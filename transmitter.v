`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:45:47 10/27/2012 
// Design Name: 
// Module Name:    transmitter 
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
// change log:(1) 引出tf_overrun管脚
//////////////////////////////////////////////////////////////////////////////////
`include "c:/uart_defines.v"

module uart_transmitter (
	clk, 
	rst_n, 
	lcr, 
	tf_push, 
	dat_i, 
	enable,	
	stx_pad_o, 
	tstate, 
	tf_count, 
	tf_overrun,
	tx_reset, 
	lsr_mask
	);

input 										clk;
input 										rst_n;
input [7:0] 							   lcr; //line control register
input 										tf_push;
input [7:0] 							   dat_i;
input 										enable;//启动发送器
input 										tx_reset;
input 										lsr_mask; //
output 										stx_pad_o;//串行发送管脚
output [2:0] 								tstate;
output [`UART_FIFO_COUNTER_W-1:0] 			tf_count; //5 bits
output 										tf_overrun;

reg [2:0] 									tstate; //状态
reg [4:0] 									counter;//脉冲计数
reg [2:0] 									bit_counter;// counts the bits to be sent
reg [6:0] 									shift_out;	// output shift register
reg 										stx_o_tmp;//stx_pad_o 串行信号
reg 										parity_xor;  // parity of the word
reg 										tf_pop;
reg 										bit_out;     //从管脚输出的位

// TX FIFO instance
//
// Transmitter FIFO signals
wire [`UART_FIFO_WIDTH-1:0] 			    tf_data_in;
wire [`UART_FIFO_WIDTH-1:0] 			    tf_data_out;
wire 										tf_push;
wire 										tf_overrun;
wire [`UART_FIFO_COUNTER_W-1:0] 		    tf_count;

assign 	tf_data_in = dat_i;

uart_tfifo fifo_tx(	// error bit signal is not used in transmitter FIFO
	.clk(		clk		), 
	.rst_n(	rst_n	),
	.data_in(	tf_data_in	),
	.data_out(	tf_data_out	),
	.push(		tf_push		),
	.pop(		tf_pop		),
	.overrun(	tf_overrun	),
	.count(		tf_count	),
	.fifo_reset(	tx_reset	),
	.reset_status(lsr_mask)
);

// TRANSMITTER FINAL STATE MACHINE

parameter s_idle        = 3'd0;//
parameter s_send_start  = 3'd1;//发送起始位
parameter s_send_byte   = 3'd2;//发送字节状态
parameter s_send_parity = 3'd3;//
parameter s_send_stop   = 3'd4;//发送停止位
parameter s_pop_byte    = 3'd5;//读FIFO状态

always @(posedge clk or negedge rst_n)
begin
  if (~rst_n)
  begin
	tstate      <= #1 s_idle;//状态寄存器
	stx_o_tmp   <= #1 1'b1;//串行输出
	counter     <= #1 5'b0;//脉冲计数器
	shift_out   <= #1 7'b0;//移位寄存器
	bit_out     <= #1 1'b0;//位寄存器与移位寄存器一起构成8位数??
	parity_xor  <= #1 1'b0;//奇偶效验位
	tf_pop      <= #1 1'b0;//读FIFO信号
	bit_counter <= #1 3'b0;//位寄存器
  end
  else
  if (enable)//
   begin
	case (tstate)//状态
	s_idle	 :	if (~|tf_count) // if tf_count==0 FIFO中数据个数
			begin
				tstate <= #1 s_idle;
				stx_o_tmp <= #1 1'b1;
			end
			else
			begin
				tf_pop     <= #1 1'b0;
				stx_o_tmp  <= #1 1'b1;
				tstate     <= #1 s_pop_byte;
			end
	s_pop_byte :	begin
				tf_pop <= #1 1'b1;
				case (lcr[/*`UART_LC_BITS*/1:0])  // number of bits in a frame
				2'b00 : begin                     // 5 bits
					bit_counter <= #1 3'b100;
					parity_xor  <= #1 ^tf_data_out[4:0];
				     end
				2'b01 : begin
					bit_counter <= #1 3'b101;
					parity_xor  <= #1 ^tf_data_out[5:0];
				     end
				2'b10 : begin
					bit_counter <= #1 3'b110;
					parity_xor  <= #1 ^tf_data_out[6:0];
				     end
				2'b11 : begin
					bit_counter <= #1 3'b111;
					parity_xor  <= #1 ^tf_data_out[7:0];
				     end
				endcase
				{shift_out[6:0], bit_out} <= #1 tf_data_out;
				tstate <= #1 s_send_start;
			end
	///////一个bit的时间为16 clks///////////////////////////////////
	s_send_start :	begin
				tf_pop <= #1 1'b0;
				if (~|counter)              //counter = 0
					counter <= #1 5'b01111;
				else
				if (counter == 5'b00001)
				begin
					counter <= #1 0;
					tstate <= #1 s_send_byte;
				end
				else
					counter <= #1 counter - 1'b1;
				stx_o_tmp <= #1 1'b0;      //输出起始位低电平
			end
	s_send_byte :	begin
				if (~|counter)
					counter <= #1 5'b01111;
				else
				if (counter == 5'b00001)
				begin
					if (bit_counter > 3'b0)
					begin
						bit_counter <= #1 bit_counter - 1'b1;
						{shift_out[5:0],bit_out  } <= #1 {shift_out[6:1], shift_out[0]};
						tstate <= #1 s_send_byte;
					end
					else   // end of byte
					if (~lcr[`UART_LC_PE]) //未开启奇偶校验
					begin
						tstate <= #1 s_send_stop;
					end
					else
					begin
						case ({lcr[`UART_LC_EP],lcr[`UART_LC_SP]})
						2'b00:	bit_out <= #1 ~parity_xor;
						2'b01:	bit_out <= #1 1'b1;
						2'b10:	bit_out <= #1 parity_xor;
						2'b11:	bit_out <= #1 1'b0;
						endcase
						tstate <= #1 s_send_parity;
					end
					counter <= #1 0;
				end
				else
					counter <= #1 counter - 1'b1;
				stx_o_tmp <= #1 bit_out; // set output pin
			end
	s_send_parity :	begin
				if (~|counter)
					counter <= #1 5'b01111;
				else
				if (counter == 5'b00001)
				begin
					counter <= #1 4'b0;
					tstate <= #1 s_send_stop;
				end
				else
					counter <= #1 counter - 1'b1;
				stx_o_tmp <= #1 bit_out;
			end
	s_send_stop :  begin
				if (~|counter)
				  begin
						casex ({lcr[`UART_LC_SB],lcr[`UART_LC_BITS]})
  						3'b0xx:	  counter <= #1 5'b01101;     // 1 stop bit ok igor
  						3'b100:	  counter <= #1 5'b10101;     // 1.5 stop bit
  						default:  counter <= #1 5'b11101;     // 2 stop bits
						endcase
					end
				else
				if (counter == 5'b00001)
				begin
					counter <= #1 0;
					tstate <= #1 s_idle;
				end
				else
					counter <= #1 counter - 1'b1;
				stx_o_tmp <= #1 1'b1;
			end

		default : // should never get here
			tstate <= #1 s_idle;
	endcase
  end // end if enable
  else
    tf_pop <= #1 1'b0;  // tf_pop must be 1 cycle width
end // transmitter logic

assign stx_pad_o = lcr[`UART_LC_BC] ? 1'b0 : stx_o_tmp;    // Break condition

endmodule
