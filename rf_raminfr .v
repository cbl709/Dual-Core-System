`include "uart_defines.v"
////rf fifo 1kB, 11 bits
module rf_raminfr   
        (clk, we, top, bottom, data_in, data_out); 

parameter addr_width = `UART_FIFO_POINTER_W;
parameter data_width = `UART_FIFO_REC_WIDTH; // 
parameter depth = `UART_FIFO_DEPTH;

input clk;   
input we;   
input  [addr_width-1:0] top;    //top
input  [addr_width-1:0] bottom; //bottom  
input  [data_width-1:0] data_in;   
output [data_width-1:0] data_out;

rf_dual_ram rf_dual_ram(
	.addra(top),
	.addrb(bottom),
	.clka(clk),
	.clkb(clk),
	.dina(data_in),
	.doutb(data_out),
	.wea(we));
    
endmodule 

