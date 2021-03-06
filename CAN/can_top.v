
`timescale 1ns / 1ps
// synopsys translate_off
//`include "timescale.v"
// synopsys translate_on

// 将can top 的双向端口分成data_in data_out,并且去除ale地址锁存信号，地址信号
//直接由外部输入  --by cbl 2013-8-9
`include "can_defines.v"

module can_top
( 
  
    rst_i,
    addr,
    rd_i,
    wr_i,
    data_in,
    data_out,
    
    cs_can_i,
    clk_i,
    rx_i,
    tx_o,
    bus_off_on,
    irq_on,
    clkout_o

);

parameter Tp = 1;

  input        rst_i;
  input        rd_i;
  input        wr_i;
  input        [7:0] addr;
  input  [7:0] data_in;
  output [7:0] data_out;
  input        cs_can_i;
    
  reg    [7:0] addr_latched;
  reg          wr_i_q;
  reg          rd_i_q;
input        clk_i;
input        rx_i;
output       tx_o;
output       bus_off_on;
output       irq_on;
output       clkout_o;


reg          data_out_fifo_selected;


wire   [7:0] data_out_fifo;
wire   [7:0] data_out_regs;


/* Mode register */
wire         reset_mode;
wire         listen_only_mode;
wire         acceptance_filter_mode;
wire         self_test_mode;

/* Command register */
wire         release_buffer;
wire         tx_request;
wire         abort_tx;
wire         self_rx_request;
wire         single_shot_transmission;
wire         tx_state;
wire         tx_state_q;
wire         overload_request;
wire         overload_frame;


/* Arbitration Lost Capture Register */
wire         read_arbitration_lost_capture_reg;

/* Error Code Capture Register */
wire         read_error_code_capture_reg;
wire   [7:0] error_capture_code;

/* Bus Timing 0 register */
wire   [5:0] baud_r_presc;
wire   [1:0] sync_jump_width;

/* Bus Timing 1 register */
wire   [3:0] time_segment1;
wire   [2:0] time_segment2;
wire         triple_sampling;

/* Error Warning Limit register */
wire   [7:0] error_warning_limit;

/* Rx Error Counter register */
wire         we_rx_err_cnt;

/* Tx Error Counter register */
wire         we_tx_err_cnt;

/* Clock Divider register */
wire         extended_mode;

/* This section is for BASIC and EXTENDED mode */
/* Acceptance code register */
wire   [7:0] acceptance_code_0;

/* Acceptance mask register */
wire   [7:0] acceptance_mask_0;
/* End: This section is for BASIC and EXTENDED mode */


/* This section is for EXTENDED mode */
/* Acceptance code register */
wire   [7:0] acceptance_code_1;
wire   [7:0] acceptance_code_2;
wire   [7:0] acceptance_code_3;

/* Acceptance mask register */
wire   [7:0] acceptance_mask_1;
wire   [7:0] acceptance_mask_2;
wire   [7:0] acceptance_mask_3;
/* End: This section is for EXTENDED mode */

/* Tx data registers. Holding identifier (basic mode), tx frame information (extended mode) and data */
wire   [7:0] tx_data_0;
wire   [7:0] tx_data_1;
wire   [7:0] tx_data_2;
wire   [7:0] tx_data_3;
wire   [7:0] tx_data_4;
wire   [7:0] tx_data_5;
wire   [7:0] tx_data_6;
wire   [7:0] tx_data_7;
wire   [7:0] tx_data_8;
wire   [7:0] tx_data_9;
wire   [7:0] tx_data_10;
wire   [7:0] tx_data_11;
wire   [7:0] tx_data_12;
/* End: Tx data registers */

wire         cs;

/* Output signals from can_btl module */
wire         sample_point;
wire         sampled_bit;
wire         sampled_bit_q;
wire         tx_point;
wire         hard_sync;

/* output from can_bsp module */
wire         rx_idle;
wire         transmitting;
wire         transmitter;
wire         go_rx_inter;
wire         not_first_bit_of_inter;
wire         set_reset_mode;
wire         node_bus_off;
wire         error_status;
wire   [7:0] rx_err_cnt;
wire   [7:0] tx_err_cnt;
wire         rx_err_cnt_dummy;  // The MSB is not displayed. It is just used for easier calculation (no counter overflow).
wire         tx_err_cnt_dummy;  // The MSB is not displayed. It is just used for easier calculation (no counter overflow).
wire         transmit_status;
wire         receive_status;
wire         tx_successful;
wire         need_to_tx;
wire         overrun;
wire         info_empty;
wire         set_bus_error_irq;
wire         set_arbitration_lost_irq;
wire   [4:0] arbitration_lost_capture;
wire         node_error_passive;
wire         node_error_active;
wire   [6:0] rx_message_counter;
wire         tx_next;

wire         go_overload_frame;
wire         go_error_frame;
wire         go_tx;
wire         send_ack;

wire         rst;
wire         we;
wire   [7:0] addr;
wire   [7:0] data_in;
reg    [7:0] data_out;
reg          rx_sync_tmp;
reg          rx_sync;

/* Connecting can_registers module */
can_registers i_can_registers
( 
  .clk(clk_i),
  .rst(rst),
  .cs(cs),
  .we(we),
  .addr(addr),
  .data_in(data_in),
  .data_out(data_out_regs),
  .irq_on(irq_on),
  
  .sample_point(sample_point),
  .transmitting(transmitting),
  .set_reset_mode(set_reset_mode),
  .node_bus_off(node_bus_off),
  .error_status(error_status),
  .rx_err_cnt(rx_err_cnt),
  .tx_err_cnt(tx_err_cnt),
  .transmit_status(transmit_status),
  .receive_status(receive_status),
  .tx_successful(tx_successful),
  .need_to_tx(need_to_tx),
  .overrun(overrun),
  .info_empty(info_empty),
  .set_bus_error_irq(set_bus_error_irq),
  .set_arbitration_lost_irq(set_arbitration_lost_irq),
  .arbitration_lost_capture(arbitration_lost_capture),
  .node_error_passive(node_error_passive),
  .node_error_active(node_error_active),
  .rx_message_counter(rx_message_counter),


  /* Mode register */
  .reset_mode(reset_mode),
  .listen_only_mode(listen_only_mode),
  .acceptance_filter_mode(acceptance_filter_mode),
  .self_test_mode(self_test_mode),

  /* Command register */
  .clear_data_overrun(),
  .release_buffer(release_buffer),
  .abort_tx(abort_tx),
  .tx_request(tx_request),
  .self_rx_request(self_rx_request),
  .single_shot_transmission(single_shot_transmission),
  .tx_state(tx_state),
  .tx_state_q(tx_state_q),
  .overload_request(overload_request),
  .overload_frame(overload_frame),

  /* Arbitration Lost Capture Register */
  .read_arbitration_lost_capture_reg(read_arbitration_lost_capture_reg),

  /* Error Code Capture Register */
  .read_error_code_capture_reg(read_error_code_capture_reg),
  .error_capture_code(error_capture_code),

  /* Bus Timing 0 register */
  .baud_r_presc(baud_r_presc),
  .sync_jump_width(sync_jump_width),

  /* Bus Timing 1 register */
  .time_segment1(time_segment1),
  .time_segment2(time_segment2),
  .triple_sampling(triple_sampling),

  /* Error Warning Limit register */
  .error_warning_limit(error_warning_limit),

  /* Rx Error Counter register */
  .we_rx_err_cnt(we_rx_err_cnt),

  /* Tx Error Counter register */
  .we_tx_err_cnt(we_tx_err_cnt),

  /* Clock Divider register */
  .extended_mode(extended_mode),
  .clkout(clkout_o),
  
  /* This section is for BASIC and EXTENDED mode */
  /* Acceptance code register */
  .acceptance_code_0(acceptance_code_0),

  /* Acceptance mask register */
  .acceptance_mask_0(acceptance_mask_0),
  /* End: This section is for BASIC and EXTENDED mode */
  
  /* This section is for EXTENDED mode */
  /* Acceptance code register */
  .acceptance_code_1(acceptance_code_1),
  .acceptance_code_2(acceptance_code_2),
  .acceptance_code_3(acceptance_code_3),

  /* Acceptance mask register */
  .acceptance_mask_1(acceptance_mask_1),
  .acceptance_mask_2(acceptance_mask_2),
  .acceptance_mask_3(acceptance_mask_3),
  /* End: This section is for EXTENDED mode */

  /* Tx data registers. Holding identifier (basic mode), tx frame information (extended mode) and data */
  .tx_data_0(tx_data_0),
  .tx_data_1(tx_data_1),
  .tx_data_2(tx_data_2),
  .tx_data_3(tx_data_3),
  .tx_data_4(tx_data_4),
  .tx_data_5(tx_data_5),
  .tx_data_6(tx_data_6),
  .tx_data_7(tx_data_7),
  .tx_data_8(tx_data_8),
  .tx_data_9(tx_data_9),
  .tx_data_10(tx_data_10),
  .tx_data_11(tx_data_11),
  .tx_data_12(tx_data_12)
  /* End: Tx data registers */
);




/* Connecting can_btl module */
can_btl i_can_btl
( 
  .clk(clk_i),
  .rst(rst),
  .rx(rx_sync), 
  .tx(tx_o),

  /* Bus Timing 0 register */
  .baud_r_presc(baud_r_presc),
  .sync_jump_width(sync_jump_width),

  /* Bus Timing 1 register */
  .time_segment1(time_segment1),
  .time_segment2(time_segment2),
  .triple_sampling(triple_sampling),

  /* Output signals from this module */
  .sample_point(sample_point),
  .sampled_bit(sampled_bit),
  .sampled_bit_q(sampled_bit_q),
  .tx_point(tx_point),
  .hard_sync(hard_sync),

  
  /* output from can_bsp module */
  .rx_idle(rx_idle),
  .rx_inter(rx_inter),
  .transmitting(transmitting),
  .transmitter(transmitter),
  .go_rx_inter(go_rx_inter),
  .tx_next(tx_next),

  .go_overload_frame(go_overload_frame),
  .go_error_frame(go_error_frame),
  .go_tx(go_tx),
  .send_ack(send_ack),
  .node_error_passive(node_error_passive)
  


);



can_bsp i_can_bsp
(
  .clk(clk_i),
  .rst(rst),
  
  /* From btl module */
  .sample_point(sample_point),
  .sampled_bit(sampled_bit),
  .sampled_bit_q(sampled_bit_q),
  .tx_point(tx_point),
  .hard_sync(hard_sync),

  .addr(addr),
  .data_in(data_in),
  .data_out(data_out_fifo),
  .fifo_selected(data_out_fifo_selected),

  /* Mode register */
  .reset_mode(reset_mode),
  .listen_only_mode(listen_only_mode),
  .acceptance_filter_mode(acceptance_filter_mode),
  .self_test_mode(self_test_mode),
  
  /* Command register */
  .release_buffer(release_buffer),
  .tx_request(tx_request),
  .abort_tx(abort_tx),
  .self_rx_request(self_rx_request),
  .single_shot_transmission(single_shot_transmission),
  .tx_state(tx_state),
  .tx_state_q(tx_state_q),
  .overload_request(overload_request),
  .overload_frame(overload_frame),

  /* Arbitration Lost Capture Register */
  .read_arbitration_lost_capture_reg(read_arbitration_lost_capture_reg),

  /* Error Code Capture Register */
  .read_error_code_capture_reg(read_error_code_capture_reg),
  .error_capture_code(error_capture_code),

  /* Error Warning Limit register */
  .error_warning_limit(error_warning_limit),

  /* Rx Error Counter register */
  .we_rx_err_cnt(we_rx_err_cnt),

  /* Tx Error Counter register */
  .we_tx_err_cnt(we_tx_err_cnt),

  /* Clock Divider register */
  .extended_mode(extended_mode),

  /* output from can_bsp module */
  .rx_idle(rx_idle),
  .transmitting(transmitting),
  .transmitter(transmitter),
  .go_rx_inter(go_rx_inter),
  .not_first_bit_of_inter(not_first_bit_of_inter),
  .rx_inter(rx_inter),
  .set_reset_mode(set_reset_mode),
  .node_bus_off(node_bus_off),
  .error_status(error_status),
  .rx_err_cnt({rx_err_cnt_dummy, rx_err_cnt[7:0]}),   // The MSB is not displayed. It is just used for easier calculation (no counter overflow).
  .tx_err_cnt({tx_err_cnt_dummy, tx_err_cnt[7:0]}),   // The MSB is not displayed. It is just used for easier calculation (no counter overflow).
  .transmit_status(transmit_status),
  .receive_status(receive_status),
  .tx_successful(tx_successful),
  .need_to_tx(need_to_tx),
  .overrun(overrun),
  .info_empty(info_empty),
  .set_bus_error_irq(set_bus_error_irq),
  .set_arbitration_lost_irq(set_arbitration_lost_irq),
  .arbitration_lost_capture(arbitration_lost_capture),
  .node_error_passive(node_error_passive),
  .node_error_active(node_error_active),
  .rx_message_counter(rx_message_counter),
  
  /* This section is for BASIC and EXTENDED mode */
  /* Acceptance code register */
  .acceptance_code_0(acceptance_code_0),

  /* Acceptance mask register */
  .acceptance_mask_0(acceptance_mask_0),
  /* End: This section is for BASIC and EXTENDED mode */
  
  /* This section is for EXTENDED mode */
  /* Acceptance code register */
  .acceptance_code_1(acceptance_code_1),
  .acceptance_code_2(acceptance_code_2),
  .acceptance_code_3(acceptance_code_3),

  /* Acceptance mask register */
  .acceptance_mask_1(acceptance_mask_1),
  .acceptance_mask_2(acceptance_mask_2),
  .acceptance_mask_3(acceptance_mask_3),
  /* End: This section is for EXTENDED mode */

  /* Tx data registers. Holding identifier (basic mode), tx frame information (extended mode) and data */
  .tx_data_0(tx_data_0),
  .tx_data_1(tx_data_1),
  .tx_data_2(tx_data_2),
  .tx_data_3(tx_data_3),
  .tx_data_4(tx_data_4),
  .tx_data_5(tx_data_5),
  .tx_data_6(tx_data_6),
  .tx_data_7(tx_data_7),
  .tx_data_8(tx_data_8),
  .tx_data_9(tx_data_9),
  .tx_data_10(tx_data_10),
  .tx_data_11(tx_data_11),
  .tx_data_12(tx_data_12),
  /* End: Tx data registers */
  
  /* Tx signal */
  .tx(tx_o),
  .tx_next(tx_next),
  .bus_off_on(bus_off_on),

  .go_overload_frame(go_overload_frame),
  .go_error_frame(go_error_frame),
  .go_tx(go_tx),
  .send_ack(send_ack)


`ifdef CAN_BIST
  ,
  /* BIST signals */
  .mbist_si_i(mbist_si_i),
  .mbist_so_o(mbist_so_o),
  .mbist_ctrl_i(mbist_ctrl_i)
`endif
);



// Multiplexing wb_dat_o from registers and rx fifo
always @ (extended_mode or addr or reset_mode)
begin
  if (extended_mode & (~reset_mode) & ((addr >= 8'd16) && (addr <= 8'd28)) | (~extended_mode) & ((addr >= 8'd20) && (addr <= 8'd29)))
    data_out_fifo_selected = 1'b1;
  else
    data_out_fifo_selected = 1'b0;
end


always @ (posedge clk_i)
begin
  if (cs & (~we))
    begin
      if (data_out_fifo_selected)
        data_out <=#Tp data_out_fifo;
      else
        data_out <=#Tp data_out_regs;
    end
end



always @ (posedge clk_i or posedge rst)
begin
  if (rst)
    begin
      rx_sync_tmp <= 1'b1;
      rx_sync     <= 1'b1;
    end
  else
    begin
      rx_sync_tmp <=#Tp rx_i;
      rx_sync     <=#Tp rx_sync_tmp;
    end
end



  // Generating delayed wr_i and rd_i signals
  always @ (posedge clk_i or posedge rst)
  begin
    if (rst)
      begin
        wr_i_q <= 1'b0;
        rd_i_q <= 1'b0;
      end
    else
      begin
        wr_i_q <=#Tp wr_i;
        rd_i_q <=#Tp rd_i;
      end
  end


  assign cs = ((wr_i & (~wr_i_q)) | (rd_i & (~rd_i_q))) & cs_can_i;
  assign rst       = rst_i;
  assign we        = wr_i;
 


endmodule
