module nand_flash_top(
                        clk,
                        cpu_wr_ram_en,
                        cpu_wr_ram_addr,//4kB,1024*32bits 的内部ram大小
                        cpu_wr_ram_data,
                        cpu_rd_ram_data,
                        
                        nf_addr0,
                        nf_addr1,
                        nfcr,
                        
                        nf_cle,
                        nf_ale,
                        nf_ce_n,
                        nf_re_n,
                        nf_we_n,
                        r,
                        
                        id,
								status,
                        
                        read_flash_en,
                        read_flash,
                        write_flash,
                        
                        cycle,
                        done
                        
                        
                      );
                      
input                clk;                      
input                cpu_wr_ram_en;
input       [9:0]    cpu_wr_ram_addr;//4kB,1024*32bits 的内部ram大小
input       [31:0]   cpu_wr_ram_data;
input       [7:0]    nfcr;
input       [31:0]   nf_addr0;
input       [31:0]   nf_addr1;
input       [7:0]    read_flash;
input                r;


output      [31:0]   cpu_rd_ram_data;

output               nf_cle;
output               nf_ale;
output               nf_ce_n;
output               nf_re_n;
output               nf_we_n;
output      [31:0]   id;      //id的高32位
output      [7:0]    status;
wire        [39:0]   full_id; //40位完整ID
assign       id     = full_id[39:8];
output      [17:0]   cycle;

output      [7:0]    write_flash;
output               read_flash_en;

wire        [31:0]  ram_to_flash_data;


output               done;
wire                 done;

/////FPGA 内部作为flash数据缓存的dual-ram//////////////
wire   [9:0]  flash_to_ram_addr;
wire   [31:0] flash_to_ram_data;
wire           flash_wr_ram_en;
buffer_ram buffer_ram
        (
        .clk(clk),
        
        .cpu_wr_ram_en(cpu_wr_ram_en),     //cpu 写FPGA内??ram使能信号,高?缙接行?        
        .cpu_wr_ram_addr(cpu_wr_ram_addr), //cpu写FPGA内部ram地址
        .cpu_wr_ram_data(cpu_wr_ram_data), //
        .cpu_rd_ram_data(cpu_rd_ram_data),
        
        .flash_wr_ram_en(flash_wr_ram_en),
        .flash_to_ram_addr(flash_to_ram_addr),
        .flash_to_ram_data(flash_to_ram_data),
        .ram_to_flash_data(ram_to_flash_data)
       );
       

/////nand flash 控制时序生成///////////////////////////       
controller controller(
                    .clk(clk),
                    .nf_addr0(nf_addr0),// nand flash address0
                    .nf_addr1(nf_addr1),
                    .r(r),
                    .done(done),
                    
                    .nfcr(nfcr),
          
                /////nand flash control pad////////
                    .nf_cle(nf_cle),
                    .nf_ale(nf_ale),
                    .nf_ce_n(nf_ce_n),
                    .nf_re_n(nf_re_n),
                    .nf_we_n(nf_we_n),
          
                ////flash to dual-ram signal//////////
                    .flash_wr_ram_en(flash_wr_ram_en),
                    .flash_to_ram_addr(flash_to_ram_addr),
                    .flash_to_ram_data(flash_to_ram_data),
                    .ram_to_flash_data(ram_to_flash_data),
                    
                    .read_flash_en(read_flash_en),
                    .read_flash(read_flash),
                    .write_flash(write_flash),
                    
                  
                    .id(full_id),
						  .status(status)
        
                 );
                      
endmodule 
