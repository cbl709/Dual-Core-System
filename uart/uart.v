`timescale 1ns / 1ps
`include "uart_defines.v"

module uart(
            clk,
            tx_write,
            rx_read,
            sr_read,
            cr,
            sr,
            ttr,      //time out and trigger_level register
            tdr,
            rdr,
            srx_pad_i, // uart in
            stx_pad_o,// uart out
            int_pad_o
            );
    input clk;
    input tx_write;
    input sr_read;
    input rx_read;
    input [31:0] cr;
    input [31:0] ttr;
    output [31:0]sr;
    input [31:0] tdr;
    output [31:0] rdr;
    input srx_pad_i; // uart in
    output stx_pad_o;// uart out
    output int_pad_o;
    
    reg int_o=1'b0;
    reg[31:0] rdr;

///////////////////lsr iir wire and regs////

wire [9:0]                              lsr;  //line status
wire                                    lsr0, lsr1, lsr2, lsr3, lsr4, lsr5, lsr6, lsr7, lsr8, lsr9;
reg                                     lsr0r=0, lsr1r=0, lsr2r=0, lsr3r=0, lsr4r=0, lsr5r=1, lsr6r=1, lsr7r=0, lsr8r=0, lsr9r=0;
assign                                  lsr[9:0] = {lsr9r,lsr8r, lsr7r, lsr6r, lsr5r, lsr4r, lsr3r, lsr2r, lsr1r, lsr0r };
reg  [7:0]                              iir= 8'hc1;
assign sr={14'b00000000000000,lsr,iir};

//////////////////ttr wire///////
wire [7:0]                              time_out_val;
assign                                  time_out_val = ttr[7:0];
wire [`UART_FIFO_COUNTER_W-1:0]         trigger_level;
assign                                  trigger_level= ttr[`UART_FIFO_COUNTER_W+7:8];


/////// Frequency divider signals/////////////////////
wire dlab;                  //divisor latch access bit
reg enable      =1'b0;
reg [7:0]   dlc =1'b0;
wire        start_dlc;
assign      dlab= cr[`CR_LC_DL];
assign      start_dlc= dlab&(cr[31:24]!=0); // dlab==1 and dl!=0

always @(posedge clk) 
begin
      if(start_dlc) begin
        if (dlc==0)           
            dlc <= #1 cr[31:24] - 1;               // reload counter
        else
            dlc <= #1 dlc - 1;              // decrement counter
        end
end

// Enable signal generation logic
always @(posedge clk )
begin
        if ( ~(|dlc) &start_dlc)     //  dlc==0 &start_dlc
            enable <= #1 1'b1;
        else
            enable <= #1 1'b0;
end


/////////////////////////push_pulse logic//////////////////////////
//tf_push signal shows the cpu is writing a data to TDR, but since it is an asynchronous signal,
// it may be wider than 1 clk, which can cause more than 1  write to the tx fifo
// so here we detect the falling edge of the tf_push

reg push_d1=1'b0;
reg push_d2=1'b0;
wire tf_push; 
////tf_push logic

assign tf_push=(tx_write&start_dlc);
always@( posedge clk )
begin
      push_d1<= tf_push;
      push_d2<= push_d1;
end
wire push_pulse; // this signal is used to push the data to transmitter fifo

assign push_pulse=~push_d1&push_d2;// detect the falling edge of tf_push


//////////////// lsr_mask  is used to clear the lsr after cpu read the lsr/////////////////////////////
wire   lsr_mask_condition;   
wire   lsr_mask;
reg     lsr_mask_d=1'b0;
assign lsr_mask_condition= sr_read&start_dlc; // when read the sr register and UART has been start
assign lsr_mask = ~lsr_mask_condition && lsr_mask_d; // falling edge of lsr_mask_condition detection
// lsr_mask_d delayed signal handling
always @(posedge clk )
begin   
// reset bits in the Line Status Register
    lsr_mask_d <= #1 lsr_mask_condition;
end


///////////////transmitter////////////////////
wire [7:0] dat_i; // data to be transmitted
wire        tf_overrun;

wire serial_out;
wire tx_reset;
wire [`UART_FIFO_COUNTER_W-1:0]                 tf_count;
wire [2:0]                                      tstate;

assign dat_i[7:0]= tdr[7:0];
assign stx_pad_o= serial_out;
assign tx_reset = cr[ `CR_TX_RESET ];
uart_transmitter transmitter(
                            .clk(clk),
                            .dat_i(dat_i),
                            .lcr(cr[23:16]),
                            .lsr_mask(lsr_mask),
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
wire [31:0] counter_t;
wire [`UART_FIFO_COUNTER_W-1:0]             rf_count;//5bits
wire [`UART_FIFO_REC_WIDTH-1:0]             rf_data_out; // 11 bits
wire rf_error_bit;
wire rf_overrun;
wire rx_reset;
wire [3:0]                                      rstate;
wire rf_push_pulse;

assign rx_reset=cr[ `CR_RX_RESET ];
assign serial_in=srx_pad;  


uart_receiver receiver(.clk(clk), 
                       .lcr(cr[23:16]), 
                       .time_out_val(time_out_val),
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
reg pop_d1=1'b0;
reg pop_d2=1'b0;
wire rf_pop; 

assign rf_pop=(rx_read&start_dlc); // CPU read the RDR 
always@( posedge clk )
begin
      pop_d1<= rf_pop;
      pop_d2<= pop_d1;
  
end
assign rf_pop_pulse=~pop_d1&pop_d2;// detect the falling edge of tf_push


    
//----------------------------------------------------------------------------------------------
//  STATUS REGISTERS  //
//

// Line Status  Register
wire thre_set_en;
wire frame_idle_en; //发送FIFO为空，并且保持空闲时间time_out_val+0.5个字节时间长度
// activation conditions
assign lsr0 = (rf_count==0 && rf_push_pulse);  // data in receiver fifo available set condition
assign lsr1 = rf_overrun;     // Receiver overrun error
assign lsr2 = rf_data_out[1]; // parity error bit
assign lsr3 = rf_data_out[0]; // framing error bit
assign lsr4 = rf_data_out[2]; // break error in the character
assign lsr5 = (tf_count==`UART_FIFO_COUNTER_W'b0 && thre_set_en&& (tstate == /*`S_IDLE */ 0)); // transmitter empty
assign lsr6 = (tf_count==`UART_FIFO_COUNTER_W'b0 && frame_idle_en && (tstate == /*`S_IDLE */ 0)); // 数据帧发送标志
assign lsr7 = rf_error_bit  ;
assign lsr8 = tf_overrun;
assign lsr9 = read_empty;

// lsr bit0 (receiver data available)
reg      lsr0_d=1'b0;

always @(posedge clk )
     lsr0_d <= #1 lsr0;

always @(posedge clk )
    lsr0r <= #1 (rf_count==1 && rf_pop && !rf_push_pulse || rx_reset) ? 0 : // deassert condition
                      lsr0r || (lsr0 && ~lsr0_d); // set on rise of lsr0 and keep asserted until deasserted 

// lsr bit 1 (receiver overrun)
reg lsr1_d=1'b0; // delayed

always @(posedge clk)
    lsr1_d <= #1 lsr1;

always @(posedge clk )
        lsr1r <= #1 lsr_mask ? 0 : lsr1r || (lsr1 && ~lsr1_d); // set on rise

// lsr bit 2 (parity error)
reg lsr2_d=1'b0; // delayed

always @(posedge clk )
    lsr2_d <= #1 lsr2;

always @(posedge clk )
    lsr2r <= #1 lsr_mask ? 0 : lsr2r || (lsr2 && ~lsr2_d); // set on rise

// lsr bit 3 (framing error)
reg lsr3_d=1'b0; // delayed

always @(posedge clk )
     lsr3_d <= #1 lsr3;

always @(posedge clk )
    lsr3r <= #1 lsr_mask ? 0 : lsr3r || (lsr3 && ~lsr3_d); // set on rise

// lsr bit 4 (break indicator)
reg lsr4_d=1'b0; // delayed

always @(posedge clk )
    lsr4_d <= #1 lsr4;

always @(posedge clk )
     lsr4r <= #1 lsr_mask ? 0 : lsr4r || (lsr4 && ~lsr4_d);

// lsr bit 5 (transmitter fifo is empty)
reg lsr5_d=1'b1;

always @(posedge clk  )
     lsr5_d <= #1 lsr5;

always @(posedge clk )
    lsr5r <= #1 (tx_write) ? 0 :  lsr5r || (lsr5 && ~lsr5_d);

// lsr bit 6 (transmitter empty indicator)
reg lsr6_d=1'b1;

always @(posedge clk)
    lsr6_d <= #1 lsr6;

always @(posedge clk )
    lsr6r <= #1 (tx_write) ? 0 : lsr6r || (lsr6 && ~lsr6_d);

// lsr bit 7 (error in fifo)
reg lsr7_d=1'b0;

always @(posedge clk)
    lsr7_d <= #1 lsr7;

always @(posedge clk )  
    lsr7r <= #1 lsr_mask ? 0 : lsr7r || (lsr7 && ~lsr7_d);

// lsr bit 8 ( transmitter fifo is overrun)
reg lsr8_d=1'b0;

always @(posedge clk )
     lsr8_d <= #1 lsr8;

always @(posedge clk )
     lsr8r <= #1 lsr_mask ? 0 : lsr8r || (lsr8 && ~lsr8_d);

// lsr bit 9 ( cpu will read an empty fifo interrupt)
reg lsr9_d=1'b0;

always @(posedge clk )
    lsr9_d <= #1 lsr9;

always @(posedge clk )  
    lsr9r <= #1 lsr_mask ? 0 : lsr9r || (lsr9 && ~lsr9_d);


    
    
// Delaying THRE status for one character cycle after a character is written to an empty fifo.
reg [7:0] block_value; // one character length minus stop bit
reg [7:0] block_cnt=8'd0;
always @(cr)
  case (cr[19:16])
    4'b0000                             : block_value = 111; // 7 bits
    4'b0100                             : block_value = 119; // 7.5 bits
    4'b0001, 4'b1000                    : block_value = 127; // 8 bits
    4'b1100                             : block_value = 135; // 8.5 bits
    4'b0010, 4'b0101, 4'b1001           : block_value = 143; // 9 bits
    4'b0011, 4'b0110, 4'b1010, 4'b1101  : block_value = 159; // 10 bits
    4'b0111, 4'b1011, 4'b1110           : block_value = 175; // 11 bits
    4'b1111                             : block_value = 191; // 12 bits
  endcase // case(lcr[3:0])

// Counting time of one character minus stop bit
always @(posedge clk)
begin
  if(tx_write)  //  write to fifo occured will stop the THRE interrupt
    block_cnt <= #1 block_value;
  else
  if (enable & block_cnt != 8'b0 )  // only work on enable times
    block_cnt <= #1 block_cnt - 1;  // decrement break counter
end // always of break condition detection


//idle_cnt 计算fifo为空的时间长度
reg [31:0] idle_cnt;
always@(time_out_val or block_value)
begin
  idle_cnt <= time_out_val*(block_value+1)+ block_value/2; //设定值为time_out_val+0.5个字节时间长度
end

reg [31:0] frame_idle_cnt =32'b0;
always@ (posedge clk)
begin
  if(~lsr5r) //发送fifo有数据可发时重新计数
     frame_idle_cnt <= idle_cnt; //
  else      //发送fifo空闲，开始倒计时
     if (enable & frame_idle_cnt != 32'b0 )  // only work on enable times
        frame_idle_cnt <= #1 frame_idle_cnt - 1;  // decrement break counter
end

// Generating THRE status enable signal
assign thre_set_en = ~(|block_cnt);
assign frame_idle_en=~(|frame_idle_cnt);  //倒计时为0，触发发送帧中断
//------------------------------------------------------------------


//
//  INTERRUPT LOGIC
//
wire rls_int; //Receiver Line Status Interrupt
wire rda_int; // when the data in rx_fifo is more than trigger_level
wire thre_int;
wire ti_int;
wire ften_int;

assign rls_int  = cr[`UART_IE_RLS] && (lsr[`UART_LS_OE] || lsr[`UART_LS_PE] || lsr[`UART_LS_FE] || lsr[`UART_LS_BI]|| lsr[`UART_LS_TO] || lsr[`UART_LS_RE]);
assign rda_int  = cr[`UART_IE_RDA] && (rf_count >= trigger_level);
assign thre_int = cr[`UART_IE_THRE ] && lsr[`UART_LS_TFE];
assign ften_int = cr[`UART_IE_FTEN]  && lsr[`UART_LS_FTE];
assign ti_int   = cr[`UART_IE_TO ] && ~(|counter_t ) && (|rf_count);

reg      rls_int_d  =1'b0;
reg      thre_int_d =1'b0;
reg      ti_int_d   =1'b0;
reg      rda_int_d  =1'b0;
reg      ften_int_d =1'b0;

// delay lines
always  @(posedge clk)
    rls_int_d <= #1 rls_int;

always  @(posedge clk)
    rda_int_d <= #1 rda_int;

always  @(posedge clk)
    thre_int_d <= #1 thre_int;

always  @(posedge clk )
    ti_int_d <= #1 ti_int;
    
always  @(posedge clk )
    ften_int_d <= #1 ften_int;

// rise detection signals

wire     rls_int_rise;
wire     thre_int_rise;
wire     ti_int_rise;
wire     rda_int_rise;
wire     ften_int_rise;

assign rda_int_rise    = rda_int & ~rda_int_d;
assign rls_int_rise    = rls_int & ~rls_int_d;
assign thre_int_rise   = thre_int & ~thre_int_d;
assign ti_int_rise     = ti_int & ~ti_int_d;
assign ften_int_rise   = ften_int&~ften_int_d;

// interrupt pending flags
reg     rls_int_pnd  =1'b0;
reg     rda_int_pnd  =1'b0;
reg     thre_int_pnd =1'b0;
reg     ti_int_pnd   =1'b0;
reg     ften_int_pnd =1'b0;

// interrupt pending flags assignments
always  @(posedge clk )
        rls_int_pnd <= #1 lsr_mask ? 0 :                        // reset condition
                          rls_int_rise ? 1 :                        // latch condition
                          rls_int_pnd && cr[`UART_IE_RLS];  // default operation: remove if masked

always  @(posedge clk)
        rda_int_pnd <= #1 ((rf_count == {1'b0,trigger_level}) && rx_read) ? 0 :     // reset condition
                            rda_int_rise ? 1 :                      // latch condition
                            rda_int_pnd && cr[`UART_IE_RDA];    // default operation: remove if masked

always  @(posedge clk )
        thre_int_pnd <= #1 tx_write || sr_read ? 0 : 
                            thre_int_rise ? 1 :
                            thre_int_pnd && cr[`UART_IE_THRE];

always  @(posedge clk )
        ften_int_pnd <= #1 tx_write || sr_read? 0 : 
                            ften_int_rise ? 1 :
                            ften_int_pnd && cr[`UART_IE_FTEN];

always  @(posedge clk )
    
        ti_int_pnd <= #1 rx_read ? 0 : 
                            ti_int_rise ? 1 :
                            ti_int_pnd && cr[`UART_IE_TO];
// end of pending flags

// INT_O logic
always @(posedge clk )
begin
        int_o <= #1 
                    rls_int_pnd     ?   ~lsr_mask                   :
                    rda_int_pnd     ? 1                             :
                    ti_int_pnd      ? ~rx_read                      :
                    thre_int_pnd    ? !(tx_write & sr_read)         :
                    ften_int_pnd    ? !(tx_write & sr_read)         :
                    
                    0;  // if no interrupt are pending
end


// Interrupt Identification register
always @(posedge clk )
begin
    
    if (rls_int_pnd)  // interrupt is pending
    begin
        iir[`UART_II_II] <= #1 `UART_II_RLS;    // set identification register to correct value
        iir[`UART_II_IP] <= #1 1'b0;        // and clear the IIR bit 0 (interrupt pending)
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
    else if(ften_int_pnd)
    begin
        iir[`UART_II_II] <= #1 `UART_II_FTEN;
        iir[`UART_II_IP] <= #1 1'b0;
    end
    else if(~int_o) // no interrupt is pending and all interrupts are clear
    begin
        iir[`UART_II_II] <= #1 0;
        iir[`UART_II_IP] <= #1 1'b1;
    end
end

//------------------type of interrupt signal----------------------------------
reg cnt=1'b0;
reg int_pad_o;
always@( posedge clk  )
begin 
   if(enable& int_o)
     cnt<=cnt+1;
    else
    if(~int_o)
      cnt<=0;

end

always@(cr)
begin
  if(cr[8])  //fcr[0] use to select the type of interrupt signal--electrical level or pulse module
   int_pad_o=cnt;
  else
   int_pad_o=int_o;
end

endmodule
    
