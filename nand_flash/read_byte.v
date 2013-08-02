///////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////
module  read_byte(
                  clk,
                  read_flash,     //connect to flash IO ports
                  read_data_out,
                  ack,
                  read_en,
                  nf_re_n
                );
       
       input         clk;
       input         read_en;
       input  [7:0]  read_flash;
                
       output [7:0]  read_data_out;
       output        nf_re_n;
       output        ack;
       
       
         
       reg [15:0] counter      = 16'h00;
       reg        counter_en   = 1'b0;
       reg        counter_rst  = 1'b1;
       
       parameter idle = 2'd0;
       parameter read = 2'd1;
       reg    [7:0]  read_data_out;
       reg           nf_re_n=1;
       reg           ack=0;
       reg    [1:0]  state=idle;
///////////MAX CLK=100MHZ//////////////////////////////////          
/*parameter TWP   = 4'd3,  //WE low pulse width min=25ns
          TWC   = 4'd6,  //write cycle width min=50ns;
          TRP   = 4'd4,  //RE pulse width min=30ns;
          TRC   = 4'd6,  //read cycle time min=50ns;
          TREA  = 4'd3,  // re_n access time max=30ns;
          TWB   = 4'd10; //WE high to busy max=100ns;*/
parameter TWP   = 16'd2,  //WE low pulse width min=12ns
          TWC   = 16'd3,  //write cycle width min=25ns;
          TRP   = 16'd2,  //RE pulse width min=12ns;
          TRC   = 16'd3,  //read cycle time min=25ns;
          TREA  = 16'd2,  // re_n access time max=20ns;
          TWB   = 16'd10, //WE high to busy max=100ns;
          TREH  = 16'd1;  //RE high hold time min=10ns;//////////////////////////////////////////////////////////////

always@(posedge clk )
    begin
       case(state)
         idle: begin 
                nf_re_n     <= 1;
                ack         <= 0;
                if(read_en)
                 state <= read;
                else
                 state <= idle;
               end
   /////////generate read time sequence////////////////////////
         read:    
               begin
                        if(counter<TREA) begin
                        nf_re_n       <= 1'b0;
                        counter_rst   <= 1'b0;
                        counter_en    <= 1'b1;
                         end
                        if(counter==TREA) 
                        begin
                        read_data_out      <= read_flash;
                        nf_re_n            <= 1'b1;
                        end
                        if(counter>=TRC) 
                        begin
                          counter_rst <= 1'b1;
                          counter_en  <= 1'b0;
                          ack         <= 1'b1;
                          state       <= idle;
                        end
                           
                       
               end
       endcase       
     end
     
////////////////////////////////////////////////////
          //////***  Counter  ***/////
////////////////////////////////////////////////////
always@(posedge clk )
  begin
          if(counter_rst)//
                counter=0;
          else if(counter_en)
                counter = counter + 1'b1;
  end

     
     
    
endmodule
