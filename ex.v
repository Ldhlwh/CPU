`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 22:51:17
// Design Name: 
// Module Name: ex
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
`include "defines.v"

module ex(
	input wire rst,
	
	input wire [6:0] opcode_i,
	input wire [14:12] funct3_i,
	input wire [31:25] funct7_i,
	input wire [31:0] reg1_i, reg2_i,
	input wire [4:0] wd_i,
	input wire wreg_i,
	input wire [11:0] offset,	//only used for STORE inst
	
	output reg [4:0] wd_o,
	output reg wreg_o,
	output reg [31:0] wdata_o,
	
	output reg stallreq,
	output reg [6:0] opcode_o,	//only used for LOAD / STORE inst
	output reg [14:12] funct3_o,	//only used for LOAD / STORE inst
	output reg [31:0] mem_addr,
	output reg [31:0] mem_reg_data
    );
    
    wire [31:0] reg2_i_mux;
    wire [31:0] result_sum;
    wire reg1_lt_reg2;
    
    assign reg2_i_mux = ((funct3_i == `FUNCT3_SUB) || (funct3_i == `FUNCT3_SLT)) ? (~reg2_i) + 1 : reg2_i;
    assign result_sum = reg1_i + reg2_i_mux;
    assign reg1_lt_reg2 = (funct3_i == `FUNCT3_SLT) ? ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31]) || (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);
    
    always @ (*)
    begin
    	stallreq = 1'b0;
    	wd_o = wd_i;
    	wreg_o = wreg_i;
    	opcode_o = 7'b0000000;
    	funct3_o = 3'b000;
    	if (rst == 1'b1)
    		wdata_o = 32'h00000000;
    	else
    	begin
    		case (opcode_i)
    			`OP_OP_IMM:
    			begin
    				case (funct3_i)
    					`FUNCT3_ANDI:
    						wdata_o = reg1_i & reg2_i;
    					`FUNCT3_ORI:
    						wdata_o = reg1_i | reg2_i;
    					`FUNCT3_XORI:
    						wdata_o = reg1_i ^ reg2_i;
    					`FUNCT3_ADDI:
    						wdata_o = reg1_i + reg2_i;
    					`FUNCT3_SLTI:
    						wdata_o = reg1_lt_reg2;
    					`FUNCT3_SLTIU:
    						wdata_o = reg1_lt_reg2;
    					`FUNCT3_SLLI:
    						wdata_o = reg1_i << reg2_i[4:0];
    					`FUNCT3_SRLI:
    					begin
    						case (funct7_i)
    							`FUNCT7_SRLI:
    								wdata_o = reg1_i >> reg2_i[4:0];
    							`FUNCT7_SRAI:
    								wdata_o = ({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4:0]})) | (reg1_i >> reg2_i[4:0]);
       						endcase
    					end
    					default:
    						wdata_o = 32'h00000000;
    				endcase
    			end
    			
    			`OP_LUI:
    				wdata_o = reg1_i;
    				
    			`OP_AUIPC:
    				wdata_o = reg1_i;
    			
    			`OP_OP:
    			begin
    				case (funct3_i)
    					`FUNCT3_ADD:
    					begin
    						case (funct7_i)
    							`FUNCT7_ADD:
    								wdata_o = reg1_i + reg2_i;
    							`FUNCT7_SUB:
    								wdata_o = result_sum;
    						endcase
    					end
    					`FUNCT3_SLT:
    						wdata_o = reg1_lt_reg2;
    					`FUNCT3_SLTU:
    						wdata_o = reg1_lt_reg2;
    					`FUNCT3_AND:
    						wdata_o = reg1_i & reg2_i;
    					`FUNCT3_OR:
    						wdata_o = reg1_i | reg2_i;
    					`FUNCT3_XOR:
    						wdata_o = reg1_i ^ reg2_i;
    					`FUNCT3_SLL:
    						wdata_o = reg1_i << reg2_i[4:0];
    					`FUNCT3_SRL:
    					begin
    						case (funct7_i)
    							`FUNCT7_SRL:
									wdata_o = reg1_i >> reg2_i[4:0];
								`FUNCT7_SRA:
									wdata_o = ({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4:0]})) | (reg1_i >> reg2_i[4:0]);
    						endcase
    					end
       				endcase
    			end
    			
    			`OP_JAL:
    				wdata_o = reg1_i;
    				
    			`OP_JALR:
    				wdata_o = reg1_i;
    				
    			`OP_LOAD:
    			begin
    				mem_addr = reg1_i + reg2_i;
    				opcode_o = opcode_i;
    				funct3_o = funct3_i;
    			end
    			
    			`OP_STORE:
    			begin
    				mem_reg_data = reg2_i;
    				mem_addr = reg1_i + offset;
    				opcode_o = opcode_i;
    				funct3_o = funct3_i;
    			end
    				
				default:
				wdata_o = 32'h00000000;
			endcase
    	end
    end
    
    
endmodule
