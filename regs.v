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

`define CR2  22'h08  // configuration register
`define SR2  22'h09  // status register
`define TDR2 22'h0a
`define RDR2 22'h0b

`define CR3  22'h0c  // configuration register
`define SR3  22'h0d  // status register
`define TDR3 22'h0e
`define RDR3 22'h0f


module regs (   clk,
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
                
                cr2,
                sr2,
                tdr2,
                rdr2,
                
                cr3,
                sr3,
                tdr3,
                rdr3,
                
                tx0_write,
                rx0_read,
                sr0_read,
                
                tx1_write,
                rx1_read,
                sr1_read,
                
                tx2_write,
                rx2_read,
                sr2_read,
                
                tx3_write,
                rx3_read,
                sr3_read
             );
input clk;
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

input  [31:0] sr2;
input  [31:0] rdr2;
output [31:0] cr2;
output [31:0] tdr2;

input  [31:0] sr3;
input  [31:0] rdr3;
output [31:0] cr3;
output [31:0] tdr3;

output              tx0_write;
output              sr0_read;
output              rx0_read;

output              tx1_write;
output              sr1_read;
output              rx1_read;

output              tx2_write;
output              sr2_read;
output              rx2_read;

output              tx3_write;
output              sr3_read;
output              rx3_read;

assign tx0_write = we&&( addr == `TDR0);
assign sr0_read  = re&&( addr == `SR0);
assign rx0_read  = re&&( addr == `RDR0);

assign tx1_write = we&&( addr == `TDR1);
assign sr1_read  = re&&( addr == `SR1);
assign rx1_read  = re&&( addr == `RDR1);

assign tx2_write = we&&( addr == `TDR2);
assign sr2_read  = re&&( addr == `SR2);
assign rx2_read  = re&&( addr == `RDR2);

assign tx3_write = we&&( addr == `TDR3);
assign sr3_read  = re&&( addr == `SR3);
assign rx3_read  = re&&( addr == `RDR3);


/////////////////registers//////////////////////    
reg [31:0]                              cr0= 32'h000c000;   // configuration register
reg [31:0]                              cr1= 32'h000c000;
reg [31:0]                              cr2= 32'h000c000;   // configuration register
reg [31:0]                              cr3= 32'h000c000;

reg [31:0]                              tdr0 =32'h00000000;
reg [31:0]                              tdr1 =32'h00000000;
reg [31:0]                              tdr2 =32'h00000000;
reg [31:0]                              tdr3 =32'h00000000;

//////////////write registers////////////
always@( posedge clk)
begin
   if(we) begin
   case(addr)
   `CR0 : cr0   <= write_data;
   `CR1 : cr1   <= write_data;
   `CR2 : cr2   <= write_data;
   `CR3 : cr3   <= write_data;
   `TDR0: tdr0  <= write_data;
   `TDR1: tdr1  <= write_data;
   `TDR2: tdr2  <= write_data;
   `TDR3: tdr3  <= write_data;
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
    
    if(cr2[ `CR_RX_RESET ]) //rx_reset
    cr2[ `CR_RX_RESET ]<=0;
  if(cr2[ `CR_TX_RESET ]) //tx_reset
    cr2[ `CR_TX_RESET ]<=0;
    
    if(cr3[ `CR_RX_RESET ]) //rx_reset
    cr3[ `CR_RX_RESET ]<=0;
  if(cr3[ `CR_TX_RESET ]) //tx_reset
    cr3[ `CR_TX_RESET ]<=0;
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
  
  `CR2:  read_data <= cr2;
  `SR2:  read_data <= sr2;
  `TDR2: read_data <= tdr2;
  `RDR2: read_data <= rdr2;
  
  `CR3:  read_data <= cr3;
  `SR3:  read_data <= sr3;
  `TDR3: read_data <= tdr3;
  `RDR3: read_data <= rdr3;
  endcase
  end
end



endmodule
