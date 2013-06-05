`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:55:26 10/25/2012 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
	  clk,
	  rst_n,
     cs_n,
     oe_n,
     we_n,
     rd_wr,
     ebi_data, // connect to D31~D0
	  ebi_addr,  // connect to A31~A27 
	  stx0_pad_o, // uart out
	  srx0_pad_i,
	  int0_o,
	  stx1_pad_o, // uart out
	  srx1_pad_i,
	  int1_o
    );
	 
	 input clk;
	 input rst_n;
    input cs_n;
    input oe_n;
    input [3:0] we_n;
    input rd_wr;
    inout [31:0] ebi_data; // connect to D31~D0
	 input [7:0] ebi_addr; // connect to A31~A27
	 
	 input  srx0_pad_i;
	 output int0_o;
	 output stx0_pad_o;
	 
	 input  srx1_pad_i;
	 output int1_o;
	 output stx1_pad_o;
	 
	 wire [31:0] write_data;
	 wire [31:0] read_data;
	 wire re_o;
	 wire we_o;
	 
	 wire [31:0] cr0;
	 wire [31:0] sr0;
	 wire [31:0] tdr0;
	 wire [31:0] rdr0;
	 
	 wire [31:0] cr1;
	 wire [31:0] sr1;
	 wire [31:0] tdr1;
	 wire [31:0] rdr1;
	 
	 wire [5:0] addr;
	 
	 wire tx0_write;
	 wire rx0_read;
	 wire	sr0_read;
	 wire tx1_write;
	 wire rx1_read;
	 wire	sr1_read;
	 
	 
assign write_data= ebi_data;
assign ebi_data[31:0]= re_o?read_data: 32'hzzzzzzzz;
    
ppc_interface  inter (     .clk(clk),
									.rst_n(rst_n),
									.cs_n(cs_n),
									.oe_n(oe_n),
									.we_n(we_n),
									.rd_wr(rd_wr),
									.ebi_addr(ebi_addr),  // connect to A31~A27
									.addr(addr),     // ingnore  A31,A30
									.re_o(re_o),
									.we_o(we_o)
									
								);
								
regs uart_regs(
				.clk(clk),
				.rst_n(rst_n),
				.addr(addr),
				.we(we_o),
				.re(re_o),
				.write_data(write_data),
				.read_data(read_data),
				.cr0(cr0),
				.sr0(sr0),
				.tdr0(tdr0),
				.rdr0(rdr0),
				.cr1(cr1),
				.sr1(sr1),
				.tdr1(tdr1),
				.rdr1(rdr1),
				.tx0_write(tx0_write),
				.rx0_read(rx0_read),
			   .sr0_read(sr0_read),
			   .tx1_write(tx1_write),
				.rx1_read(rx1_read),
			   .sr1_read(sr1_read)
				);
				
uart uart0(
			.clk(clk),
			.rst_n(rst_n),
			.cr(cr0),
			.sr(sr0),
			.tdr(tdr0),
			.rdr(rdr0),
			.tx_write(tx0_write),
			.rx_read(rx0_read),
			.sr_read(sr0_read),
			.srx_pad_i(srx0_pad_i), // uart in
		   .stx_pad_o(stx0_pad_o),// uart out
			.int_pad_o(int0_o)
			);

uart uart1(
			.clk(clk),
			.rst_n(rst_n),
			.cr(cr1),
			.sr(sr1),
			.tdr(tdr1),
			.rdr(rdr1),
			.tx_write(tx1_write),
			.rx_read(rx1_read),
			.sr_read(sr1_read),
			.srx_pad_i(srx1_pad_i), // uart in
		   .stx_pad_o(stx1_pad_o),// uart out
			.int_pad_o(int1_o)
			);
	 
	 

endmodule
