//`timescale 1ns / 1ps

`include "uart_defines.v"

///注意地址是忽略A30,A31的
`define CR0  16'h0000  // configuration register
`define TTR0 16'h0001
`define SR0  16'h0002  // status register
`define TDR0 16'h0003
`define RDR0 16'h0004

`define CR1  16'h0005  // configuration register
`define TTR1 16'h0006
`define SR1  16'h0007  // status register
`define TDR1 16'h0008
`define RDR1 16'h0009

`define CR2  16'h000A  // configuration register
`define TTR2 16'h000B
`define SR2  16'h000C  // status register
`define TDR2 16'h000D
`define RDR2 16'h000E

`define CR3  16'h000F  // configuration register
`define TTR3 16'h0010
`define SR3  16'h0011  // status register
`define TDR3 16'h0012
`define RDR3 16'h0013

`define CR4  16'h0014  // configuration register
`define TTR4 16'h0015
`define SR4  16'h0016  // status register
`define TDR4 16'h0017
`define RDR4 16'h0018

`define CR5  16'h0019  // configuration register
`define TTR5 16'h001A
`define SR5  16'h001B  // status register
`define TDR5 16'h001C
`define RDR5 16'h001D

/////////FPGA IO ////////////
`define FPGA_I0 16'h0100
`define FPGA_I1 16'h0101
`define FPGA_I2 16'h0102
`define FPGA_I3 16'h0103
`define FPGA_I4 16'h0104

`define FPGA_O0 16'h0105
`define FPGA_O1 16'h0106
`define FPGA_O2 16'h0107
`define FPGA_O3 16'h0108
`define FPGA_O4 16'h0109

///////FPGA CAN ///////////
`define CAN_BEGIN   16'h0200
///sja1000 占用32个寄存器
`define CAN0_BEGIN  16'h0200
`define CAN0_END    16'h021f


`define CAN_END     16'h02ff

//////////nand flash controller registers///////
`define PAGE_BEGIN  16'h1000  //4KB的ram地址
`define PAGE_END    16'h13ff  

`define NFADDR0     16'h0300    
`define NFADDR1     16'h0301    
`define NFCR        16'h0302    
`define ID          16'h0303    
`define STATUS      16'h0304   




module regs ( 
                clk,
                addr,
                we,
                re,
                write_data,
                read_data,
                cr0,
                ttr0,
                sr0,
                tdr0,
                rdr0,
                
                cr1,
                ttr1,
                sr1,
                tdr1,
                rdr1,
                
                cr2,
                ttr2,
                sr2,
                tdr2,
                rdr2,
                
                cr3,
                ttr3,
                sr3,
                tdr3,
                rdr3,
                
                cr4,
                ttr4,
                sr4,
                tdr4,
                rdr4,
                
                cr5,
                ttr5,
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
                sr5_read,
                //FPGA IO//////
                fpga_o0,
                fpga_o1,
                fpga_o2,
                fpga_o3,
                fpga_o4,
                
                fpga_i0,
                fpga_i1,
                fpga_i2,
                fpga_i3,
                fpga_i4,
                
                ///NAND Flash///
                done,
                id,
                status,        //flash status register
                cpu_wr_ram_en, //cpu 写FPGA内部ram使能信号,高电平有效
                cpu_wr_ram_addr,//cpu写FPGA内部ram地址
                cpu_wr_ram_data,// 
                cpu_rd_ram_data,
                nfcr,           //nand flash controller register
                nf_addr0,
                nf_addr1
                
                
                
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
output [31:0] ttr0;
output [31:0] tdr0;

input  [31:0] sr1;
output [31:0] ttr1;
input  [31:0] rdr1;
output [31:0] cr1;
output [31:0] tdr1;

input  [31:0] sr2;
output [31:0] ttr2;
input  [31:0] rdr2;
output [31:0] cr2;
output [31:0] tdr2;

input  [31:0] sr3;
output [31:0] ttr3;
input  [31:0] rdr3;
output [31:0] cr3;
output [31:0] tdr3;

input  [31:0] sr4;
output [31:0] ttr4;
input  [31:0] rdr4;
output [31:0] cr4;
output [31:0] tdr4;

input  [31:0] sr5;
output [31:0] ttr5;
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

///FPGA IO   //////
output  [31:0]      fpga_o0;
output  [31:0]      fpga_o1;
output  [31:0]      fpga_o2;
output  [31:0]      fpga_o3;
output  [31:0]      fpga_o4;

input  [31:0]      fpga_i0;
input  [31:0]      fpga_i1;
input  [31:0]      fpga_i2;
input  [31:0]      fpga_i3;
input  [31:0]      fpga_i4;


///nand flash/////
input               done;   //nand flash已经执行完一个指令
input        [31:0] id;     //nand flash ID号
input        [7:0]  status;
input        [31:0] cpu_rd_ram_data;
output       [7:0]  nfcr;
output       [31:0] nf_addr0;
output       [31:0] nf_addr1;
output              cpu_wr_ram_en;
output       [9:0]  cpu_wr_ram_addr;//4kB,1024*32bits 的内部ram大小
output       [31:0] cpu_wr_ram_data;


assign cpu_wr_ram_en   = we&&(addr>=`PAGE_BEGIN)&&(addr<=`PAGE_END);
assign cpu_wr_ram_addr = addr[9:0]; //将CPU读写ram地址PAGE_BEGIN~PAGE_END映?涞?~4KB
assign cpu_wr_ram_data = write_data;
wire   cpu_rd_ram_en;
assign cpu_rd_ram_en   = re&&(addr>=`PAGE_BEGIN)&&(addr<=`PAGE_END);


wire  [15:0] match_addr;
assign match_addr = addr [15:0];


////////UART read/write signal/////////////////
wire tx0_write = we&&( match_addr == `TDR0);
wire cr0_write = we&&( match_addr == `CR0);
wire ttr0_write = we&&( match_addr == `TTR0);
wire sr0_read  = re&&( match_addr == `SR0);
wire rx0_read  = re&&( match_addr == `RDR0);

wire tx1_write = we&&( match_addr == `TDR1);
wire cr1_write = we&&( match_addr == `CR1);
wire ttr1_write = we&&( match_addr == `TTR1);
wire sr1_read  = re&&( match_addr == `SR1);
wire rx1_read  = re&&( match_addr == `RDR1);

wire tx2_write = we&&( match_addr == `TDR2);
wire cr2_write = we&&( match_addr == `CR2);
wire ttr2_write = we&&( match_addr == `TTR2);
wire sr2_read  = re&&( match_addr == `SR2);
wire rx2_read  = re&&( match_addr == `RDR2);

wire tx3_write = we&&( match_addr == `TDR3);
wire cr3_write = we&&( match_addr == `CR3);
wire ttr3_write = we&&( match_addr == `TTR3);
wire sr3_read  = re&&( match_addr == `SR3);
wire rx3_read  = re&&( match_addr == `RDR3);

wire tx4_write = we&&( match_addr == `TDR4);
wire cr4_write = we&&( match_addr == `CR4);
wire ttr4_write = we&&( match_addr == `TTR4);
wire sr4_read  = re&&( match_addr == `SR4);
wire rx4_read  = re&&( match_addr == `RDR4);

wire tx5_write = we&&( match_addr == `TDR5);
wire cr5_write = we&&( match_addr == `CR5);
wire ttr5_write = we&&( match_addr == `TTR5);
wire sr5_read  = re&&( match_addr == `SR5);
wire rx5_read  = re&&( match_addr == `RDR5);

wire fpga_o0_write = we&&(match_addr==`FPGA_O0);
wire fpga_o1_write = we&&(match_addr==`FPGA_O1);
wire fpga_o2_write = we&&(match_addr==`FPGA_O2);
wire fpga_o3_write = we&&(match_addr==`FPGA_O3);
wire fpga_o4_write = we&&(match_addr==`FPGA_O4);

wire nfcr_write       = we&&(match_addr==`NFCR);
wire nf_addr0_write   = we&&(match_addr==`NFADDR0);
wire nf_addr1_write   = we&&(match_addr==`NFADDR1);

/////////////////UART registers//////////////////////    
wire [31:0]                              cr0;
wire [31:0]                              cr1;
wire [31:0]                              cr2;  // configuration register
wire [31:0]                              cr3;
wire [31:0]                              cr4;  // configuration register
wire [31:0]                              cr5;

wire [31:0]                             ttr0;  //默认4个字节时间timeout
wire [31:0]                             ttr1;
wire [31:0]                             ttr2;
wire [31:0]                             ttr3;
wire [31:0]                             ttr4;
wire [31:0]                             ttr5;

wire [31:0]                              tdr0; 
wire [31:0]                              tdr1;
wire [31:0]                              tdr2; 
wire [31:0]                              tdr3;
wire [31:0]                              tdr4;
wire [31:0]                              tdr5;

///////////////FPGA IO registers///////////////
wire  [31:0]                             fpga_o0;
wire  [31:0]                             fpga_o1;
wire  [31:0]                             fpga_o2;
wire  [31:0]                             fpga_o3;
wire  [31:0]                             fpga_o4;

///////////////NAND Flash controller registers//////////////
wire [7:0]                              nfcr; 
wire [31:0]                             nfaddr0; 
wire [31:0]                             nfaddr1;




////////////////write  registers /////////// 
register  #(32,32'h000c000) cr0_reg
            (
            .data_in(write_data),
            .data_out(cr0),
            .we(cr0_write),
            .clk(clk)
            );

register  #(32,32'h000c000) cr1_reg
            (
            .data_in(write_data),
            .data_out(cr1),
            .we(cr1_write),
            .clk(clk)
            );

register  #(32,32'h000c000) cr2_reg
            (
            .data_in(write_data),
            .data_out(cr2),
            .we(cr2_write),
            .clk(clk)
            );
            
register #(32,32'h000c000) cr3_reg 
            (
            .data_in(write_data),
            .data_out(cr3),
            .we(cr3_write),
            .clk(clk)
            );
            
register  #(32,32'h000c000) cr4_reg
            (
            .data_in(write_data),
            .data_out(cr4),
            .we(cr4_write),
            .clk(clk)
            );

register  #(32,32'h000c000) cr5_reg
            (
            .data_in(write_data),
            .data_out(cr5),
            .we(cr5_write),
            .clk(clk)
            );
            
///////ttr registers /////////////
register  #(32,32'h0000104) ttr0_reg
            (
            .data_in(write_data),
            .data_out(ttr0),
            .we(ttr0_write),
            .clk(clk)
            );

register  #(32,32'h0000104) ttr1_reg
            (
            .data_in(write_data),
            .data_out(ttr1),
            .we(ttr1_write),
            .clk(clk)
            );
register  #(32,32'h0000104) ttr2_reg
            (
            .data_in(write_data),
            .data_out(ttr2),
            .we(ttr2_write),
            .clk(clk)
            );
            
register #(32,32'h0000104)  ttr3_reg
            (
            .data_in(write_data),
            .data_out(ttr3),
            .we(ttr3_write),
            .clk(clk)
            );
register #(32,32'h0000104) ttr4_reg
            (
            .data_in(write_data),
            .data_out(ttr4),
            .we(ttr4_write),
            .clk(clk)
            );
register  #(32,32'h0000104) ttr5_reg
            (
            .data_in(write_data),
            .data_out(ttr5),
            .we(ttr5_write),
            .clk(clk)
            );
            
register  #(32,32'h00000000) tdr0_reg
            (
            .data_in(write_data),
            .data_out(tdr0),
            .we(tx0_write),
            .clk(clk)
            );
register  #(32,32'h00000000) tdr1_reg
            (
            .data_in(write_data),
            .data_out(tdr1),
            .we(tx1_write),
            .clk(clk)
            );
register #(32,32'h00000000) tdr2_reg
            (
            .data_in(write_data),
            .data_out(tdr2),
            .we(tx2_write),
            .clk(clk)
            );
register #(32,32'h00000000) tdr3_reg
            (
            .data_in(write_data),
            .data_out(tdr3),
            .we(tx3_write),
            .clk(clk)
            );
register  #(32,32'h00000000) tdr4_reg
            (
            .data_in(write_data),
            .data_out(tdr4),
            .we(tx4_write),
            .clk(clk)
            );
register #(32,32'h00000000) tdr5_reg
            (
            .data_in(write_data),
            .data_out(tdr5),
            .we(tx5_write),
            .clk(clk)
            );
            
register #(32,32'hffffffff) fpga_o0_reg
            (
            .data_in(write_data),
            .data_out(fpga_o0),
            .we(fpga_o0_write),
            .clk(clk)
            );
register  #(32,32'hffffffff) fpga_o1_reg
            (
            .data_in(write_data),
            .data_out(fpga_o1),
            .we(fpga_o1_write),
            .clk(clk)
            );
register  #(32,32'hffffffff) fpga_o2_reg
            (
            .data_in(write_data),
            .data_out(fpga_o2),
            .we(fpga_o2_write),
            .clk(clk)
            );
register #(32,32'hffffffff)  fpga_o3_reg
            (
            .data_in(write_data),
            .data_out(fpga_o3),
            .we(fpga_o3_write),
            .clk(clk)
            );
register  #(32,32'hffffffff) fpga_o4_reg
            (
            .data_in(write_data),
            .data_out(fpga_o4),
            .we(fpga_o4_write),
            .clk(clk)
            );
register  #(32,32'hffffffff) fpga_o5_reg
            (
            .data_in(write_data),
            .data_out(fpga_o5),
            .we(fpga_o5_write),
            .clk(clk)
            );
            
register #(8,8'h00)  nfcr_reg
            (
            .data_in(write_data),
            .data_out(nfcr),
            .we(nfcr_write),
            .clk(clk)
            );
            
register #(32,32'h00000000) nf_addr0_reg
            (
            .data_in(write_data),
            .data_out(nf_addr0),
            .we(nf_addr0_write),
            .clk(clk)
            );

register  #(32,32'h00000000) nf_addr1_reg
            (
            .data_in(write_data),
            .data_out(nf_addr1),
            .we(nf_addr1_write),
            .clk(clk)
            );

///////////read registers/////////////////
reg  [31:0] read_data_in=32'h00000000;
wire [31:0] read_data;
reg         re_d=0;

always@(posedge clk)
 re_d <= re;

register  #(32,32'h00000000) read_data_reg
            (
            .data_in(read_data_in),
            .data_out(read_data),
            .we(re_d),
            .clk(clk)
            );

always@ (cr0 or cr1 or cr2 or cr3 or cr4 or cr5 or
         sr0 or sr1 or sr2 or sr3 or sr4 or sr5 or
         tdr0 or tdr1 or tdr2 or tdr3 or tdr4 or tdr5 or
         rdr0 or rdr1 or rdr2 or rdr3 or rdr4 or rdr5 or
         fpga_o0 or fpga_o1 or fpga_o2 or fpga_o3 or fpga_o4 or
         fpga_i0 or fpga_i1 or fpga_i2 or fpga_i3 or fpga_i4 or
         nfcr    or nfaddr0 or nfaddr1)
begin
  if(re) begin
  case(match_addr)
  
  //////////UART////////////
  `CR0:  read_data_in <= cr0;
  `SR0:  read_data_in <= sr0;
  `TDR0: read_data_in <= tdr0;
  `RDR0: read_data_in <= rdr0;
  
  `CR1:  read_data_in <= cr1;
  `SR1:  read_data_in <= sr1;
  `TDR1: read_data_in <= tdr1;
  `RDR1: read_data_in <= rdr1;
  
  `CR2:  read_data_in <= cr2;
  `SR2:  read_data_in <= sr2;
  `TDR2: read_data_in <= tdr2;
  `RDR2: read_data_in <= rdr2;
  
  `CR3:  read_data_in <= cr3;
  `SR3:  read_data_in <= sr3;
  `TDR3: read_data_in <= tdr3;
  `RDR3: read_data_in <= rdr3;
  
  `CR4:  read_data_in <= cr4;
  `SR4:  read_data_in <= sr4;
  `TDR4: read_data_in <= tdr4;
  `RDR4: read_data_in <= rdr4;
  
  `CR5:  read_data_in <= cr5;
  `SR5:  read_data_in <= sr5;
  `TDR5: read_data_in <= tdr5;
  `RDR5: read_data_in <= rdr5;
  ///FPGA IO///////////////////
  `FPGA_O0: read_data_in <= fpga_o0; 
  `FPGA_O1: read_data_in <= fpga_o1;
  `FPGA_O2: read_data_in <= fpga_o2; 
  `FPGA_O3: read_data_in <= fpga_o3; 
  `FPGA_O4: read_data_in <= fpga_o4;
  
  `FPGA_I0: read_data_in <= fpga_i0; 
  `FPGA_I1: read_data_in <= fpga_i1;
  `FPGA_I2: read_data_in <= fpga_i2; 
  `FPGA_I3: read_data_in <= fpga_i3; 
  `FPGA_I4: read_data_in <= fpga_i4;
  
  ////NAND Flash Controller///
  `NFCR:     read_data_in <= nfcr;
  `NFADDR0:  read_data_in <= nfaddr0;
  `ID:       read_data_in <= id;
  `STATUS:   read_data_in <= status;
  endcase
  
  if(cpu_rd_ram_en) //cpu读取FPGA内部ram数据
     read_data_in       <= cpu_rd_ram_data;
     
  end
  
 
  
end



endmodule
