`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/07 16:15:56
// Design Name: 
// Module Name: mips_min_sopc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips_min_sopc(
	input wire clk,
	input wire rst
    );
    
    wire [31:0] inst_addr;
    wire [31:0] inst;
    wire rom_ce;
    
    wire [31:0] ram_addr;
    wire [31:0] ram_data;
    wire [3:0] ram_sel;
    wire ram_we, ram_ce;
    
    wire [31:0] data;
    
    mips mips0(
    	.clk(clk),	.rst(rst),
    	.rom_addr_o(inst_addr),	.rom_data_i(inst),
    	.rom_ce_o(rom_ce),
    	
    	.ram_data_i(data),
    	.ram_addr_o(ram_addr),	.ram_data_o(ram_data),	.ram_sel_o(ram_sel),	.ram_we_o(ram_we),	.ram_ce_o(ram_ce)
    );
    
    inst_rom inst_rom0(
    	.ce(rom_ce),	.addr(inst_addr),	.inst(inst)
    );
    
    data_ram data_ram0(
    	.clk(clk), .addr(ram_addr),	.data_i(ram_data),	.sel(ram_sel),	.we(ram_we),	.ce(ram_ce),
    	.data_o(data)
    );
    
endmodule
