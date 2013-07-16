///////cbl_uart
//change log:(1) 
`timescale 1ns / 1ps
`include "uart_defines.v"

module uart_rfifo (clk, 
	 data_in, data_out,
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
reg	[fifo_pointer_w-1:0]	top=0;
reg	[fifo_pointer_w-1:0]	bottom=0;

reg	[fifo_counter_w-1:0]	count=0;
reg				overrun=0;
reg 			read_empty=0;

wire [fifo_pointer_w-1:0] top_plus_1 = top + 1'b1;
wire push_logic;
assign push_logic=push&(count<fifo_depth);

rf_raminfr  rfifo  
        (.clk(clk), 
			.we(push_logic), 
			.top(top), 
			.bottom(bottom), 
			.data_in(data_in), 
			.data_out(data_out)
		); 

always @(posedge clk) // synchronous FIFO
begin
	
	if (fifo_reset) begin
		top		<= #1 0;
		bottom		<= #1 1'b0;
		count		<= #1 0;
		
	end
  else
	begin
		case ({push, pop})
		2'b10 : if (count<fifo_depth)  // overrun condition
			begin
				top       <= #1 top_plus_1;
				count     <= #1 count + 1'b1;
			end
		2'b01 : if(count>0)
			begin
				bottom   <= #1 bottom + 1'b1;
				count	 <= #1 count - 1'b1;
			end
		2'b11 : begin
				bottom   <= #1 bottom + 1'b1;
				top       <= #1 top_plus_1;
		        end
    default: ;
		endcase
	end
end   

always @(posedge clk ) // synchronous FIFO
begin

  if(fifo_reset | reset_status) 
    overrun   <= #1 1'b0;
  else
  if(push & ~pop & (count==fifo_depth))
    overrun   <= #1 1'b1;
end   // always

////empty logic
always @(posedge clk ) // 
begin
  if(fifo_reset | reset_status) 
    read_empty   <= #1 1'b0;
  else
  if(~push & pop & (count==0))  // not receive new data and fifo is empty, should not be read
    read_empty   <= #1 1'b1;
end   // always

endmodule
