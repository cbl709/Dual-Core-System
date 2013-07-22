`include "uart_defines.v"
//tf fifo: 1kB, 8bits
module tf_raminfr   
        (clk, we, top, bottom, data_in, data_out); 

parameter addr_width = `UART_FIFO_POINTER_W;
parameter data_width = `UART_FIFO_WIDTH;  //8 bits
parameter depth = `UART_FIFO_DEPTH;

input clk;   
input we;   
input  [addr_width-1:0] top;    //top
input  [addr_width-1:0] bottom; //bottom  
input  [data_width-1:0] data_in;   
output [data_width-1:0] data_out;   
//reg    [data_width-1:0] ram [depth-1:0]; //

wire [data_width-1:0]   dout;
reg  [data_width-1:0]   data_out;
tf_dual_ram tf_dual_ram(
	.addra(top),
	.addrb(bottom),
	.clka(clk),
	.clkb(clk),
	.dina(data_in),
	.doutb(dout),
	.wea(we));
    
always@(posedge clk)
  data_out<= dout;

endmodule 

