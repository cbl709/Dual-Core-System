module fpga_io(
               clk,
               fpga_o0,
               fpga_o1,
               fpga_o2,
             
               
               fpga_i0,
               fpga_i1,
               fpga_i2,
              
               
               input_pad0,
               input_pad1,
               input_pad2,
             
               
               output_pad0,
               output_pad1,
               output_pad2
            
              );

  input                    clk;
  
  // net from regs module
  input [31:0]             fpga_o0;
  input [31:0]             fpga_o1;
  input [31:0]             fpga_o2;
  
  
  // net to regs module
  output  [31:0]           fpga_i0;
  output  [31:0]           fpga_i1;
  output  [31:0]           fpga_i2;
  
  
  reg  [31:0]              fpga_i0;
  reg  [31:0]              fpga_i1;
  reg  [31:0]              fpga_i2;
 
  
  // input signals from outside world
  input [31:0]              input_pad0;
  input [31:0]              input_pad1;
  input [31:0]              input_pad2;
  
  
  // output signals to outside world
  output [31:0]            output_pad0;
  output [31:0]            output_pad1;
  output [31:0]            output_pad2;
  
  
  //实际上可以直接将fpga_o寄存器作为输出，这里重新定义了寄存器是为了方便以后扩展
  reg [31:0]            output_pad0 = 32'hffffffff;
  reg [31:0]            output_pad1 = 32'hffffffff;
  reg [31:0]            output_pad2 = 32'hffffffff;
  
  
  always@(posedge clk)
  begin
   
   output_pad0 <= fpga_o0;
   output_pad1 <= fpga_o1;
   output_pad2 <= fpga_o2;
  
  
  end
  
  always@(posedge clk)
  begin
   fpga_i0 <= input_pad0;
   fpga_i1 <= input_pad1;
   fpga_i2 <= input_pad2;
  
  
  end
  












endmodule 
