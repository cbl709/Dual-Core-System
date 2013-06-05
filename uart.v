`timescale 1ns / 1ps
`include "uart_defines.v"

module uart(
			clk,
			rst_n,
			tx_write,
			rx_read,
			sr_read,
			cr,
			sr,
			tdr,
			rdr,
			srx_pad_i, // uart in
		   stx_pad_o,// uart out
			int_pad_o
			);
	input clk;
	input rst_n;
	input tx_write;
	input sr_read;
	input rx_read;
	input [31:0] cr;
	output [31:0]sr;
	input [31:0] tdr;
	output [31:0] rdr;
	input srx_pad_i; // uart in
	output stx_pad_o;// uart out
	output int_pad_o;
	reg int_o;
	
	
	
	reg[31:0] rdr;

///////////////////lsr iir wire and regs////

wire [9:0]								lsr;  //line status
wire 									   lsr0, lsr1, lsr2, lsr3, lsr4, lsr5, lsr6, lsr7, lsr8, lsr9;
reg										lsr0r, lsr1r, lsr2r, lsr3r, lsr4r, lsr5r, lsr6r, lsr7r, lsr8r, lsr9r;
assign 									lsr[9:0] = {lsr9r,lsr8r, lsr7r, lsr6r, lsr5r, lsr4r, lsr3r, lsr2r, lsr1r, lsr0r };
reg  [7:0]								iir;
assign sr={14'b00000000000000,lsr,iir};


//////////////////cr wire//////////////////////
/*wire [31:0] cr;

wire ier[7:0];
wire fcr[7:0];
wire lcr[7:0];
wire dl[7:0];
assign ier[7:0]=cr[7:0];
assign fcr[7:0]=cr[15:8];
assign lcr[7:0]=cr[23:16];
assign  dl[7:0]=cr[31:24];*/
//////////////////////////////////////////////


/////// Frequency divider signals/////////////////////
wire dlab;					//divisor latch access bit
reg enable;
reg [7:0]   dlc;
wire  		start_dlc;
assign 		dlab= cr[`CR_LC_DL];
assign 		start_dlc= dlab&(cr[31:24]!=0); // dlab==1 and dl!=0

always @(posedge clk or negedge rst_n) 
begin
	if (~rst_n) 
		dlc <= #1 0;
	else
	  if(start_dlc) begin
		if (dlc==0)           
  			dlc <= #1 cr[31:24] - 1;               // reload counter
		else
			dlc <= #1 dlc - 1;              // decrement counter
	 end
end

// Enable signal generation logic
always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)
		enable <= #1 1'b0;
	else
		if ( ~(|dlc) &start_dlc)     //  dlc==0 &start_dlc
			enable <= #1 1'b1;
		else
			enable <= #1 1'b0;
end


/////////////////////////push_pulse logic//////////////////////////
//tf_push signal shows the cpu is writing a data to TDR, but since it is an asynchronous signal,
// it may be wider than 1 clk, which can cause more than 1  write to the tx fifo
// so here we detect the falling edge of the tf_push

reg push_d1;
reg push_d2;
wire tf_push; 
////tf_push logic

assign tf_push=(tx_write&start_dlc);
always@( posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
	  push_d1<=0;
	  push_d2<=0;
  end else begin
	  push_d1<= tf_push;
	  push_d2<= push_d1;
  end //end of else
end
wire push_pulse; // this signal is used to push the data to transmitter fifo

assign push_pulse=~push_d1&push_d2;// detect the falling edge of tf_push


//////////////// lsr_mask  is used to clear the lsr after cpu read the lsr/////////////////////////////
wire 	lsr_mask_condition;   
wire   lsr_mask;
reg 	lsr_mask_d;
assign lsr_mask_condition= sr_read&start_dlc; // when read the sr register and UART has been start
assign lsr_mask = ~lsr_mask_condition && lsr_mask_d; // falling edge of lsr_mask_condition detection
// lsr_mask_d delayed signal handling
always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)
		lsr_mask_d <= #1 0;
	else // reset bits in the Line Status Register
		lsr_mask_d <= #1 lsr_mask_condition;
end


///////////////transmitter////////////////////
wire [7:0] dat_i; // data to be transmitted
wire 		tf_overrun;

wire serial_out;
wire tx_reset;
wire [`UART_FIFO_COUNTER_W-1:0] 				tf_count;
wire [2:0] 										tstate;

assign dat_i[7:0]= tdr[7:0];
assign stx_pad_o= serial_out;
assign tx_reset = cr[ `CR_TX_RESET ];


uart_transmitter transmitter(
							.clk(clk),
							.dat_i(dat_i),
							.lcr(cr[23:16]),
							.lsr_mask(lsr_mask),
							.rst_n(rst_n),
							.tf_push(push_pulse),
							.tx_reset(tx_reset),
							.enable(enable),
							.tf_count(tf_count),
							.tf_overrun(tf_overrun),
							.tstate(tstate),
							.stx_pad_o(serial_out)
							);
							
							
///////////////////////////
// Synchronizing and sampling serial RX input
wire srx_pad;

  uart_sync_flops    i_uart_sync_flops
  (
    .rst_i           (rst_n),
    .clk_i           (clk),
    .stage1_rst_i    (1'b0),
    .stage1_clk_en_i (1'b1),
    .async_dat_i     (srx_pad_i),
    .sync_dat_o      (srx_pad)
  );
  defparam i_uart_sync_flops.width      = 1;
  defparam i_uart_sync_flops.init_value = 1'b1;
  
// Receiver Instance

wire rf_pop_pulse; // this signal is used to pop the data from receiver fifo
wire serial_in;
wire [9:0] counter_t;
wire [`UART_FIFO_COUNTER_W-1:0] 			rf_count;//5bits
wire [`UART_FIFO_REC_WIDTH-1:0] 			rf_data_out; // 11 bits
wire rf_error_bit;
wire rf_overrun;
wire rx_reset;
wire [3:0] 										rstate;
wire rf_push_pulse;

assign rx_reset=cr[ `CR_RX_RESET ];
assign serial_in=srx_pad;  ///test
//assign serial_in= serial_out;

uart_receiver receiver(.clk(clk), 
					   .rst_n(rst_n),
					   .lcr(cr[23:16]), 
					   .rf_pop(rf_pop_pulse),
					   .srx_pad_i(serial_in), 
					   .enable(enable), 
					   .counter_t(counter_t), 
					   .rf_count(rf_count), 
					   .rf_data_out(rf_data_out), 
					   .rf_error_bit(rf_error_bit), // a 1 is returned if any of the error bits in the fifo is 1
					   .rf_overrun(rf_overrun),
					   .read_empty(read_empty), 
					   .rx_reset(rx_reset), 
					   .lsr_mask(lsr_mask), 
					   .rstate(rstate),
					   .rf_push_pulse(rf_push_pulse)
					   );
					   
/////asynchronous read  the rx_fifo data 
always@( rf_data_out or cr )
begin
    
	rdr={24'h0,rf_data_out[10:3]};
end

//////////rf_pop_pulse logic //////
reg pop_d1;
reg pop_d2;
wire rf_pop; 

assign rf_pop=(rx_read&start_dlc); // CPU read the RDR 
always@( posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
	  pop_d1<=0;
	  pop_d2<=0;
  end else begin
	  pop_d1<= rf_pop;
	  pop_d2<= pop_d1;
  end //end of else
end
assign rf_pop_pulse=~pop_d1&pop_d2;// detect the falling edge of tf_push

//////////////
// Receiver FIFO trigger level selection logic (asynchronous mux)
reg[3:0] trigger_level;
always @(cr)
	case (cr[`CR_FC_TL])               //fcr[7:6]
		2'b00 : trigger_level = 1;
		2'b01 : trigger_level = 4;
		2'b10 : trigger_level = 8;
		2'b11 : trigger_level = 14;
	endcase // case(fcr[`UART_FC_TL])
	


//----------------------------------------------------------------------------------------------
//  STATUS REGISTERS  //
//

// Line Status  Register
wire thre_set_en;

// activation conditions
assign lsr0 = (rf_count==0 && rf_push_pulse);  // data in receiver fifo available set condition
assign lsr1 = rf_overrun;     // Receiver overrun error
assign lsr2 = rf_data_out[1]; // parity error bit
assign lsr3 = rf_data_out[0]; // framing error bit
assign lsr4 = rf_data_out[2]; // break error in the character
//assign lsr5 = (tf_count==5'b0 && thre_set_en);  // transmitter fifo is empty
assign lsr5 = (tf_count==`UART_FIFO_COUNTER_W'b0&& thre_set_en );  // transmitter fifo is empty
assign lsr6 = (tf_count==`UART_FIFO_COUNTER_W'b0 && thre_set_en && (tstate == /*`S_IDLE */ 0)); // transmitter empty
assign lsr7 = rf_error_bit  ;
assign lsr8 = tf_overrun;
assign lsr9 = read_empty;

// lsr bit0 (receiver data available)
reg 	 lsr0_d;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr0_d <= #1 0;
	else lsr0_d <= #1 lsr0;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr0r <= #1 0;
	else lsr0r <= #1 (rf_count==1 && rf_pop && !rf_push_pulse || rx_reset) ? 0 : // deassert condition
					  lsr0r || (lsr0 && ~lsr0_d); // set on rise of lsr0 and keep asserted until deasserted 

// lsr bit 1 (receiver overrun)
reg lsr1_d; // delayed

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr1_d <= #1 0;
	else lsr1_d <= #1 lsr1;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr1r <= #1 0;
	else	lsr1r <= #1	lsr_mask ? 0 : lsr1r || (lsr1 && ~lsr1_d); // set on rise

// lsr bit 2 (parity error)
reg lsr2_d; // delayed

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr2_d <= #1 0;
	else lsr2_d <= #1 lsr2;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr2r <= #1 0;
	else lsr2r <= #1 lsr_mask ? 0 : lsr2r || (lsr2 && ~lsr2_d); // set on rise

// lsr bit 3 (framing error)
reg lsr3_d; // delayed

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr3_d <= #1 0;
	else lsr3_d <= #1 lsr3;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr3r <= #1 0;
	else lsr3r <= #1 lsr_mask ? 0 : lsr3r || (lsr3 && ~lsr3_d); // set on rise

// lsr bit 4 (break indicator)
reg lsr4_d; // delayed

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr4_d <= #1 0;
	else lsr4_d <= #1 lsr4;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr4r <= #1 0;
	else lsr4r <= #1 lsr_mask ? 0 : lsr4r || (lsr4 && ~lsr4_d);

// lsr bit 5 (transmitter fifo is empty)
reg lsr5_d;

always @(posedge clk or negedge rst_n )
	if (~rst_n) lsr5_d <= #1 1;
	else lsr5_d <= #1 lsr5;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr5r <= #1 1;
	else lsr5r <= #1 (tx_write) ? 0 :  lsr5r || (lsr5 && ~lsr5_d);

// lsr bit 6 (transmitter empty indicator)
reg lsr6_d;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr6_d <= #1 1;
	else lsr6_d <= #1 lsr6;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr6r <= #1 1;
	else lsr6r <= #1 (tx_write) ? 0 : lsr6r || (lsr6 && ~lsr6_d);

// lsr bit 7 (error in fifo)
reg lsr7_d;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr7_d <= #1 0;
	else lsr7_d <= #1 lsr7;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr7r <= #1 0;
	else lsr7r <= #1 lsr_mask ? 0 : lsr7r || (lsr7 && ~lsr7_d);

// lsr bit 8 ( transmitter fifo is overrun)
reg lsr8_d;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr8_d <= #1 0;
	else lsr8_d <= #1 lsr8;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr8r <= #1 0;
	else lsr8r <= #1 lsr_mask ? 0 : lsr8r || (lsr8 && ~lsr8_d);

// lsr bit 9 ( cpu will read an empty fifo interrupt)
reg lsr9_d;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr9_d <= #1 0;
	else lsr9_d <= #1 lsr9;

always @(posedge clk or negedge rst_n)
	if (~rst_n) lsr9r <= #1 0;
	else lsr9r <= #1 lsr_mask ? 0 : lsr9r || (lsr9 && ~lsr9_d);


	
	
// Delaying THRE status for one character cycle after a character is written to an empty fifo.
reg [7:0] block_value; // one character length minus stop bit
reg [7:0] block_cnt;
always @(cr)
  case (cr[19:16])
    4'b0000                             : block_value =  95; // 6 bits
    4'b0100                             : block_value = 103; // 6.5 bits
    4'b0001, 4'b1000                    : block_value = 111; // 7 bits
    4'b1100                             : block_value = 119; // 7.5 bits
    4'b0010, 4'b0101, 4'b1001           : block_value = 127; // 8 bits
    4'b0011, 4'b0110, 4'b1010, 4'b1101  : block_value = 143; // 9 bits
    4'b0111, 4'b1011, 4'b1110           : block_value = 159; // 10 bits
    4'b1111                             : block_value = 175; // 11 bits
  endcase // case(lcr[3:0])

// Counting time of one character minus stop bit
always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
    block_cnt <= #1 8'd0;
  else
  if(tx_write)  //  write to fifo occured will stop the THRE interrupt
    block_cnt <= #1 block_value;
  else
  if (enable & block_cnt != 8'b0)  // only work on enable times
    block_cnt <= #1 block_cnt - 1;  // decrement break counter
end // always of break condition detection

// Generating THRE status enable signal
assign thre_set_en = ~(|block_cnt);
//------------------------------------------------------------------


//
//	INTERRUPT LOGIC
//
wire rls_int; //Receiver Line Status Interrupt
wire rda_int; // when the data in rx_fifo is more than trigger_level
wire thre_int;
wire ti_int;

assign rls_int  = cr[`UART_IE_RLS] && (lsr[`UART_LS_OE] || lsr[`UART_LS_PE] || lsr[`UART_LS_FE] || lsr[`UART_LS_BI]|| lsr[`UART_LS_TO] || lsr[`UART_LS_RE]);
assign rda_int  = cr[`UART_IE_RDA] && (rf_count >= trigger_level);
assign thre_int = cr[`UART_IE_THRE ] && lsr[`UART_LS_TFE];
assign ti_int   = cr[`UART_IE_TO ] && (counter_t == 10'b0) && (|rf_count);

reg 	 rls_int_d;
reg 	 thre_int_d;
reg 	 ti_int_d;
reg 	 rda_int_d;

// delay lines
always  @(posedge clk or negedge rst_n)
	if (~rst_n) rls_int_d <= #1 0;
	else rls_int_d <= #1 rls_int;

always  @(posedge clk or negedge rst_n)
	if (~rst_n) rda_int_d <= #1 0;
	else rda_int_d <= #1 rda_int;

always  @(posedge clk or negedge rst_n)
	if (~rst_n) thre_int_d <= #1 0;
	else thre_int_d <= #1 thre_int;

always  @(posedge clk or negedge rst_n)
	if (~rst_n) ti_int_d <= #1 0;
	else ti_int_d <= #1 ti_int;

// rise detection signals

wire 	 rls_int_rise;
wire 	 thre_int_rise;
wire 	 ti_int_rise;
wire 	 rda_int_rise;

assign rda_int_rise    = rda_int & ~rda_int_d;
assign rls_int_rise    = rls_int & ~rls_int_d;
assign thre_int_rise   = thre_int & ~thre_int_d;
assign ti_int_rise 	   = ti_int & ~ti_int_d;

// interrupt pending flags
reg 	rls_int_pnd;
reg		rda_int_pnd;
reg 	thre_int_pnd;
reg 	ti_int_pnd;

// interrupt pending flags assignments
always  @(posedge clk or negedge rst_n)
	if (~rst_n) rls_int_pnd <= #1 0; 
	else 
		rls_int_pnd <= #1 lsr_mask ? 0 :  						// reset condition
						  rls_int_rise ? 1 :						// latch condition
						  rls_int_pnd && cr[`UART_IE_RLS];	// default operation: remove if masked

always  @(posedge clk or negedge rst_n)
	if (~rst_n) rda_int_pnd <= #1 0; 
	else 
		rda_int_pnd <= #1 ((rf_count == {1'b0,trigger_level}) && rx_read) ? 0 :  	// reset condition
							rda_int_rise ? 1 :						// latch condition
							rda_int_pnd && cr[`UART_IE_RDA];	// default operation: remove if masked

always  @(posedge clk or negedge rst_n)
	if (~rst_n) thre_int_pnd <= #1 0; 
	else 
		thre_int_pnd <= #1 tx_write || (sr_read & ~iir[`UART_II_IP] & iir[`UART_II_II] == `UART_II_THRE)? 0 : 
							thre_int_rise ? 1 :
							thre_int_pnd && cr[`UART_IE_THRE];


always  @(posedge clk or negedge rst_n)
	if (~rst_n) ti_int_pnd <= #1 0; 
	else 
		ti_int_pnd <= #1 rx_read ? 0 : 
							ti_int_rise ? 1 :
							ti_int_pnd && cr[`UART_IE_TO];
// end of pending flags

// INT_O logic
always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)	
		int_o <= #1 1'b0;
	else
		int_o <= #1 
					rls_int_pnd		?	~lsr_mask					:
					rda_int_pnd		? 1								:
					ti_int_pnd		? ~rx_read						:
					thre_int_pnd	? !(tx_write & sr_read) 	:
					0;	// if no interrupt are pending
end


// Interrupt Identification register
always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)
		iir <= #1 8'hc1;
	else
	if (rls_int_pnd)  // interrupt is pending
	begin
		iir[`UART_II_II] <= #1 `UART_II_RLS;	// set identification register to correct value
		iir[`UART_II_IP] <= #1 1'b0;		// and clear the IIR bit 0 (interrupt pending)
	end else // the sequence of conditions determines priority of interrupt identification
	if (rda_int)
	begin
		iir[`UART_II_II] <= #1 `UART_II_RDA;
		iir[`UART_II_IP] <= #1 1'b0;
	end
	else if (ti_int_pnd)
	begin
		iir[`UART_II_II] <= #1 `UART_II_TI;
		iir[`UART_II_IP] <= #1 1'b0;
	end
	else if (thre_int_pnd)
	begin
		iir[`UART_II_II] <= #1 `UART_II_THRE;
		iir[`UART_II_IP] <= #1 1'b0;
	end
	
	else if(~int_o)	// no interrupt is pending and all interrupts are clear
	begin
		iir[`UART_II_II] <= #1 0;
		iir[`UART_II_IP] <= #1 1'b1;
	end
end

//------------------type of interrupt signal----------------------------------
reg cnt;
reg int_pad_o;
always@( posedge clk or negedge rst_n )
begin 
  if(~rst_n)
    cnt<=0;
  else begin
   if(enable& int_o)
	 cnt<=cnt+1;
	else
	if(~int_o)
	  cnt<=0;
  end
    
end

always@(cr)
begin
  if(cr[8])  //fcr[0] use to select the type of interrupt signal--electrical level or pulse module
   int_pad_o=cnt;
  else
   int_pad_o=int_o;
end

endmodule
	
