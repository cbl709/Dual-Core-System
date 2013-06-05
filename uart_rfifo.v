///////cbl_uart
//change log:(1) 
`timescale 1ns / 1ps
`include "c:/uart_defines.v"

module uart_rfifo (clk, 
	rst_n, data_in, data_out,
// Control signals
	push, // push strobe, active high
	pop,   // pop strobe, active high
// status signals
	overrun, // fifo is full
	read_empty,   // cpu will read empty fifo
	count,
	error_bit,
	fifo_reset,
	reset_status
	);


// FIFO parameters
parameter fifo_width = `UART_FIFO_REC_WIDTH;
parameter fifo_depth = `UART_FIFO_DEPTH;
parameter fifo_pointer_w = `UART_FIFO_POINTER_W;
parameter fifo_counter_w = `UART_FIFO_COUNTER_W;

input						clk;
input						rst_n;
input						push;
input						pop;

input	[`UART_FIFO_REC_WIDTH-1:0]	data_in; //11 bits
input						fifo_reset;
input       				reset_status;


output	[`UART_FIFO_REC_WIDTH-1:0]		data_out;//11 bits

output							overrun;
output                          read_empty;
output	[fifo_counter_w-1:0]	count;
output							error_bit;

wire	[`UART_FIFO_REC_WIDTH-1:0]	data_out; // 11 bits

wire [7:0] data8_out;
// flags FIFO
reg	[2:0]	fifo[fifo_depth-1:0];

// FIFO pointers
reg	[fifo_pointer_w-1:0]	top;
reg	[fifo_pointer_w-1:0]	bottom;

reg	[fifo_counter_w-1:0]	count;
reg				overrun;
reg 			read_empty;

wire [fifo_pointer_w-1:0] top_plus_1 = top + 1'b1;
wire push_logic;
assign push_logic=push&(count<fifo_depth);

raminfr #(fifo_pointer_w,8,fifo_depth) rfifo  
        (.clk(clk), 
			.we(push_logic), 
			.a(top), 
			.dpra(bottom), 
			.di(data_in[`UART_FIFO_REC_WIDTH-1:`UART_FIFO_REC_WIDTH-8]), 
			.dpo(data8_out)
		); 

always @(posedge clk or negedge rst_n) // synchronous FIFO
begin
	if (~rst_n)
	begin
		top		<= #1 0;
		bottom		<= #1 1'b0;
		count		<= #1 0;
		fifo[0] <= #1 0;
		fifo[1] <= #1 0;
		fifo[2] <= #1 0;
		fifo[3] <= #1 0;
		fifo[4] <= #1 0;
		fifo[5] <= #1 0;
		fifo[6] <= #1 0;
		fifo[7] <= #1 0;
		fifo[8] <= #1 0;
		fifo[9] <= #1 0;
		fifo[10] <= #1 0;
		fifo[11] <= #1 0;
		fifo[12] <= #1 0;
		fifo[13] <= #1 0;
		fifo[14] <= #1 0;
		fifo[15] <= #1 0;
	end
	else
	if (fifo_reset) begin
		top		<= #1 0;
		bottom		<= #1 1'b0;
		count		<= #1 0;
		fifo[0] <= #1 0;
		fifo[1] <= #1 0;
		fifo[2] <= #1 0;
		fifo[3] <= #1 0;
		fifo[4] <= #1 0;
		fifo[5] <= #1 0;
		fifo[6] <= #1 0;
		fifo[7] <= #1 0;
		fifo[8] <= #1 0;
		fifo[9] <= #1 0;
		fifo[10] <= #1 0;
		fifo[11] <= #1 0;
		fifo[12] <= #1 0;
		fifo[13] <= #1 0;
		fifo[14] <= #1 0;
		fifo[15] <= #1 0;
	end
  else
	begin
		case ({push, pop})
		2'b10 : if (count<fifo_depth)  // overrun condition
			begin
				top       <= #1 top_plus_1;
				fifo[top] <= #1 data_in[2:0];
				count     <= #1 count + 1'b1;
			end
		2'b01 : if(count>0)
			begin
                fifo[bottom] <= #1 0;
				bottom   <= #1 bottom + 1'b1;
				count	 <= #1 count - 1'b1;
			end
		2'b11 : begin
				bottom   <= #1 bottom + 1'b1;
				top       <= #1 top_plus_1;
				fifo[top] <= #1 data_in[2:0];
		        end
    default: ;
		endcase
	end
end   // always

/////overrun logic
always @(posedge clk or negedge rst_n) // synchronous FIFO
begin
  if (~rst_n)
    overrun   <= #1 1'b0;
  else
  if(fifo_reset | reset_status) 
    overrun   <= #1 1'b0;
  else
  if(push & ~pop & (count==fifo_depth))
    overrun   <= #1 1'b1;
end   // always

////empty logic
always @(posedge clk or negedge rst_n) // 
begin
  if (~rst_n)
    read_empty   <= #1 1'b0;
  else
  if(fifo_reset | reset_status) 
    read_empty   <= #1 1'b0;
  else
  if(~push & pop & (count==0))  // not receive new data and fifo is empty, should not be read
    read_empty   <= #1 1'b1;
end   // always


// please note though that data_out is only valid one clock after pop signal
assign data_out = {data8_out,fifo[bottom]};

// Additional logic for detection of error conditions (parity and framing) inside the FIFO
// for the Line Status Register bit 7

wire	[2:0]	word0 = fifo[0];
wire	[2:0]	word1 = fifo[1];
wire	[2:0]	word2 = fifo[2];
wire	[2:0]	word3 = fifo[3];
wire	[2:0]	word4 = fifo[4];
wire	[2:0]	word5 = fifo[5];
wire	[2:0]	word6 = fifo[6];
wire	[2:0]	word7 = fifo[7];

wire	[2:0]	word8 = fifo[8];
wire	[2:0]	word9 = fifo[9];
wire	[2:0]	word10 = fifo[10];
wire	[2:0]	word11 = fifo[11];
wire	[2:0]	word12 = fifo[12];
wire	[2:0]	word13 = fifo[13];
wire	[2:0]	word14 = fifo[14];
wire	[2:0]	word15 = fifo[15];

// a 1 is returned if any of the error bits in the fifo is 1
assign	error_bit = |(word0[2:0]  | word1[2:0]  | word2[2:0]  | word3[2:0]  |
            		      word4[2:0]  | word5[2:0]  | word6[2:0]  | word7[2:0]  |
            		      word8[2:0]  | word9[2:0]  | word10[2:0] | word11[2:0] |
            		      word12[2:0] | word13[2:0] | word14[2:0] | word15[2:0] );

endmodule
