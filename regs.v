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

`define CR4  22'h10  // configuration register
`define SR4  22'h11  // status register
`define TDR4 22'h12
`define RDR4 22'h13

`define CR5  22'h14  // configuration register
`define SR5  22'h15  // status register
`define TDR5 22'h16
`define RDR5 22'h17


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
                
                cr4,
                sr4,
                tdr4,
                rdr4,
                
                cr5,
                sr5,
                tdr5,
                rdr5,
                
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
                sr3_read,
                
                tx4_write,
                rx4_read,
                sr4_read,
                
                tx5_write,
                rx5_read,
                sr5_read
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

input  [31:0] sr4;
input  [31:0] rdr4;
output [31:0] cr4;
output [31:0] tdr4;

input  [31:0] sr5;
input  [31:0] rdr5;
output [31:0] cr5;
output [31:0] tdr5;

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

output              tx4_write;
output              sr4_read;
output              rx4_read;

output              tx5_write;
output              sr5_read;
output              rx5_read;

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

assign tx4_write = we&&( addr == `TDR4);
assign sr4_read  = re&&( addr == `SR4);
assign rx4_read  = re&&( addr == `RDR4);

assign tx5_write = we&&( addr == `TDR5);
assign sr5_read  = re&&( addr == `SR5);
assign rx5_read  = re&&( addr == `RDR5);


/////////////////registers//////////////////////    
reg [31:0]                              cr0= 32'h000c000;   // configuration register
reg [31:0]                              cr1= 32'h000c000;
reg [31:0]                              cr2= 32'h000c000;   // configuration register
reg [31:0]                              cr3= 32'h000c000;
reg [31:0]                              cr4= 32'h000c000;   // configuration register
reg [31:0]                              cr5= 32'h000c000;

reg [31:0]                              tdr0 =32'h00000000;
reg [31:0]                              tdr1 =32'h00000000;
reg [31:0]                              tdr2 =32'h00000000;
reg [31:0]                              tdr3 =32'h00000000;
reg [31:0]                              tdr4 =32'h00000000;
reg [31:0]                              tdr5 =32'h00000000;

//////////////write registers////////////
always@( posedge clk)
begin
   if(we) begin
   case(addr)
   `CR0 : cr0   <= write_data;
   `CR1 : cr1   <= write_data;
   `CR2 : cr2   <= write_data;
   `CR3 : cr3   <= write_data;
   `CR4 : cr4   <= write_data;
   `CR5 : cr5   <= write_data;
   `TDR0: tdr0  <= write_data;
   `TDR1: tdr1  <= write_data;
   `TDR2: tdr2  <= write_data;
   `TDR3: tdr3  <= write_data;
   `TDR4: tdr4  <= write_data;
   `TDR5: tdr5  <= write_data;
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
    
     if(cr4[ `CR_RX_RESET ]) //rx_reset
    cr4[ `CR_RX_RESET ]<=0;
  if(cr4[ `CR_TX_RESET ]) //tx_reset
    cr4[ `CR_TX_RESET ]<=0;
    
    if(cr5[ `CR_RX_RESET ]) //rx_reset
    cr5[ `CR_RX_RESET ]<=0;
  if(cr5[ `CR_TX_RESET ]) //tx_reset
    cr5[ `CR_TX_RESET ]<=0;
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
  
  `CR4:  read_data <= cr4;
  `SR4:  read_data <= sr4;
  `TDR4: read_data <= tdr4;
  `RDR4: read_data <= rdr4;
  
  `CR5:  read_data <= cr5;
  `SR5:  read_data <= sr5;
  `TDR5: read_data <= tdr5;
  `RDR5: read_data <= rdr5;
  endcase
  end
end



endmodule
