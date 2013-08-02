module buffer_ram
        (
        clk,
        
        cpu_wr_ram_en, //cpu дFPGA�ڲ�ramʹ���ź�,�ߵ�ƽ��Ч
        cpu_wr_ram_addr,//cpuдFPGA�ڲ�ram��ַ
        cpu_wr_ram_data,//
        cpu_rd_ram_data,
        
        flash_wr_ram_en,
        flash_to_ram_addr,
        flash_to_ram_data,
        ram_to_flash_data
       );
       
input                clk; 
 
input                cpu_wr_ram_en;
input       [9:0]    cpu_wr_ram_addr;//4kB,1024*32bits ���ڲ�ram��С
input       [31:0]   cpu_wr_ram_data;
output      [31:0]   cpu_rd_ram_data;

input       [31:0]   flash_to_ram_data;
input                flash_wr_ram_en;
input       [9:0]    flash_to_ram_addr;
output      [31:0]   ram_to_flash_data;

       
flash_dualram buffer_ram(
                         .addra(cpu_wr_ram_addr),
                         .addrb(flash_to_ram_addr),
                         .clka(clk),
                         .clkb(clk),
                         .dina(cpu_wr_ram_data),
                         .dinb(flash_to_ram_data),
                         .douta(cpu_rd_ram_data),
                         .doutb(ram_to_flash_data),
                         .wea(cpu_wr_ram_en),
                         .web(flash_wr_ram_en)
                         );
       
endmodule 
