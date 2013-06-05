`include "c:/uart_defines.v"
//Following is the Verilog code for a dual-port RAM with asynchronous read. 
module raminfr   
        (clk, we, a, dpra, di, dpo); 

parameter addr_width = `UART_FIFO_POINTER_W;
parameter data_width = 8;
parameter depth = `UART_FIFO_DEPTH;

input clk;   
input we;   
input  [addr_width-1:0] a;    //top
input  [addr_width-1:0] dpra; //bottom  
input  [data_width-1:0] di;   
//output [data_width-1:0] spo;   
output [data_width-1:0] dpo;   
reg    [data_width-1:0] ram [depth-1:0]; //定义ram深度16字节

wire [data_width-1:0] dpo;
wire  [data_width-1:0] di;   
wire  [addr_width-1:0] a;   
wire  [addr_width-1:0] dpra;   
 
  always @(posedge clk) begin   
    if (we)   
      ram[a] <= di;   
  end   
//  assign spo = ram[a];   
  assign dpo = ram[dpra];   
endmodule 

