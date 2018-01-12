`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 22:40:49
// Design Name: 
// Module Name: id_ex
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


module id_ex(
	input wire clk,
	input wire rst,
	
	input wire [6:0] id_opcode,
	input wire [14:12] id_funct3,
	input wire [31:25] id_funct7,
	input wire [31:0] id_reg1, id_reg2,
	input wire [4:0] id_wd,
	input wire id_wreg,
	
	input wire [5:0] stall,
	input wire [11:0] id_offset,
	
	output reg [6:0] ex_opcode,
	output reg [14:12] ex_funct3,
	output reg [31:25] ex_funct7,
	output reg [31:0] ex_reg1,
	output reg [31:0] ex_reg2,
	output reg [4:0] ex_wd,
	output reg ex_wreg,
	output reg [11:0] ex_offset
    );
    
    always @ (posedge clk)
    begin
    	if (rst == 1'b1)
    	begin
    		ex_opcode <= 7'b0000000;
    		ex_funct3 <= 3'b000;
    		ex_funct7 <= 7'b0000000;
    		ex_reg1 <= 32'h00000000;
    		ex_reg2 <= 32'h00000000;
    		ex_wd <= 5'b00000;
    		ex_wreg <= 1'b0;
    		ex_offset <= 12'h000;
    	end
    	else if (stall[2] == 1'b1 && stall[3] == 1'b0)
    	begin
			ex_opcode <= 7'b0000000;
			ex_funct3 <= 3'b000;
			ex_funct7 <= 7'b0000000;
			ex_reg1 <= 32'h00000000;
			ex_reg2 <= 32'h00000000;
			ex_wd <= 5'b00000;
			ex_wreg <= 1'b0;
			ex_offset <= 12'h000;
		end
    	else if (stall[2] == 1'b0)
    	begin
    		ex_opcode <= id_opcode;
    		ex_funct3 <= id_funct3;
    		ex_funct7 <= id_funct7;
    		ex_reg1 <= id_reg1;
    		ex_reg2 <= id_reg2;
    		ex_wd <= id_wd;
    		ex_wreg <= id_wreg;
    		ex_offset <= id_offset;
    	end
    end
endmodule
