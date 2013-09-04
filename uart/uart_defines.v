//////////////////////////////////////////////////////////////////////
////                                                              ////
////  uart_defines.v                                              ////
////                                                              ////
////                                                              ////

// Uncomment this if you want your UART to have
// 16xBaudrate output port.
// If defined, the enable signal will be used to drive baudrate_o signal
// It's frequency is 16xbaudrate

// `define UART_HAS_BAUDRATE_OUTPUT


// Interrupt Enable register bits
`define UART_IE_RDA     0   // Received Data available interrupt
`define UART_IE_THRE    1   // Transmitter Holding Register empty interrupt
`define UART_IE_RLS     2   // Receiver Line Status Interrupt
`define UART_IE_TO      3   // time out interrupt enable
`define UART_IE_FTEN    4   //数据帧发送中断使能

// Interrupt Identification register bits
`define UART_II_IP      0   // Interrupt pending when 0
`define UART_II_II      3:1 // Interrupt identification

// Interrupt identification values for bits 3:1
`define UART_II_RLS     3'b011  // Receiver Line Status
`define UART_II_RDA     3'b010  // Receiver Data available
`define UART_II_TI      3'b110  // Timeout Indication
`define UART_II_THRE    3'b001  // Transmitter Holding Register empty
`define UART_II_FTEN    3'b100  // frame transmit interrupt

// FIFO Control Register bits
`define CR_RX_RESET     17    // rx_reset is the 9th bit of the CR
`define CR_TX_RESET     18

//---------------------------------------------
// Line Control register bits
`define CR_LC_BITS   9:8   // bits in character
`define CR_LC_SB        10  // stop bits
`define CR_LC_PE        11  // parity enable
`define CR_LC_EP        12  // even parity
`define CR_LC_SP        13  // stick parity
`define CR_LC_BC        14  // Break control
`define CR_LC_DL        15  // Divisor Latch access bit

// Line Control register bits
`define UART_LC_BITS    1:0 // bits in character
`define UART_LC_SB      2   // stop bits
`define UART_LC_PE      3   // parity enable
`define UART_LC_EP      4   // even parity
`define UART_LC_SP      5   // stick parity
`define UART_LC_BC      6   // Break control
`define UART_LC_DL      7   // Divisor Latch access bit
//----------------------------


// Line Status Register bits
`define UART_LS_DR  0   // Data ready
`define UART_LS_OE  1   // Overrun Error
`define UART_LS_PE  2   // Parity Error
`define UART_LS_FE  3   // Framing Error
`define UART_LS_BI  4   // Break interrupt
`define UART_LS_TFE 5   // Transmit FIFO is empty
`define UART_LS_FTE 6   // Frame transmit enable 数据帧传送使能
`define UART_LS_EI  7   // Error indicator
`define UART_LS_TO  8   // Transmit FIFO is overrun
`define UART_LS_RE  9   // CPU will read an empty fifo interrupt
// FIFO parameter defines

`define UART_FIFO_WIDTH     8
`define UART_FIFO_DEPTH     1024
`define UART_FIFO_POINTER_W 10  //
`define UART_FIFO_COUNTER_W 11
// receiver fifo has width 11 because it has break, parity and framing error bits
`define UART_FIFO_REC_WIDTH  11








