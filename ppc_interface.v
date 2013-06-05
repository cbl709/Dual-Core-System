`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:43:22 10/25/2012 
// Design Name: 
// Module Name:    ppc_interface 
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
module ppc_interface(
	  clk,
	  rst_n,
     cs_n,
     oe_n,
     we_n,
     rd_wr,
	  ebi_addr,  // connect to A31~A27
	  addr,     // ingnore  A31,A30
     re_o,
     we_o
    );
	 
//////IO///////////////////
    input clk;
	 input rst_n;
    input cs_n;
    input oe_n;
    input [3:0] we_n;
    input rd_wr;
	 input [7:0] ebi_addr; // connect to A31~A27
	 output [5:0] addr;     // ingnore  A31,A30
    output re_o;
    output we_o;
/////////////////////////////	  

wire  [5:0] addr;	

 
wire re_o;
wire we_o;
	 

assign we_o =  ~rd_wr & ~cs_n&(we_n!=4'b1111); //&&(~we_n); //& wre ; //WE for registers	
assign re_o = rd_wr & ~cs_n&(we_n==4'b1111)  ; //RE for registers

assign addr[5:0]=ebi_addr[7:2];
	  

endmodule
