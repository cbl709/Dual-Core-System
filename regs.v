//`timescale 1ns / 1ps

`include "./uart/uart_defines.v"

///注意地址是忽略A30,A31的
`define CR0  22'h0000  // configuration register
`define TTR0 22'h0001
`define SR0  22'h0002  // status register
`define TDR0 22'h0003
`define RDR0 22'h0004

`define CR1  22'h0005  // configuration register
`define TTR1 22'h0006
`define SR1  22'h0007  // status register
`define TDR1 22'h0008
`define RDR1 22'h0009

`define CR2  22'h000A  // configuration register
`define TTR2 22'h000B
`define SR2  22'h000C  // status register
`define TDR2 22'h000D
`define RDR2 22'h000E

`define CR3  22'h000F  // configuration register
`define TTR3 22'h0010
`define SR3  22'h0011  // status register
`define TDR3 22'h0012
`define RDR3 22'h0013

`define CR4  22'h0014  // configuration register
`define TTR4 22'h0015
`define SR4  22'h0016  // status register
`define TDR4 22'h0017
`define RDR4 22'h0018

`define CR5  22'h0019  // configuration register
`define TTR5 22'h001A
`define SR5  22'h001B  // status register
`define TDR5 22'h001C
`define RDR5 22'h001D

`define CR6  22'h001F  // configuration register
`define TTR6 22'h0020
`define SR6  22'h0021  // status register
`define TDR6 22'h0022
`define RDR6 22'h0023

`define CR7  22'h0024  // configuration register
`define TTR7 22'h0025
`define SR7  22'h0026  // status register
`define TDR7 22'h0027
`define RDR7 22'h0028

`define CR8  22'h0029  // configuration register
`define TTR8 22'h002A
`define SR8  22'h002B  // status register
`define TDR8 22'h002C
`define RDR8 22'h002D

`define CR9  22'h002F  // configuration register
`define TTR9 22'h0030
`define SR9  22'h0031  // status register
`define TDR9 22'h0032
`define RDR9 22'h0033

`define CR10  22'h0034  // configuration register
`define TTR10 22'h0035
`define SR10  22'h0036  // status register
`define TDR10 22'h0037
`define RDR10 22'h0038

`define CR11  22'h0039  // configuration register
`define TTR11 22'h003A
`define SR11  22'h003B  // status register
`define TDR11 22'h003C
`define RDR11 22'h003D

/////////FPGA IO////////////////
`define FPGA_O0   22'h0100
`define FPGA_O1   22'h0101
`define FPGA_O2   22'h0102

`define FPGA_I0   22'h0103
`define FPGA_I1   22'h0104
`define FPGA_I2   22'h0105

////////FPGA CAN////////////////
`define CAN0_BEGIN 22'h0200
`define CAN0_END   22'h021f

//////////nand flash controller registers///////
`define PAGE_BEGIN  22'h1000  //4KB的ram地址
`define PAGE_END    22'h13ff  

`define NFADDR0     22'h0300    
`define NFADDR1     22'h0301    
`define NFCR        22'h0302    
`define ID          22'h0303    
`define STATUS      22'h0304   






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
                
                cr6,
                ttr6,
                sr6,
                tdr6,
                rdr6,
                
                cr7,
                ttr7,
                sr7,
                tdr7,
                rdr7,
                
                cr8,
                ttr8,
                sr8,
                tdr8,
                rdr8,
                
                cr9,
                ttr9,
                sr9,
                tdr9,
                rdr9,
                
                cr10,
                ttr10,
                sr10,
                tdr10,
                rdr10,
                
                cr11,
                ttr11,
                sr11,
                tdr11,
                rdr11,
                
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
                
                tx6_write,
                rx6_read,
                sr6_read,
                
                tx7_write,
                rx7_read,
                sr7_read,
                
                tx8_write,
                rx8_read,
                sr8_read,
                
                tx9_write,
                rx9_read,
                sr9_read,
                
                tx10_write,
                rx10_read,
                sr10_read,
                
                tx10_write,
                rx10_read,
                sr10_read,
                
                tx11_write,
                rx11_read,
                sr11_read,
                
                
                ///FPGA IO/////
                fpga_o0,
                fpga_o1,
                fpga_o2,
                
                //FPGA CAN////
                can0_rd_en,
                can0_wr_en,
                cpu_read_can0_data,
             
               
                fpga_i0,
                fpga_i1,
                fpga_i2,
                
                ///NAND Flash///
                done,
                id,
                status,        //flash status register
                cpu_wr_ram_en, //cpu 写FPGA内部ram使能信号,高电平有效
                cpu_wr_ram_addr,//cpu写FPGA内部ram地址
                cpu_wr_ram_data,// 
                cpu_rd_ram_data,
                nfcr,           //nand flash controller register
                nfaddr0,
                nfaddr1
                
                
                
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

input  [31:0] sr6;
input  [31:0] rdr6;
output [31:0] cr6;
output [31:0] ttr6;
output [31:0] tdr6;

input  [31:0] sr7;
output [31:0] ttr7;
input  [31:0] rdr7;
output [31:0] cr7;
output [31:0] tdr7;

input  [31:0] sr8;
output [31:0] ttr8;
input  [31:0] rdr8;
output [31:0] cr8;
output [31:0] tdr8;

input  [31:0] sr9;
output [31:0] ttr9;
input  [31:0] rdr9;
output [31:0] cr9;
output [31:0] tdr9;

input  [31:0] sr10;
output [31:0] ttr10;
input  [31:0] rdr10;
output [31:0] cr10;
output [31:0] tdr10;

input  [31:0] sr11;
output [31:0] ttr11;
input  [31:0] rdr11;
output [31:0] cr11;
output [31:0] tdr11;



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

output              tx6_write;
output              sr6_read;
output              rx6_read;

output              tx7_write;
output              sr7_read;
output              rx7_read;

output              tx8_write;
output              sr8_read;
output              rx8_read;

output              tx9_write;
output              sr9_read;
output              rx9_read;

output              tx10_write;
output              sr10_read;
output              rx10_read;

output              tx11_write;
output              sr11_read;
output              rx11_read;

///FPGA IO//////////////////
 output [31:0]             fpga_o0;
 output [31:0]             fpga_o1;
 output [31:0]             fpga_o2;
 
 input  [31:0]             fpga_i0;
 input  [31:0]             fpga_i1;
 input  [31:0]             fpga_i2;
 
 
 ////FPGA CAN/////////////
 output  can0_rd_en;
 output  can0_wr_en;
 input  [7:0] cpu_read_can0_data;
 assign can0_rd_en= re&&(addr>=`CAN0_BEGIN)&&(addr<=`CAN0_END);
 assign can0_wr_en= we&&(addr>=`CAN0_BEGIN)&&(addr<=`CAN0_END);
 
///nand flash/////
input               done;   //nand flash已经执行完一个指令
input        [31:0] id;     //nand flash ID号
input        [7:0]  status;
input        [31:0] cpu_rd_ram_data;
output       [7:0]  nfcr;
output       [31:0] nfaddr0;
output       [31:0] nfaddr1;
output              cpu_wr_ram_en;
output       [9:0]  cpu_wr_ram_addr;//4kB,1024*32bits 的内部ram大小
output       [31:0] cpu_wr_ram_data;


assign cpu_wr_ram_en   = we&&(addr>=`PAGE_BEGIN)&&(addr<=`PAGE_END);
assign cpu_wr_ram_addr = addr[9:0]; //将CPU读写ram地址PAGE_BEGIN~PAGE_END映射到0~4KB
assign cpu_wr_ram_data = write_data;
wire   cpu_rd_ram_en;
assign cpu_rd_ram_en   = re&&(addr>=`PAGE_BEGIN)&&(addr<=`PAGE_END);


////////UART read/write signal/////////////////
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

assign tx6_write = we&&( addr == `TDR6);
assign sr6_read  = re&&( addr == `SR6);
assign rx6_read  = re&&( addr == `RDR6);

assign tx7_write = we&&( addr == `TDR7);
assign sr7_read  = re&&( addr == `SR7);
assign rx7_read  = re&&( addr == `RDR7);

assign tx8_write = we&&( addr == `TDR8);
assign sr8_read  = re&&( addr == `SR8);
assign rx8_read  = re&&( addr == `RDR8);

assign tx9_write = we&&( addr == `TDR9);
assign sr9_read  = re&&( addr == `SR9);
assign rx9_read  = re&&( addr == `RDR9);

assign tx10_write = we&&( addr == `TDR10);
assign sr10_read  = re&&( addr == `SR10);
assign rx10_read  = re&&( addr == `RDR10);

assign tx11_write = we&&( addr == `TDR11);
assign sr11_read  = re&&( addr == `SR11);
assign rx11_read  = re&&( addr == `RDR11);

/////////////////UART registers//////////////////////    
reg [31:0]                              cr0= 32'h00000300;   // configuration register
reg [31:0]                              cr1= 32'h00000300;
reg [31:0]                              cr2= 32'h00000300;   // configuration register
reg [31:0]                              cr3= 32'h00000300;
reg [31:0]                              cr4= 32'h00000300;   // configuration register
reg [31:0]                              cr5= 32'h00000300;
reg [31:0]                              cr6= 32'h00000300;   // configuration register
reg [31:0]                              cr7= 32'h00000300;
reg [31:0]                              cr8= 32'h00000300;   // configuration register
reg [31:0]                              cr9= 32'h00000300;
reg [31:0]                              cr10=32'h00000300;   // configuration register
reg [31:0]                              cr11=32'h00000300;

reg [31:0]                             ttr0= 32'h00000104;   //默认4个字节时间timeout，trigger level默认为1
reg [31:0]                             ttr1= 32'h00000104;
reg [31:0]                             ttr2= 32'h00000104;
reg [31:0]                             ttr3= 32'h00000104;
reg [31:0]                             ttr4= 32'h00000104;
reg [31:0]                             ttr5= 32'h00000104;
reg [31:0]                             ttr6= 32'h00000104;   //默认4个字节时间timeout，trigger level默认为1
reg [31:0]                             ttr7= 32'h00000104;
reg [31:0]                             ttr8= 32'h00000104;
reg [31:0]                             ttr9= 32'h00000104;
reg [31:0]                             ttr10=32'h00000104;
reg [31:0]                             ttr11=32'h00000104;

reg [31:0]                              tdr0 =32'h00000000;
reg [31:0]                              tdr1 =32'h00000000;
reg [31:0]                              tdr2 =32'h00000000;
reg [31:0]                              tdr3 =32'h00000000;
reg [31:0]                              tdr4 =32'h00000000;
reg [31:0]                              tdr5 =32'h00000000;
reg [31:0]                              tdr6 =32'h00000000;
reg [31:0]                              tdr7 =32'h00000000;
reg [31:0]                              tdr8 =32'h00000000;
reg [31:0]                              tdr9 =32'h00000000;
reg [31:0]                              tdr10=32'h00000000;
reg [31:0]                              tdr11=32'h00000000;

//////FPGA IO///////////////
reg [31:0]             fpga_o0=32'hffffffff; //IO 口默认输出高电平
reg [31:0]             fpga_o1=32'hffffffff;
reg [31:0]             fpga_o2=32'hffffffff;


///////////////NAND Flash controller registers//////////////
reg [7:0]                              nfcr =8'h00;
reg [31:0]                           nfaddr0 =32'h00000000;
reg [31:0]                           nfaddr1 =32'h00000000;


//////////////write registers////////////
always@( posedge clk)
begin
   if(we) begin
   case(addr)
   /////UART/////////////////
   `CR0 : cr0   <= write_data[31:0];
   `CR1 : cr1   <= write_data[31:0];
   `CR2 : cr2   <= write_data[31:0];
   `CR3 : cr3   <= write_data[31:0];
   `CR4 : cr4   <= write_data[31:0];
   `CR5 : cr5   <= write_data[31:0];
   `CR6 : cr6   <= write_data[31:0];
   `CR7 : cr7   <= write_data[31:0];
   `CR8 : cr8   <= write_data[31:0];
   `CR9 : cr9   <= write_data[31:0];
   `CR10 : cr10  <= write_data[31:0];
   `CR11 : cr11  <= write_data[31:0];
   
   `TTR0: ttr0  <= write_data[31:0];
   `TTR1: ttr1  <= write_data[31:0];
   `TTR2: ttr2  <= write_data[31:0];
   `TTR3: ttr3  <= write_data[31:0];
   `TTR4: ttr4  <= write_data[31:0];
   `TTR5: ttr5  <= write_data[31:0];
   `TTR6: ttr6  <= write_data[31:0];
   `TTR7: ttr7  <= write_data[31:0];
   `TTR8: ttr8  <= write_data[31:0];
   `TTR9: ttr9  <= write_data[31:0];
   `TTR10:ttr10 <= write_data[31:0];
   `TTR11:ttr11 <= write_data[31:0];
   
   `TDR0: tdr0  <= write_data[31:0];
   `TDR1: tdr1  <= write_data[31:0];
   `TDR2: tdr2  <= write_data[31:0];
   `TDR3: tdr3  <= write_data[31:0];
   `TDR4: tdr4  <= write_data[31:0];
   `TDR5: tdr5  <= write_data[31:0];
   `TDR6: tdr6  <= write_data[31:0];
   `TDR7: tdr7  <= write_data[31:0];
   `TDR8: tdr8  <= write_data[31:0];
   `TDR9: tdr9  <= write_data[31:0];
   `TDR10:tdr10 <= write_data[31:0];
   `TDR11:tdr11 <= write_data[31:0];
   
   ////FPGA IO
   `FPGA_O0: fpga_o0 <= write_data[31:0];
   `FPGA_O1: fpga_o1 <= write_data[31:0];
   `FPGA_O2: fpga_o2 <= write_data[31:0];
   
   ///NAND Flash///////////
   `NFCR:      nfcr    <=write_data[31:0];
   `NFADDR0:   nfaddr0 <=write_data[31:0];
   `NFADDR1:   nfaddr1 <=write_data[31:0];  
    endcase
    end
    
///各个串口的发送和接收fifo复位控制信号保持一个clk后自动清零
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
    
     if(cr6[ `CR_RX_RESET ]) //rx_reset
    cr6[ `CR_RX_RESET ]<=0;
  if(cr6[ `CR_TX_RESET ]) //tx_reset
    cr6[ `CR_TX_RESET ]<=0;
    
  if(cr7[ `CR_RX_RESET ]) //rx_reset
    cr7[ `CR_RX_RESET ]<=0;
  if(cr7[ `CR_TX_RESET ]) //tx_reset
    cr7[ `CR_TX_RESET ]<=0;
    
    if(cr8[ `CR_RX_RESET ]) //rx_reset
    cr8[ `CR_RX_RESET ]<=0;
  if(cr8[ `CR_TX_RESET ]) //tx_reset
    cr8[ `CR_TX_RESET ]<=0;
    
    if(cr9[ `CR_RX_RESET ]) //rx_reset
    cr9[ `CR_RX_RESET ]<=0;
  if(cr9[ `CR_TX_RESET ]) //tx_reset
    cr9[ `CR_TX_RESET ]<=0;
    
     if(cr10[ `CR_RX_RESET ]) //rx_reset
    cr10[ `CR_RX_RESET ]<=0;
  if(cr10[ `CR_TX_RESET ]) //tx_reset
    cr10[ `CR_TX_RESET ]<=0;
    
    if(cr11[ `CR_RX_RESET ]) //rx_reset
    cr11[ `CR_RX_RESET ]<=0;
  if(cr11[ `CR_TX_RESET ]) //tx_reset
    cr11[ `CR_TX_RESET ]<=0;
    
   if(done) // a command has been finished 
      nfcr[7] <= 0; // disable start signal 
   
end

///////////read registers/////////////////
reg [31:0] read_data=32'h00000000;
always@(re or addr)
begin
  if(re) begin
  case(addr)
  
  //////////UART////////////
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
  
  `CR6:  read_data <= cr6;
  `SR6:  read_data <= sr6;
  `TDR6: read_data <= tdr6;
  `RDR6: read_data <= rdr6;
  
  `CR7:  read_data <= cr7;
  `SR7:  read_data <= sr7;
  `TDR7: read_data <= tdr7;
  `RDR7: read_data <= rdr7;
  
  `CR8 : read_data <= cr8;
  `SR8 : read_data <= sr8;
  `TDR8 :read_data <= tdr8;
  `RDR8 :read_data <= rdr8;
  
  `CR9:  read_data <= cr9;
  `SR9:  read_data <= sr9;
  `TDR9: read_data <= tdr9;
  `RDR9: read_data <= rdr9;
  
  `CR10: read_data <= cr10;
  `SR10: read_data <= sr10;
  `TDR10:read_data <= tdr10;
  `RDR10:read_data <= rdr10;
  
  `CR11: read_data <= cr11;
  `SR11: read_data <= sr11;
  `TDR11:read_data <= tdr11;
  `RDR11:read_data <= rdr11;
  
  ///FPGA IO///////////////////
  `FPGA_O0: read_data <= fpga_o0;
  `FPGA_O1: read_data <= fpga_o1;
  `FPGA_O2: read_data <= fpga_o2;
  
  `FPGA_I0: read_data <= fpga_i0;
  `FPGA_I1: read_data <= fpga_i1;
  `FPGA_I2: read_data <= fpga_i2;
  
  ////NAND Flash Controller///
  `NFCR:     read_data <= nfcr;
  `NFADDR0:  read_data <= nfaddr0;
  `ID:       read_data <= id;
  `STATUS:   read_data <= status;
  endcase
  
  if(cpu_rd_ram_en) //cpu读取FPGA内部ram数据
     read_data <= cpu_rd_ram_data;
  
  if(can0_rd_en)
    read_data  <= {24'b0,cpu_read_can0_data};
  
  end
  
  
 
end



endmodule
