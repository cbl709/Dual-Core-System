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
       cs_n,
       oe_n,
       we_n,
       rd_wr,
       ebi_data,  // connect to D31~D0
       ebi_addr,  // connect to A31~A8 
       stxA_pad_o, // uart out
       srxA_pad_i,
       intA_o,
       
       stxB_pad_o, // uart out
       srxB_pad_i,
       intB_o,
       
       stxC_pad_o, // uart out
       srxC_pad_i,
       intC_o,
       
       stxD_pad_o, // uart out
       srxD_pad_i,
       intD_o
    );
     
     input       clk;
     input       cs_n;
     input       oe_n;
     input [3:0] we_n;
     input       rd_wr;
     inout [31:0] ebi_data; // connect to D31~D0
     input [23:0]  ebi_addr; // connect to A31~A8
     
     input  srxA_pad_i;
     output intA_o;
     output stxA_pad_o;
     
     input  srxB_pad_i;
     output intB_o;
     output stxB_pad_o;
     
     input  srxC_pad_i;
     output intC_o;
     output stxC_pad_o;
     
     input  srxD_pad_i;
     output intD_o;
     output stxD_pad_o;
     
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
     
     wire [31:0] cr2;
     wire [31:0] sr2;
     wire [31:0] tdr2;
     wire [31:0] rdr2;
     
     wire [31:0] cr3;
     wire [31:0] sr3;
     wire [31:0] tdr3;
     wire [31:0] rdr3;
     
     wire [5:0] addr;
     
     wire tx0_write;
     wire rx0_read;
     wire sr0_read;
     
     wire tx1_write;
     wire rx1_read;
     wire sr1_read;
     
     wire tx2_write;
     wire rx2_read;
     wire sr2_read;
     
     wire tx3_write;
     wire rx3_read;
     wire sr3_read;
     
     
assign write_data    = ebi_data;
assign ebi_data[31:0]= re_o?read_data: 32'hzzzzzzzz;
    
ppc_interface  interface (          .clk(clk),
                                    .cs_n(cs_n),
                                    .oe_n(oe_n),
                                    .we_n(we_n),
                                    .rd_wr(rd_wr),
                                    .ebi_addr(ebi_addr),  // connect to A31~A8
                                    .addr(addr),     // ingnore  A31,A30
                                    .re_o(re_o),
                                    .we_o(we_o)
                    );
                                
regs uart_regs(
                .clk(clk),
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
                
                .cr2(cr2),
                .sr2(sr2),
                .tdr2(tdr2),
                .rdr2(rdr2),
                
                .cr3(cr3),
                .sr3(sr3),
                .tdr3(tdr3),
                .rdr3(rdr3),
                
                .tx0_write(tx0_write),
                .rx0_read(rx0_read),
                .sr0_read(sr0_read),
                
                .tx1_write(tx1_write),
                .rx1_read(rx1_read),
                .sr1_read(sr1_read),
                
                .tx2_write(tx2_write),
                .rx2_read(rx2_read),
                .sr2_read(sr2_read),
                
                .tx3_write(tx3_write),
                .rx3_read(rx3_read),
                .sr3_read(sr3_read)
                );
                
uart uartA(
            .clk(clk),
            .cr(cr0),
            .sr(sr0),
            .tdr(tdr0),
            .rdr(rdr0),
            .tx_write(tx0_write),
            .rx_read(rx0_read),
            .sr_read(sr0_read),
            .srx_pad_i(srxA_pad_i), // uart in
           .stx_pad_o(stxA_pad_o),// uart out
            .int_pad_o(intA_o)
            );
uart uartB(
            .clk(clk),
            .cr(cr1),
            .sr(sr1),
            .tdr(tdr1),
            .rdr(rdr1),
            .tx_write(tx1_write),
            .rx_read(rx1_read),
            .sr_read(sr1_read),
            .srx_pad_i(srxB_pad_i), // uart in
            .stx_pad_o(stxB_pad_o),// uart out
            .int_pad_o(intB_o)
            );
            
uart uartC(
            .clk(clk),
            .cr(cr2),
            .sr(sr2),
            .tdr(tdr2),
            .rdr(rdr2),
            .tx_write(tx2_write),
            .rx_read(rx2_read),
            .sr_read(sr2_read),
            .srx_pad_i(srxC_pad_i), // uart in
            .stx_pad_o(stxC_pad_o),// uart out
            .int_pad_o(intC_o)
            );
            
uart uartD(
            .clk(clk),
            .cr(cr3),
            .sr(sr3),
            .tdr(tdr3),
            .rdr(rdr3),
            .tx_write(tx3_write),
            .rx_read(rx3_read),
            .sr_read(sr3_read),
            .srx_pad_i(srxD_pad_i), // uart in
            .stx_pad_o(stxD_pad_o),// uart out
            .int_pad_o(intD_o)
            );


     

endmodule
