`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 23:21:15
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,
	input wire rst,
	
	input wire [31:0] rom_data_i,
	input wire [31:0] ram_data_i,
	
	output wire [31:0] rom_addr_o,
	output wire rom_ce_o,
	output wire [31:0] ram_addr_o,
	output wire [31:0] ram_data_o,
	output wire ram_we_o,
	output wire [3:0] ram_sel_o,
	output wire ram_ce_o
    );
    
    wire [31:0] pc, id_pc_i;
    wire [31:0] id_inst_i;	//between IF/ID and ID
    
    wire [6:0] id_opcode_o;
    wire [14:12] id_funct3_o;
    wire [31:25] id_funct7_o;
    wire [31:0] id_reg1_o, id_reg2_o;
    wire id_wreg_o;
    wire [4:0] id_wd_o;	//between ID and ID/EX
    
    wire [6:0] ex_opcode_i;
    wire [14:12] ex_funct3_i;
    wire [31:25] ex_funct7_i;
    wire [31:0] ex_reg1_i, ex_reg2_i;
    wire ex_wreg_i;
    wire [4:0] ex_wd_i;	//between ID/EX and EX
    
    wire ex_wreg_o;
    wire [4:0] ex_wd_o;
    wire [31:0] ex_wdata_o;	//between EX and EX/MEM
    
    wire mem_wreg_i;
    wire [4:0] mem_wd_i;
    wire [31:0] mem_wdata_i;	//between EX/MEM and MEM
    
    wire mem_wreg_o;
    wire [4:0] mem_wd_o;
    wire [31:0] mem_wdata_o;	//between MEM and MEM/WB
    
    wire wb_wreg_i;
    wire [4:0] wb_wd_i;
    wire [31:0] wb_wdata_i;	//between MEM/WB and WB
    
    wire reg1_read, reg2_read;
    wire [31:0] reg1_data, reg2_data;
    wire [4:0] reg1_addr, reg2_addr;	//between ID amd RegFile
    
    wire stallreq_id, stallreq_ex;
    wire [5:0] ctrl_stall;	//about stall in CTRL
    
    wire isbranch;
    wire [31:0] branch_new_addr;
    
    wire [12:0] id_offset, ex_offset;
    wire [6:0] ex_opcode, mem_opcode;
    wire [14:12] ex_funct3, mem_funct3;
    wire [31:0] ex_mem_addr, mem_mem_addr;
    wire [31:0] ex_mem_reg_data, mem_mem_reg_data;
    
    
    pc_reg pc_reg0(
    	.clk(clk),	.rst(rst),	.pc(pc),	.ce(rom_ce_o),
    	.stall(ctrl_stall),
    	.isbranch_id(isbranch),
    	.new_addr(branch_new_addr)
    );
    
    assign rom_addr_o = pc;
    
    if_id if_id0(
    	.clk(clk),	.rst(rst),	.if_pc(pc),
    	.if_inst(rom_data_i),	.id_pc(id_pc_i),	.id_inst(id_inst_i),
		.stall(ctrl_stall)
    );
    
    id id0(
    	.rst(rst),	.pc_i(id_pc_i),	.inst_i(id_inst_i),
    	.reg1_data_i(reg1_data),	.reg2_data_i(reg2_data),
    	.reg1_read_o(reg1_read),	.reg2_read_o(reg2_read),
    	.reg1_addr_o(reg1_addr),	.reg2_addr_o(reg2_addr),
    	.opcode(id_opcode_o),	.funct3(id_funct3_o),	.funct7(id_funct7_o),
    	.reg1_o(id_reg1_o),	.reg2_o(id_reg2_o),
    	.wd_o(id_wd_o),	.wreg_o(id_wreg_o),
    	
    	.ex_wdata_i(ex_wdata_o),	.ex_wd_i(ex_wd_o),	.ex_wreg_i(ex_wreg_o),
    	.mem_wdata_i(mem_wdata_o),	.mem_wd_i(mem_wd_o),	.mem_wreg_i(mem_wreg_o),	//forwarding
    	
    	.stallreq(stallreq_id),
    	.isbranch(isbranch),
    	.branch_addr(branch_new_addr),
    	
    	.offset(id_offset),
    	.ex_opcode_i(ex_opcode)
    );
    
    regfile regfile1(
    	.clk(clk),	.rst(rst),
    	.we(wb_wreg_i),	.waddr(wb_wd_i),	.wdata(wb_wdata_i),
    	.re1(reg1_read),	.raddr1(reg1_addr),	.rdata1(reg1_data),
    	.re2(reg2_read),	.raddr2(reg2_addr),	.rdata2(reg2_data)
	);
	
	id_ex id_ex0(
		.clk(clk),	.rst(rst),
		.id_opcode(id_opcode_o),	.id_funct3(id_funct3_o),	.id_funct7(id_funct7_o),
		.id_reg1(id_reg1_o),	.id_reg2(id_reg2_o),
		.id_wd(id_wd_o),	.id_wreg(id_wreg_o),
		
		.ex_opcode(ex_opcode_i),	.ex_funct3(ex_funct3_i),	.ex_funct7(ex_funct7_i),
		.ex_reg1(ex_reg1_i),	.ex_reg2(ex_reg2_i),	.ex_wd(ex_wd_i),	.ex_wreg(ex_wreg_i),
		.stall(ctrl_stall),
		
		.id_offset(id_offset),	.ex_offset(ex_offset)
	);
	
	ex ex0(
		.rst(rst),
		.opcode_i(ex_opcode_i),	.funct3_i(ex_funct3_i), .funct7_i(ex_funct7_i),
		.reg1_i(ex_reg1_i),	.reg2_i(ex_reg2_i),	.wd_i(ex_wd_i),	.wreg_i(ex_wreg_i),
		.wd_o(ex_wd_o),	.wreg_o(ex_wreg_o),	.wdata_o(ex_wdata_o),
		
		.stallreq(stallreq_ex),
		.offset(ex_offset),
		.opcode_o(ex_opcode),	.funct3_o(ex_funct3),
		.mem_addr(ex_mem_addr),	.mem_reg_data(ex_mem_reg_data)
	);
	
	ex_mem ex_mem0(
		.clk(clk),	.rst(rst),
		.ex_wd(ex_wd_o),	.ex_wreg(ex_wreg_o),	.ex_wdata(ex_wdata_o),
		.mem_wd(mem_wd_i),	.mem_wreg(mem_wreg_i),	.mem_wdata(mem_wdata_i),
		.stall(ctrl_stall),
		
		.ex_opcode(ex_opcode),	.ex_funct3(ex_funct3),
		.ex_mem_addr(ex_mem_addr),	.ex_mem_reg_data(ex_mem_reg_data),
		.mem_opcode(mem_opcode),	.mem_funct3(mem_funct3),
		.mem_mem_addr(mem_mem_addr),	.mem_mem_reg_data(mem_mem_reg_data)
	);    
	
	mem mem0(
		.rst(rst),
		.wd_i(mem_wd_i),	.wreg_i(mem_wreg_i),	.wdata_i(mem_wdata_i),
		.wd_o(mem_wd_o),	.wreg_o(mem_wreg_o),	.wdata_o(mem_wdata_o),
		
		.opcode(mem_opcode),	.funct3(mem_funct3),
		.mem_addr(mem_mem_addr),	.mem_reg_data(mem_mem_reg_data),
		
		.mem_data(ram_data_i),
		
		.mem_addr_o(ram_addr_o),	.mem_we_o(ram_we_o),	.mem_sel_o(ram_sel_o),
		.mem_reg_data_o(ram_data_o),	.mem_ce_o(ram_ce_o)
	);
	
	mem_wb mem_wb0(
		.clk(clk),	.rst(rst),
		.mem_wd(mem_wd_o),	.mem_wreg(mem_wreg_o),	.mem_wdata(mem_wdata_o),
		.wb_wd(wb_wd_i),	.wb_wreg(wb_wreg_i),	.wb_wdata(wb_wdata_i),
		.stall(ctrl_stall)
	);
	
	ctrl ctrl0(
		.rst(rst),
		.stallreq_from_id(stallreq_id),	.stallreq_from_ex(stallreq_ex),
		.stall(ctrl_stall)
	);
endmodule
