`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 23:09:57
// Design Name: 
// Module Name: ex_mem
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


module ex_mem(
	input wire clk,
	input wire rst,
	
	input wire [4:0] ex_wd,
	input wire ex_wreg,
	input wire [31:0] ex_wdata,
	
	input wire [5:0] stall,
	input wire [6:0] ex_opcode,
	input wire [14:12] ex_funct3,
	input wire [31:0] ex_mem_addr,
	input wire [31:0] ex_mem_reg_data,
	
	output reg [4:0] mem_wd,
	output reg mem_wreg,
	output reg [31:0] mem_wdata,
	output reg [6:0] mem_opcode,
	output reg [14:12] mem_funct3,
	output reg [31:0] mem_mem_addr,
	output reg [31:0] mem_mem_reg_data
    );
    
    always @ (posedge clk)
    begin
    	if ((rst == 1'b1) || (stall[3] == 1'b1 && stall[4] == 1'b0))
    	begin
    		mem_wd <= 5'b00000;
    		mem_wreg <= 1'b0;
    		mem_wdata <= 32'h00000000;
    		mem_opcode <= 7'b0000000;
    		mem_funct3 <= 3'b000;
    		mem_mem_addr <= 32'h00000000;
    		mem_mem_reg_data <= 32'h00000000;
    	end
    	else if (stall[3] == 1'b0)
    	begin
    		mem_wd <= ex_wd;
    		mem_wreg <= ex_wreg;
    		mem_wdata <= ex_wdata;
    		mem_opcode <= ex_opcode;
    		mem_funct3 <= ex_funct3;
    		mem_mem_addr <= ex_mem_addr;
    		mem_mem_reg_data <= ex_mem_reg_data;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
    	end
    end
    
endmodule
