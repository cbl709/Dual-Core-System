//`timescale 1ns / 1ps

`include "uart_defines.v"

module regs ( clk,
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
input [5:0] addr;
input we;
input re;
input [31:0] write_data;
output [31:0] read_data;
input [31:0] sr0;
input [31:0] rdr0;
output [31:0] cr0;
output [31:0] tdr0;
input [31:0] sr1;
input [31:0] rdr1;
output [31:0] cr1;
output [31:0] tdr1;

output				tx0_write;
output			    sr0_read;
output			    tx1_write;
output			    sr1_read;
output             rx0_read;
output 				 rx1_read;
/////////////////registers//////////////////////	
reg [31:0]                        		cr0;   // configuration register
reg [31:0]								      cr1;

reg [31:0]								tdr0;
reg [31:0]								tdr1;


/////////////write registers///////////////////
wire cr0_write;   //signal to enable write CR 
wire tx0_write;
assign cr0_write = we&&( addr == `CR0 );
assign tx0_write = we&&( addr == `TDR0);

wire cr1_write;   //signal to enable write CR 
wire tx1_write;
assign cr1_write = we&&( addr == `CR1 );
assign tx1_write = we&&( addr == `TDR1);

always@( posedge clk or negedge rst_n)
begin
  if(~rst_n) begin
  cr0<= 32'h0000c000;
  tdr0<= 32'h00000000;
  cr1<= 32'h0000c000;
  tdr1<= 32'h00000000;
  end
  else begin
 
  if(cr0_write)
    cr0<= write_data;
  if(cr1_write)
    cr1<= write_data;
///rx_reset and tx_reset will be clear after they are set for a clock
  if(cr0[ `CR_RX_RESET ]) //rx_reset
    cr0[ `CR_RX_RESET ]<=0;
  if(cr0[ `CR_TX_RESET ]) //tx_reset
    cr0[ `CR_TX_RESET ]<=0;
  if(cr1[ `CR_RX_RESET ]) //rx_reset
    cr1[ `CR_RX_RESET ]<=0;
  if(cr1[ `CR_TX_RESET ]) //tx_reset
    cr1[ `CR_TX_RESET ]<=0;
  
	
  if(tx0_write)
    tdr0<= write_data;
  if(tx1_write)
    tdr1<= write_data;
  end//end of else   
end

///////////read registers///////////////////
wire cr0_read;
wire sr0_read;
wire tx0_read;
wire rx0_read;

wire cr1_read;
wire sr1_read;
wire tx1_read;
wire rx1_read;

reg [31:0] read_data;
reg read_state;

assign cr0_read = re&&(addr== `CR0);
assign sr0_read = re&&(addr == `SR0);
assign tx0_read = re&&(addr == `TDR0);
assign rx0_read = re&&(addr == `RDR0);

assign cr1_read = re&&(addr== `CR1);
assign sr1_read = re&&(addr == `SR1);
assign tx1_read = re&&(addr == `TDR1);
assign rx1_read = re&&(addr == `RDR1);

always@(cr0_read or sr0_read or tx0_read or rx0_read or cr1_read or sr1_read or tx1_read or rx1_read) 
begin
        case({cr0_read,sr0_read,tx0_read,rx0_read,cr1_read,sr1_read,tx1_read,rx1_read})
			8'b10000000: read_data= cr0;
			8'b01000000: read_data= sr0;
			8'b00100000: read_data= tdr0;
			8'b00010000: read_data= rdr0;
			8'b00001000: read_data= cr1;
			8'b00000100: read_data= sr1;
			8'b00000010: read_data= tdr1;
			8'b00000001: read_data= rdr1;
			default: read_data=32'hffff0000;
		 endcase
end		

endmodule
