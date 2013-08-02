//`timescale 1ns / 1ps

`include "uart_defines.v"

///注意地址是忽略A30,A31的
`define CR0  22'h0000  // configuration register
`define SR0  22'h0001  // status register
`define TDR0 22'h0002
`define RDR0 22'h0003

`define CR1  22'h0004  // configuration register
`define SR1  22'h0005  // status register
`define TDR1 22'h0006
`define RDR1 22'h0007

`define CR2  22'h0008  // configuration register
`define SR2  22'h0009  // status register
`define TDR2 22'h000a
`define RDR2 22'h000b

`define CR3  22'h000c  // configuration register
`define SR3  22'h000d  // status register
`define TDR3 22'h000e
`define RDR3 22'h000f

`define CR4  22'h0010  // configuration register
`define SR4  22'h0011  // status register
`define TDR4 22'h0012
`define RDR4 22'h0013

`define CR5  22'h0014  // configuration register
`define SR5  22'h0015  // status register
`define TDR5 22'h0016
`define RDR5 22'h0017
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
                sr5_read,
                
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

/////////////////UART registers//////////////////////    
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
   `TDR0: tdr0  <= write_data[31:0];
   `TDR1: tdr1  <= write_data[31:0];
   `TDR2: tdr2  <= write_data[31:0];
   `TDR3: tdr3  <= write_data[31:0];
   `TDR4: tdr4  <= write_data[31:0];
   `TDR5: tdr5  <= write_data[31:0];
   
   ///NAND Flash///////////
   `NFCR:      nfcr    <=write_data[31:0];
   `NFADDR0:   nfaddr0 <=write_data[31:0];
   `NFADDR1:   nfaddr1 <=write_data[31:0];  
    endcase
    end
    
    ///各个串口的发送和接收fifo复位控制信号保持一个clk后自动清0
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
  
  ////NAND Flash Controller///
  `NFCR:     read_data <= nfcr;
  `NFADDR0:  read_data <= nfaddr0;
  `ID:       read_data <= id;
  `STATUS:   read_data <= status;
  endcase
  
  if(cpu_rd_ram_en) //cpu读取FPGA内部ram数据
     read_data <= cpu_rd_ram_data;
  
  
  end
end



endmodule
