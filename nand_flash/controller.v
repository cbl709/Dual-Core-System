module controller(
                    clk,
                    nf_addr0,// nand flash address0
                    nf_addr1,
                    r,
                    done,
                    
                    nfcr,
          
                /////nand flash control signal////////
                    nf_cle,
                    nf_ale,
                    nf_ce_n,
                    nf_re_n,
                    nf_we_n,
          
                ////flash to dual-ram signal//////////
                    flash_wr_ram_en,
                    flash_to_ram_addr,
                    flash_to_ram_data,
                    
                    ram_to_flash_data,
                          
                    read_flash_en,
                    read_flash,
                    write_flash,
                    
                    status,
                    
                ///test/////
                   cycle,
                   byte_num,
         
       
                    id
        
                 );

input           clk;
input [31:0]    nf_addr0;
input [31:0]    nf_addr1;
input           r;
input [7:0]     nfcr;
input  [7:0]     read_flash;
output [7:0]     write_flash;
reg    [7:0]     write_flash=8'h00;

wire  [3:0]     operate;
wire            start;
wire  [1:0]     page_size;

assign  operate    = nfcr[3:0];
assign  page_size  = nfcr[5:4];
assign  start      = nfcr[7];


output          done;
output          nf_cle;
output          nf_ale;
output          nf_ce_n;
output          nf_re_n;
output          nf_we_n;
output [7:0]    status;
reg    [7:0]    status=0;

input  [31:0]  ram_to_flash_data;

output          [11:0] byte_num;

output  [19:0]  cycle;

output          read_flash_en;
reg             read_flash_en=1'b1;


output [31:0]   flash_to_ram_data;
reg    [31:0]   flash_to_ram_data=32'h0;

output          flash_wr_ram_en;
reg             flash_wr_ram_en;

output [9:0]    flash_to_ram_addr;
reg    [9:0]    flash_to_ram_addr=10'h0;

output [39:0]   id;
reg    [39:0]   id =40'h0;


reg             nf_cle  = 1'b0;
reg             nf_ale  = 1'b0;
reg             nf_ce_n = 1'b0;
reg             nf_we_n = 1'b1;
reg             done    = 1'b0;

wire ack;
wire [7:0]      read_data_out;
reg             read_en=0;


////////////state parameter///////////////////////////////

parameter idle               =  8'b00000001,
          flash_rst          =  8'b00000010,
          page_read          =  8'b00000100,
          block_erase        =  8'b00001000,
          page_program       =  8'b00010000,
          read_id            =  8'b00100000,
          read_status        =  8'b01000000;  
          
          
          
////////// cycle parameter////////////////////////////
parameter cycle_1               =  20'b00000000000000000001,
          cycle_2               =  20'b00000000000000000010,
          cycle_3               =  20'b00000000000000000100,
          cycle_4               =  20'b00000000000000001000,
          cycle_5               =  20'b00000000000000010000,
          cycle_6               =  20'b00000000000000100000,
          cycle_7               =  20'b00000000000001000000,  
          cycle_8               =  20'b00000000000010000000,
          cycle_9               =  20'b00000000000100000000,
          cycle_10              =  20'b00000000001000000000,
          cycle_11              =  20'b00000000010000000000,
          cycle_12              =  20'b00000000100000000000,
          cycle_13              =  20'b00000001000000000000,
          cycle_14              =  20'b00000010000000000000,
          cycle_15              =  20'b00000100000000000000,
          cycle_16              =  20'b00001000000000000000,
          cycle_17              =  20'b00010000000000000000,
          cycle_18              =  20'b00100000000000000000,
          cycle_19              =  20'b01000000000000000000,
          cycle_20              =  20'b10000000000000000000;
          
////////////////////////////  
///////////////////       
parameter TWP   = 16'd2,  //WE low pulse width min=12ns
          TWC   = 16'd3,  //write cycle width min=25ns;
          TRP   = 16'd2,  //RE pulse width min=12ns;
          TRC   = 16'd3,  //read cycle time min=25ns;
          TREA  = 16'd2,  // re_n access time max=20ns;
          TWB   = 16'd10, //WE high to busy max=100ns;
          TREH  = 16'd1;  //RE high hold time min=10ns;
          
///////////page size define//////////////////////////
 reg[11:0]     byte_num = 12'd0;
 reg[11:0]     PageSize;
 always @*
     begin
        case(page_size)
        2'b00: PageSize = 12'd256;
        2'b01: PageSize = 12'd512;
        2'b10: PageSize = 12'd1024;
        2'b11: PageSize = 12'd2048+12'd64;
       endcase
     end
     

reg ack_d=0;
reg r_d  =0;
always@(posedge clk)
begin
  ack_d<=ack;
  r_d  <=r;
end
     
     
     
 //////////////////////////////////////////////////
 ///////////////  主状态/////////////////////////////
 /////////////////////////////////////////////////
 reg [7:0]  r_cnt=0;
 reg [7:0] state = idle;
 reg [19:0] cycle = cycle_1;
 always@(posedge clk)
 begin
  case(state)
    idle:   begin
              nf_ce_n <=0; // flash always enable
              nf_cle  <=0;
              nf_ale  <=0;
              nf_we_n <=1;
              done    <=0;
              flash_to_ram_addr <=0;
              flash_wr_ram_en   <=0;
              byte_num          <=0;
              r_cnt             <=0;
              read_flash_en     <=1;
              read_en           <=0;
              cycle             <= cycle_1;
              
               if(start&~done) begin
                case(operate)
                4'b0000: state <= idle;
                4'b0001: state <= page_program;
                4'b0010: state <= page_read;
                4'b0011: state <= block_erase;
                4'b0100: state <= flash_rst;
                4'b0101: state <= read_id;
                4'b0110: state <= read_status;
                default: state <= idle;
                endcase
              end
            end
            
    read_id: begin
                case(cycle)
                cycle_1: send_cmd(8'h90);
                cycle_2: send_addr(8'h00,1);
                cycle_3: read_byte_task(id[39:32]);
                cycle_4: read_byte_task(id[31:24]);
                cycle_5: read_byte_task(id[23:16]);
                cycle_6: read_byte_task(id[15:8]);
                cycle_7: read_byte_task(id[7:0]);
                cycle_8: opdone;
                         
                endcase         
               end
               
    flash_rst: begin
                case(cycle)
                cycle_1:send_cmd(8'hff);
                cycle_2: begin
                         r_cnt <= r_cnt+1;
                         if(r_cnt==TWB)
                           cycle_inc;
                          end
                cycle_3:  begin
                            if(r)
                            cycle_inc; // wait until not busy 
                                
                          end
                cycle_4: opdone;
                default: state<= idle;
                endcase
               end
               
  page_program: begin
                 case(cycle)
                  cycle_1:send_cmd(8'h80);
                  cycle_2:send_addr(nf_addr0[7:0],0);
                  cycle_3:if(page_size==2'b11)
                            send_addr({4'b0,nf_addr0[11:8]},0);
                          else
                            send_addr(nf_addr0[7:0],0);
                  cycle_4:if(page_size==2'b11)
                              send_addr(nf_addr0[19:12],0);
                          else
                              send_addr(nf_addr0[24:17],0);
                  cycle_5: if(page_size==2'b11)
                              send_addr(nf_addr0[27:20],0);
                           else
                             send_addr({7'b0,nf_addr0[25]},1);
                             
                  cycle_6: if(page_size==2'b11)
                              send_addr({5'b0,nf_addr0[30:28]},1);
                            else
                              cycle_inc;
                          
                  cycle_7: send_byte(ram_to_flash_data[7:0],1);
                  cycle_8: send_byte(ram_to_flash_data[15:8],1);
                  cycle_9 :send_byte(ram_to_flash_data[23:16],1);
                  cycle_10:send_byte(ram_to_flash_data[31:24],1); // write 4 bytes 
                  cycle_11:begin
                             flash_to_ram_addr <= flash_to_ram_addr+1;
                             if(byte_num==PageSize)
                               cycle_inc;
                             else
                                cycle<= cycle_7;
                           end
                  cycle_12: send_cmd(8'h10);
                  cycle_13: begin
                              r_cnt <= r_cnt+1;
                              if(r_cnt==TWB)
                                 cycle_inc;
                            end
                  cycle_14:  begin
                               if(r) 
                                cycle_inc; // wait until not busy 
                            end
                  cycle_15: send_cmd(8'h70);
                  cycle_16: cycle_inc;
                  cycle_17: read_byte_task(status[7:0]);
                  cycle_18: opdone;
                  default: state<= idle;
                  
                 endcase    
                    end
               
    page_read: begin            
                case(cycle)
                  cycle_1:send_cmd(8'h00);
                  cycle_2:send_addr(nf_addr0[7:0],0);
                  cycle_3:if(page_size==2'b11)
                            send_addr({4'b0,nf_addr0[11:8]},0);
                          else
                            send_addr(nf_addr0[7:0],0);
                  cycle_4:if(page_size==2'b11)
                              send_addr(nf_addr0[19:12],0);
                          else
                              send_addr(nf_addr0[24:17],0);
                  cycle_5: if(page_size==2'b11)
                              send_addr(nf_addr0[27:20],0);
                           else
                             send_addr({7'b0,nf_addr0[25]},1);
                             
                  cycle_6: if(page_size==2'b11)
                              send_addr({5'b0,nf_addr0[30:28]},1);
                            else
                              cycle_inc;                      
                  cycle_7: send_cmd(8'h30);
                  cycle_8: begin
                        r_cnt <= r_cnt+1;
                        if(r_cnt==TWB)                              
                          cycle_inc;
                          end
                  cycle_9: if(r) cycle_inc;        // wait until not busy
                
       //////cycle 10 to cycle 12: read 4 bytes flash data, and write to dual-ram /////////
                  cycle_10:  read_byte_task(flash_to_ram_data[7:0]);                                                                     
                  cycle_11:  read_byte_task(flash_to_ram_data[15:8]);                                               
                  cycle_12:  read_byte_task(flash_to_ram_data[23:16]);                               
                  cycle_13:  read_byte_task(flash_to_ram_data[31:24]);                

                cycle_14:begin
                        flash_wr_ram_en <=1;      //after read 4 bytes from flash, write flash_to_ram_data to dual-ram,
                                                // enable flash_wr_ram_en
                        cycle_inc;
                        end
                cycle_15:begin
                        flash_wr_ram_en   <= 0;     // disable the Flash2RamWe, ensure the Flash2RamWe enable not more than 1 clk
                        flash_to_ram_addr <= flash_to_ram_addr+1;
                        cycle_inc;
                        end 
                cycle_16: begin
                        if(byte_num==PageSize)
                             cycle_inc;            
                        else
                            cycle<= cycle_10;
                           end   
                 cycle_17: send_cmd(8'h70);
                 cycle_18: cycle_inc;
                 cycle_19: read_byte_task(status[7:0]);
                 cycle_20: opdone;
               default: state<= idle;
                    
            endcase 
        end
        
block_erase: begin
                    case(cycle)
                    cycle_1: send_cmd(8'h60); 
                    cycle_2: if(page_size==2'b11)
                                send_addr (nf_addr0[19:12],0);
                             else
                                 send_addr(nf_addr0[16:9],0);
                                 
                    cycle_3: if(page_size==2'b11)
                               send_addr (nf_addr0[27:20],0);
                             else
                               send_addr(nf_addr0[24:17],0);
                    cycle_4: if(page_size==2'b11)
                                send_addr ({5'b0,nf_addr0[30:28]},1);
                             else
                                send_addr({7'b0,nf_addr0[25]},1);
                    cycle_5: send_cmd(8'hd0);
                    cycle_6: begin
                             r_cnt <= r_cnt+1;
                             if(r_cnt==TWB)
                              cycle_inc;
                            end
                    cycle_7:begin
                               if(r) 
                                cycle_inc; // wait until not busy 
                            end
                    cycle_8: send_cmd(8'h70);
                    cycle_9: cycle_inc;
                    cycle_10: read_byte_task(status[7:0]);
                    cycle_11: opdone;
                    default: state<= idle;
                    endcase
                end
                
read_status: begin
                    case(cycle)
                    cycle_1: send_cmd(8'h70);
                    cycle_2: cycle_inc;
                    cycle_3: read_byte_task(status[7:0]);
                    cycle_4: opdone;
                    default: state <=idle;
                    endcase
             end
               
               
  endcase
          
 end
 



task cycle_inc;
begin
  cycle <= (cycle<<1);
end
endtask

task opdone;
      begin
        state <= idle;
         done <= 1;
         
      end
endtask

////////////////////////////////////////////////////
          //////***  Counter  ***/////
////////////////////////////////////////////////////
reg [15:0] counter      = 16'h00;
reg        counter_en   = 1'b0;
reg        counter_rst  = 1'b1;
always@(posedge clk )
  begin
          if(counter_rst)
                counter=0;
          else if(counter_en)
                counter = counter + 1'b1;
  end

///////////////////////////////////////////////////////////////////////////////////////////
//   send_cmd(cmd0)   send the command "cmd0" ,and jump to the next operate Cycle        //
/////////////////////////////////////////////////////////////////////////////////////////
task  send_cmd;
       input[7:0]  command;
       begin
       if(counter<TWP) begin
           write_flash     <= command;
           read_flash_en   <= 1'b0;
           nf_cle          <= 1'b1;
           nf_ale          <= 1'b0;
           nf_we_n         <= 1'b0;
           counter_rst     <= 0;
           counter_en      <= 1;
        end

       if( counter>=TWP)
            nf_we_n      <= 1'b1; 
       if ( counter==TWC )
       begin
             nf_cle        <= 1'b0;
             counter_rst   <= 1'b1;
             counter_en    <= 1'b0;
             cycle_inc;
            end
   end
endtask

///////////////////////////////////////////////////////////////////////////////////////////
//   send_byte(data0,1)   send the last data "data0" ,and jump to the next operate Cycle  //
//////////////////////////////////////////////////////////////////////////////////////////
task  send_byte;
       input[7:0]  data;
       input       last_data;
       begin
       counter_rst    <= 0;
       counter_en     <= 1;
       read_flash_en  <= 1'b0;// write
       nf_we_n        <= 1'b0;
       nf_cle         <= 1'b0;
       nf_ale         <= 1'b0;
       write_flash    <= data;
         if( counter>=TWP )
           nf_we_n <= 1'b1; 
         if ( counter==TWC )
            begin
             counter_rst <= 1'b1;
             counter_en  <= 1'b0;
             byte_num    <= byte_num+1;
             if(last_data)
               cycle_inc;
            end
       end
endtask

///////////////////////////////////////////////////////////////////////////////////////////
//   send_addr(addr0,0)   send the address "addr0"  , oAle doesnot need to be pull down  //
//   send_addr(addr1,1)   send the last address "addr1"  oAle needs to be pull down      //
/////////////////////////////////////////////////////////////////////////////////////////
task  send_addr;
    input[7:0] address;
    input      last_addr;
     begin
      if(counter<TWP) begin
      read_flash_en   <= 0; // write to flash
      nf_cle     <= 0;
      nf_ce_n    <= 0;
      nf_we_n    <= 0;
      nf_ale     <= 1;
      write_flash <= address;    
      counter_rst<= 0;
      counter_en <= 1;  
      end
      if(counter>=TWP)
           nf_we_n <= 1'b1; 
      if ( counter==TWC )
           begin
             nf_cle   <= 1'b0;
             counter_rst <= 1'b1;
             counter_en  <= 1'b0;
             cycle_inc;
            if(last_addr) 
             nf_ale<=0;
             
           end
     end
endtask


////////////////read byte module signal ///////////////////

read_byte read_byte(
           .clk(clk),
           .read_flash(read_flash),
           .read_data_out(read_data_out),
           .ack(ack),
           .read_en(read_en),
           .nf_re_n(nf_re_n)
         );


task  read_byte_task;
       output[7:0]  data;
       
       begin
       read_flash_en <= 1'b1;//
       read_en       <= 1;
       
       if(read_en)
        read_en <=0; //保证read_en只保持一个clk
       
       if(ack) begin
        data         <= read_data_out;
        byte_num     <= byte_num+1;
       end
       if(~ack&ack_d) begin
        cycle        <= cycle<<1;
       end
      end
endtask


endmodule 
