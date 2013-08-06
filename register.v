
// synopsys translate_off
`timescale 1ns / 1ps
// synopsys translate_on


module register
( data_in,
  data_out,
  we,
  clk
);

parameter WIDTH = 32; // default parameter of the register width
parameter DEFAULT_VAL= 0;

input [WIDTH-1:0] data_in;
input             we;
input             clk;

output [WIDTH-1:0] data_out;
reg    [WIDTH-1:0] data_out;



always @ (posedge clk)
begin
  if (we)                        // write
    data_out<=#1 data_in;
end



endmodule
