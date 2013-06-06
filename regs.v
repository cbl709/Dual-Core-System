//`timescale 1ns / 1ps

`include "uart_defines.v"

`define CR0  22'h00  // configuration register
`define SR0  22'h01  // status register
`define TDR0 22'h02
`define RDR0 22'h03
`define CR1  22'h04  // configuration register
`define SR1  22'h05  // status register
`define TDR1 22'h06
`define RDR1 22'h07

module regs (   clk,
                rst_n,
                addr,
                we,
                re,
                write_data,
                read_data,
                cr0,
                sr0,
                tdr0,
                rdr0,
                cr1,
                sr1,
                tdr1,
                rdr1,
                tx0_write,
                rx0_read,
                sr0_read,
                tx1_write,
                rx1_read,
                sr1_read
             );
input clk;
input rst_n;
input [21:0] addr;
input we;
input re;
input  [31:0] write_data;
output [31:0] read_data;
input  [31:0] sr0;
input  [31:0] rdr0;
output [31:0] cr0;
output [31:0] tdr0;
input  [31:0] sr1;
input  [31:0] rdr1;
output [31:0] cr1;
output [31:0] tdr1;

output              tx0_write;
output              sr0_read;
output              tx1_write;
output              sr1_read;
output              rx0_read;
output              rx1_read;

assign tx0_write = we&&( addr == `TDR0);
assign tx1_write = we&&( addr == `TDR1);
assign sr0_read  = re&&( addr == `SR0);
assign sr1_read  = re&&( addr == `SR1);
assign rx0_read  = re&&( addr == `RDR0);
assign rx1_read  = re&&( addr == `RDR1);


/////////////////registers//////////////////////    
reg [31:0]                              cr0= 32'h000c000;   // configuration register
reg [31:0]                              cr1= 32'h000c000;

reg [31:0]                              tdr0 =32'h00000000;
reg [31:0]                              tdr1 =32'h00000000;

//////////////write registers////////////
always@( posedge clk)
begin
   if(we) begin
   case(addr)
   `CR0 : cr0   <= write_data;
   `CR1 : cr1   <= write_data;
   `TDR0: tdr0  <= write_data;
   `TDR1: tdr1  <= write_data;
   endcase
   end
   ///rx_reset and tx_reset will be clear after they are set for a clock
  if(cr0[ `CR_RX_RESET ]) //rx_reset
    cr0[ `CR_RX_RESET ]<=0;
  if(cr0[ `CR_TX_RESET ]) //tx_reset
    cr0[ `CR_TX_RESET ]<=0;
  if(cr1[ `CR_RX_RESET ]) //rx_reset
    cr1[ `CR_RX_RESET ]<=0;
  if(cr1[ `CR_TX_RESET ]) //tx_reset
    cr1[ `CR_TX_RESET ]<=0;
end

///////////read registers/////////////////
reg [31:0] read_data=32'h00000000;
always@(re or addr)
begin
  if(re) begin
  case(addr)
  `CR0:  read_data <= cr0;
  `SR0:  read_data <= sr0;
  `TDR0: read_data <= tdr0;
  `RDR0: read_data <= rdr0;
  
  `CR1:  read_data <= cr1;
  `SR1:  read_data <= sr1;
  `TDR1: read_data <= tdr1;
  `RDR1: read_data <= rdr1;
  endcase
  end
end



endmodule
