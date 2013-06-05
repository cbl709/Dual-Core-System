
////cbl_uart

`timescale 1ns / 1ps
`include "c:/uart_defines.v"

module uart_receiver (clk, rst_n, lcr, rf_pop, srx_pad_i, enable, 
	counter_t, rf_count, rf_data_out, rf_error_bit, rf_overrun, read_empty,rx_reset, lsr_mask, rstate, rf_push_pulse);

input				clk;
input				rst_n;
input	         [7:0]	lcr;
input				rf_pop;
input				srx_pad_i;
input				enable;
input				rx_reset;
input               lsr_mask;

output	[9:0]			            counter_t;
output	[`UART_FIFO_COUNTER_W-1:0]	rf_count;
output	[`UART_FIFO_REC_WIDTH-1:0]	rf_data_out; //11 bits
output				rf_overrun;
output				read_empty;
output				rf_error_bit;
output [3:0] 		rstate;
output 				rf_push_pulse;

reg	[3:0]	rstate;
reg	[3:0]	rcounter16;
reg	[2:0]	rbit_counter;
reg	[7:0]	rshift;			// receiver shift register
reg		rparity;		    // received parity
reg		rparity_error;
reg		rframing_error;		// framing error flag

reg		rparity_xor;
reg	[7:0]	counter_b;	    // counts the 0 (low) signals
reg   rf_push_q; 

// RX FIFO signals
reg	    [`UART_FIFO_REC_WIDTH-1:0]	    				rf_data_in;
wire	[`UART_FIFO_REC_WIDTH-1:0]	    				rf_data_out;
wire      												rf_push_pulse;
reg														rf_push;
wire													rf_pop;
wire													rf_overrun;
wire	[`UART_FIFO_COUNTER_W-1:0]						rf_count;
wire													rf_error_bit; // an error (parity or framing) is inside the fifo
wire 													break_error = (counter_b == 0);

// RX FIFO instance
uart_rfifo #(`UART_FIFO_REC_WIDTH) fifo_rx(
	.clk(		clk		), 
	.rst_n(	rst_n	),
	.data_in(	rf_data_in	),
	.data_out(	rf_data_out	),
	.push(		rf_push_pulse		),
	.pop(		rf_pop		),
	.overrun(	rf_overrun	),
	.read_empty  (read_empty),
	.count(		rf_count	),
	.error_bit(	rf_error_bit	),
	.fifo_reset(	rx_reset	),
	.reset_status(lsr_mask)
);

wire 		rcounter16_eq_7 = (rcounter16 == 4'd7);
wire		rcounter16_eq_0 = (rcounter16 == 4'd0);
wire		rcounter16_eq_1 = (rcounter16 == 4'd1);

wire [3:0] rcounter16_minus_1 = rcounter16 - 1'b1;

parameter  sr_idle 					= 4'd0;
parameter  sr_rec_start 			= 4'd1;
parameter  sr_rec_bit 				= 4'd2;
parameter  sr_rec_parity			= 4'd3;
parameter  sr_rec_stop 				= 4'd4;
parameter  sr_check_parity 			= 4'd5;
parameter  sr_rec_prepare 			= 4'd6;
parameter  sr_end_bit				= 4'd7;
parameter  sr_ca_lc_parity			= 4'd8;
parameter  sr_wait1 				= 4'd9;
parameter  sr_push 					= 4'd10;


always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
  begin
     rstate 				<= #1 sr_idle;

	  rcounter16 			<= #1 0;
	  rbit_counter 			<= #1 0;
	  rparity_xor 			<= #1 1'b0;
	  rframing_error 		<= #1 1'b0;
	  rparity_error 		<= #1 1'b0;
	  rparity 				<= #1 1'b0;
	  rshift 				<= #1 0;
	  rf_push 				<= #1 1'b0;
	  rf_data_in 			<= #1 0;
  end
  else
  if (enable)
  begin
	case (rstate)
	sr_idle : begin
			rf_push 			  	<= #1 1'b0;
			rf_data_in 	  			<= #1 0;
			rcounter16 	  			<= #1 4'b1110; // 
			if (srx_pad_i==1'b0 & ~break_error)   // detected a pulse (start bit?)
			begin
				rstate 		  <= #1 sr_rec_start;
			end
		end
	sr_rec_start :	begin
  			rf_push 			  <= #1 1'b0;
				if (rcounter16_eq_7)    // check the pulse
					if (srx_pad_i==1'b1)   // no start bit
						rstate <= #1 sr_idle;
					else            // start bit detected
						rstate <= #1 sr_rec_prepare;
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_rec_prepare:begin
				case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a word
				2'b00 : rbit_counter <= #1 3'b100;
				2'b01 : rbit_counter <= #1 3'b101;
				2'b10 : rbit_counter <= #1 3'b110;
				2'b11 : rbit_counter <= #1 3'b111;
				endcase
				if (rcounter16_eq_0)
				begin
					rstate		<= #1 sr_rec_bit;
					rcounter16	<= #1 4'b1110;
					rshift		<= #1 0;
				end
				else
					rstate <= #1 sr_rec_prepare;
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_rec_bit :	begin
				if (rcounter16_eq_0)
					rstate <= #1 sr_end_bit;
				if (rcounter16_eq_7) // read the bit
					case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a word
					2'b00 : rshift[4:0]  <= #1 {srx_pad_i, rshift[4:1]};
					2'b01 : rshift[5:0]  <= #1 {srx_pad_i, rshift[5:1]};
					2'b10 : rshift[6:0]  <= #1 {srx_pad_i, rshift[6:1]};
					2'b11 : rshift[7:0]  <= #1 {srx_pad_i, rshift[7:1]};
					endcase
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_end_bit :   begin
				if (rbit_counter==3'b0) // no more bits in word
					if (lcr[`UART_LC_PE]) // choose state based on parity
						rstate <= #1 sr_rec_parity;
					else
					begin
						rstate <= #1 sr_rec_stop;
						rparity_error <= #1 1'b0;  // no parity - no error :)
					end
				else		// else we have more bits to read
				begin
					rstate <= #1 sr_rec_bit;
					rbit_counter <= #1 rbit_counter - 1'b1;
				end
				rcounter16 <= #1 4'b1110;
			end
	sr_rec_parity: begin
				if (rcounter16_eq_7)	// read the parity
				begin
					rparity <= #1 srx_pad_i;
					rstate <= #1 sr_ca_lc_parity; 
				end
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_ca_lc_parity : begin    // rcounter equals 6
				rcounter16  <= #1 rcounter16_minus_1;
				rparity_xor <= #1 ^{rshift,rparity}; // calculate parity on all incoming data
				rstate      <= #1 sr_check_parity;
			  end
	sr_check_parity: begin	  // rcounter equals 5
				case ({lcr[`UART_LC_EP],lcr[`UART_LC_SP]})
					2'b00: rparity_error <= #1  rparity_xor == 0;  // no error if parity 1
					2'b01: rparity_error <= #1 ~rparity;      // parity should sticked to 1
					2'b10: rparity_error <= #1  rparity_xor == 1;   // error if parity is odd
					2'b11: rparity_error <= #1  rparity;	  // parity should be sticked to 0
				endcase
				rcounter16 <= #1 rcounter16_minus_1;
				rstate <= #1 sr_wait1;
			  end
	sr_wait1 :	if (rcounter16_eq_0)
			begin
				rstate <= #1 sr_rec_stop;
				rcounter16 <= #1 4'b1110;
			end
			else
				rcounter16 <= #1 rcounter16_minus_1;
	sr_rec_stop :	begin
				if (rcounter16_eq_7)	// read stop bit
				begin
					rframing_error <= #1 !srx_pad_i; // no framing error if input is 1 (stop bit)
					rstate <= #1 sr_push;
				end
				rcounter16 <= #1 rcounter16_minus_1;
			end
	sr_push :	begin
///////////////////////////////////////
//				$display($time, ": received: %b", rf_data_in);
        if(srx_pad_i | break_error)
          begin
            if(break_error)
        		  rf_data_in 	<= #1 {8'b0, 3'b100}; // break input (empty character) to receiver FIFO
            else
        		  rf_data_in  <= #1 {rshift, 1'b0, rparity_error, rframing_error};
      		      rf_push 		  <= #1 1'b1;
    			  rstate        <= #1 sr_idle;
          end
        else if(~rframing_error)  // There's always a framing before break_error -> wait for break or srx_pad_i
          begin
       			rf_data_in  <= #1 {rshift, 1'b0, rparity_error, rframing_error};
      		    rf_push 		  <= #1 1'b1;
      			rcounter16 	  <= #1 4'b1110;
    				rstate 		  <= #1 sr_rec_start;
          end
                      
			end
	default : rstate <= #1 sr_idle;
	endcase
  end  // if (enable)
end // always of receiver

always @ (posedge clk or negedge rst_n)
begin
  if(~rst_n)
    rf_push_q <= 0;
  else
    rf_push_q <= #1 rf_push;
end

assign rf_push_pulse = rf_push & ~rf_push_q; // detect the rising edge of rf_push

  
//
// Break condition detection.
// Works in conjuction with the receiver state machine
// counter_b   1 characters time
// counter_t   4 characters time

reg 	[9:0]	toc_value; // value to be set to timeout counter

always @(lcr)
	case (lcr[3:0])
		4'b0000										: toc_value = 447; // 7 bits
		4'b0100										: toc_value = 479; // 7.5 bits
		4'b0001,	4'b1000							: toc_value = 511; // 8 bits
		4'b1100										: toc_value = 543; // 8.5 bits
		4'b0010, 4'b0101, 4'b1001				: toc_value = 575; // 9 bits
		4'b0011, 4'b0110, 4'b1010, 4'b1101	: toc_value = 639; // 10 bits
		4'b0111, 4'b1011, 4'b1110				: toc_value = 703; // 11 bits
		4'b1111										: toc_value = 767; // 12 bits
	endcase // case(lcr[3:0])

wire [7:0] 	brc_value; // value to be set to break counter
assign 		brc_value = toc_value[9:2]; // the same as timeout but 1 insead of 4 character times

always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)
		counter_b <= #1 8'd159;
	else
	if (srx_pad_i)
		counter_b <= #1 brc_value; // character time length - 1
	else
	if(enable & counter_b != 8'b0)            // only work on enable times  break not reached.
		counter_b <= #1 counter_b - 1;  // decrement break counter
end // always of break condition detection

///
/// Timeout condition detection
reg	[9:0]	counter_t;	// counts the timeout condition clocks

always @(posedge clk or negedge rst_n)
begin
	if (~rst_n)
		counter_t <= #1 10'd639; // 10 bits for the default 8N1
	else
		if(rf_push_pulse || rf_pop || rf_count == 0) // counter is reload when RX FIFO is empty, pop or push
			counter_t <= #1 toc_value;
		else
		if (enable && counter_t != 10'b0)  // we don't want to underflow
			counter_t <= #1 counter_t - 1;		
end
	
endmodule
