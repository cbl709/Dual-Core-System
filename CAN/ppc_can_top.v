/////////处理powerPC与CAN模块的接口////////////

`timescale 1ns / 1ps
module ppc_can_top(
                   clk,
                   addr,
                   can_wr_en,
                   can_rd_en,
                   cpu_write_can_data,
                   cpu_read_can_data,
                 
                   can_rx,
                   can_tx,
                   can_irq
                   
                  );

input        clk;
input  [7:0] addr;
input        can_wr_en;
input        can_rd_en;
input        can_rx;

input  [7:0] cpu_write_can_data;
output       can_tx;
output       can_irq;
output [7:0] cpu_read_can_data;

 can_top can0
( 
  
    .rst_i(),
    .addr(addr),
    .rd_i(can_rd_en),
    .wr_i(can_wr_en),
    .data_in(cpu_write_can_data),
    .data_out(cpu_read_can_data),
    
    .cs_can_i(1'b1), //CAN模块始终使能
    .clk_i(clk),
    .rx_i(can_rx),
    .tx_o(can_tx),
    .bus_off_on(),
    .irq_on(can_irq),
    .clkout_o()

);




endmodule 
