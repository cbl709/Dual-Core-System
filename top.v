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
       intD_o,
       
       stxE_pad_o, // uart out
       srxE_pad_i,
       intE_o,
       
       stxF_pad_o, // uart out
       srxF_pad_i,
       intF_o,
       
       /////NAND Flash controller
       dio,
       nf_cle,
       nf_ale,
       nf_ce_n,
       nf_re_n,
       nf_we_n,
         r
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
     
     input  srxE_pad_i;
     output intE_o;
     output stxE_pad_o;
     
     input  srxF_pad_i;
     output intF_o;
     output stxF_pad_o;
     
     ////NAND Flash controller
     output               nf_cle;
     output               nf_ale;
     output               nf_ce_n;
     output               nf_re_n;
     output               nf_we_n;
     inout      [7:0]     dio;
     input                r;

     
     
     wire [31:0] write_data;
     wire [31:0] read_data;
     wire re_o;
     wire we_o;
     
     wire [31:0] cr0;
     wire [31:0] ttr0;
     wire [31:0] sr0;
     wire [31:0] tdr0;
     wire [31:0] rdr0;
     
     wire [31:0] cr1;
     wire [31:0] ttr1;
     wire [31:0] sr1;
     wire [31:0] tdr1;
     wire [31:0] rdr1;
     
     wire [31:0] cr2;
     wire [31:0] ttr2;
     wire [31:0] sr2;
     wire [31:0] tdr2;
     wire [31:0] rdr2;
     
     wire [31:0] cr3;
     wire [31:0] ttr3;
     wire [31:0] sr3;
     wire [31:0] tdr3;
     wire [31:0] rdr3;
     
     wire [31:0] cr4;
     wire [31:0] ttr4;
     wire [31:0] sr4;
     wire [31:0] tdr4;
     wire [31:0] rdr4;
     
     wire [31:0] cr5;
     wire [31:0] ttr5;
     wire [31:0] sr5;
     wire [31:0] tdr5;
     wire [31:0] rdr5;
     
     wire [21:0] addr;
     
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
     
     wire tx4_write;
     wire rx4_read;
     wire sr4_read;
     
     wire tx5_write;
     wire rx5_read;
     wire sr5_read;
     
     /////////////NAND Flash controller////////////////
     wire                cpu_wr_ram_en;
     wire       [9:0]    cpu_wr_ram_addr;//4kB,1024*32bits 的内部ram大小
     wire       [31:0]   cpu_wr_ram_data;
     wire      [31:0]    cpu_rd_ram_data;

     wire       [31:0]   flash_wr_ram_data;
     wire                flash_wr_ram_en;
     wire       [9:0]    flash_wr_ram_addr;
     wire      [31:0]    flash_rd_ram_data;
     
     wire      [31:0]    nf_addr0;
     wire      [31:0]    nf_addr1;
     wire      [7:0]     nfcr;
     wire      [31:0]    id;
      wire      [7:0]     status;
     
     
////cpu and fpga inout port     
assign write_data    = ebi_data;
assign ebi_data[31:0]= re_o?read_data: 32'hzzzzzzzz;

///fpga and flash inout port
wire   [7:0] write_flash;
wire  [7:0] read_flash;
wire        read_flash_en;
wire        done;

assign           read_flash= dio;
assign           dio=read_flash_en? 8'hzz:write_flash;


    
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
                                
regs regs(
                .clk(clk),
                .addr(addr),
                .we(we_o),
                .re(re_o),
                .write_data(write_data),
                .read_data(read_data),
                .cr0(cr0),
                .ttr0(ttr0),
                .sr0(sr0),
                .tdr0(tdr0),
                .rdr0(rdr0),
                
                .cr1(cr1),
                .ttr1(ttr1),
                .sr1(sr1),
                .tdr1(tdr1),
                .rdr1(rdr1),
                
                .cr2(cr2),
                .ttr2(ttr2),
                .sr2(sr2),
                .tdr2(tdr2),
                .rdr2(rdr2),
                
                .cr3(cr3),
                .ttr3(ttr3),
                .sr3(sr3),
                .tdr3(tdr3),
                .rdr3(rdr3),
                
                .cr4(cr4),
                .ttr4(ttr4),
                .sr4(sr4),
                .tdr4(tdr4),
                .rdr4(rdr4),
                
                .cr5(cr5),
                .ttr5(ttr5),
                .sr5(sr5),
                .tdr5(tdr5),
                .rdr5(rdr5),
                
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
                .sr3_read(sr3_read),
                
                .tx4_write(tx4_write),
                .rx4_read(rx4_read),
                .sr4_read(sr4_read),
                
                .tx5_write(tx5_write),
                .rx5_read(rx5_read),
                .sr5_read(sr5_read),
                ////////nand flash////
                .done(done),
                .id(id),
                     .status(status),
                .cpu_wr_ram_en(cpu_wr_ram_en), //cpu 写FPGA内部ram使能信号,高电平有效
                .cpu_wr_ram_addr(cpu_wr_ram_addr),//cpu写FPGA内部ram地址
                .cpu_wr_ram_data(cpu_wr_ram_data),// 
                .cpu_rd_ram_data(cpu_rd_ram_data),
                .nfcr(nfcr),            //nand flash controller register
                .nf_addr0(nf_addr0),
                .nf_addr1(nf_addr1)
                );


                
nand_flash_top  nand_flash_top(
                        .clk(clk),
                        .cpu_wr_ram_en  (cpu_wr_ram_en),
                        .cpu_wr_ram_addr(cpu_wr_ram_addr),//4kB,1024*32bits                      
                        .cpu_wr_ram_data(cpu_wr_ram_data),
                        .cpu_rd_ram_data(cpu_rd_ram_data),
                        
                        .nf_addr0(nf_addr0),
                        .nf_addr1(nf_addr1),
                        .nfcr(nfcr),
                        .read_flash(read_flash),
                        .write_flash(write_flash),
                        .read_flash_en(read_flash_en),
                        
                        .nf_cle(nf_cle),
                        .nf_ale(nf_ale),
                        .nf_ce_n(nf_ce_n),
                        .nf_re_n(nf_re_n),
                        .nf_we_n(nf_we_n),
                        .r(r),
                        
                        .id(id),
                                .status(status),
                                
                        .done(done)
                      );
                
uart uartA(
            .clk(clk),
            .cr(cr0),
            .ttr(ttr0),
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
            .ttr(ttr1),
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
            .ttr(ttr2),
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
            .ttr(ttr3),
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
            
uart uartE(
            .clk(clk),
            .cr(cr4),
            .ttr(ttr4),
            .sr(sr4),
            .tdr(tdr4),
            .rdr(rdr4),
            .tx_write(tx4_write),
            .rx_read(rx4_read),
            .sr_read(sr4_read),
            .srx_pad_i(srxE_pad_i), // uart in
            .stx_pad_o(stxE_pad_o),// uart out
            .int_pad_o(intE_o)
            );
            
uart uartF(
            .clk(clk),
            .cr(cr5),
            .ttr(ttr5),
            .sr(sr5),
            .tdr(tdr5),
            .rdr(rdr5),
            .tx_write(tx5_write),
            .rx_read(rx5_read),
            .sr_read(sr5_read),
            .srx_pad_i(srxF_pad_i), // uart in
            .stx_pad_o(stxF_pad_o),// uart out
            .int_pad_o(intF_o)
            );


     

endmodule
