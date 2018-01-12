`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 19:52:08
// Design Name: 
// Module Name: id
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
module id(
	input wire rst,
	input wire [31:0] pc_i,
	input wire [31:0] inst_i,
	input wire [31:0] reg1_data_i, reg2_data_i,
	
	input wire ex_wreg_i,
	input wire [31:0] ex_wdata_i,
	input wire [4:0] ex_wd_i,
	
	input wire mem_wreg_i,
	input wire [31:0] mem_wdata_i,
	input wire [4:0] mem_wd_i,
	
	input wire [6:0] ex_opcode_i,
	
	output reg reg1_read_o, reg2_read_o,
	output reg [4:0] reg1_addr_o, reg2_addr_o,
	
	output reg [6:0] opcode,
	output reg [14:12] funct3,
	output reg [31:25] funct7,
	output reg [31:0] reg1_o, reg2_o,
	output reg [4:0] wd_o,
	output reg wreg_o,
	
	output wire stallreq,
	output reg isbranch,
	output reg [31:0] branch_addr,
	
	output reg [11:0] offset	//Only used for STORE inst
    );
    
    
    reg [31:0] imm;
    reg instvalid;
    //reg reg1_rdy, reg2_rdy;
    
    wire [31:0] reg2_o_mux;
	wire [31:0] result_sum;
	wire reg1_lt_reg2;
		
	assign reg2_o_mux = ((inst_i[14:12] == `FUNCT3_BGE) || (inst_i[14:12] == `FUNCT3_BLT)) ? (~reg2_o) + 1 : reg2_o;
	assign result_sum = reg1_o + reg2_o_mux;
	assign reg1_lt_reg2 = ((inst_i[14:12] == `FUNCT3_BLT) || (inst_i[14:12] == `FUNCT3_BGE)) ? ((reg1_o[31] && !reg2_o[31]) || (!reg1_o[31] && !reg2_o[31] && result_sum[31]) || (reg1_o[31] && reg2_o[31] && result_sum[31])) : (reg1_o < reg2_o);
    
    reg stallreq_for_reg1_loadrelate;
    reg stallreq_for_reg2_loadrelate;
    
    wire pre_inst_is_load;
    
    assign pre_inst_is_load = (ex_opcode_i == `OP_LOAD) ? 1'b1 : 1'b0;
    
    always @ (*)
    begin
    	if (rst == 1'b1)
    	begin
    		opcode = 7'b0000000;
    		funct3 = 3'b000;
    		funct7 = 7'b0000000;
    		wd_o = 5'b00000;
    		wreg_o = 1'b0;
    		instvalid = 1'b0;
    		reg1_read_o = 1'b0;
    		reg2_read_o = 1'b0;
    		reg1_addr_o = 5'b00000;
    		reg2_addr_o = 5'b00000;
    		imm = 32'h00000000;
    		isbranch = 1'b0;
    		branch_addr = 32'h00000000;
    		offset = 12'h000;
    	end
    	else
    	begin
    		opcode = inst_i[6:0];
    		funct3 = inst_i[14:12];
    		funct7 = inst_i[31:25];
    		wd_o = inst_i[11:7];
    		reg1_addr_o = inst_i[19:15];
    		reg2_addr_o = inst_i[24:20];
    		imm = 32'h00000000;
    		isbranch = 1'b0;
    		branch_addr = 32'h00000000;
    		offset = 12'h000;
    	end
    	case (inst_i[6:0])
    		`OP_OP_IMM:
    		begin
    			if ((inst_i[14:12] == `FUNCT3_ORI) || (inst_i[14:12] == `FUNCT3_ANDI) || (inst_i[14:12] == `FUNCT3_XORI) || (inst_i[14:12] == `FUNCT3_ADDI) || (inst_i[14:12] == `FUNCT3_SLTI) || (inst_i[14:12] == `FUNCT3_SLTIU))
				begin
					wreg_o = 1'b1;
					reg1_read_o = 1'b1;
					reg2_read_o = 1'b0;
					imm = {{20{inst_i[31]}}, inst_i[31:20]};
					instvalid = 1'b1;
				end
				else if ((inst_i[14:12] == `FUNCT3_SLLI) || (inst_i[14:12] == `FUNCT3_SRLI) || (inst_i[14:12] == `FUNCT3_SRAI))
				begin
					wreg_o = 1'b1;
					reg1_read_o = 1'b1;
					reg2_read_o = 1'b0;
					imm = {{27{inst_i[24]}}, inst_i[24:20]};
					instvalid = 1'b1;
				end
    		end
    		
    		`OP_OP:
    		begin
    			wreg_o = 1'b1;
    			reg1_read_o = 1'b1;
    			reg2_read_o = 1'b1;
    			instvalid = 1'b1;
    		end
    		
    		`OP_LUI:
    		begin
    			wreg_o = 1'b1;
    			reg1_read_o = 1'b0;
    			reg2_read_o = 1'b0;
    			imm = {inst_i[31:12], 12'h000};
    			instvalid = 1'b1;
    		end
    		
    		`OP_AUIPC:
    		begin
    			wreg_o = 1'b1;
    			reg1_read_o = 1'b0;
    			reg2_read_o = 1'b0;
    			imm = {inst_i[31:12], 12'h000} + pc_i;
    			instvalid = 1'b1;
    		end
    		
    		`OP_JAL:
    		begin
    			wreg_o = 1'b1;
    			reg1_read_o = 1'b0;
    			reg2_read_o = 1'b0;
    			imm = pc_i + 4;
    			$display("pci=%d A", pc_i);
    			isbranch = 1'b1;
    			branch_addr = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0} + pc_i;
    			instvalid = 1'b1;
    		end
    		
    		`OP_JALR:
    		begin
    			wreg_o = 1'b1;
    			reg1_read_o = 1'b1;
    			reg2_read_o = 1'b0;
    			imm = pc_i + 4;
    			$display("pci=%d B", pc_i);
    			isbranch = 1'b1;
    			branch_addr = {{20{inst_i[31]}}, inst_i[31:20]} + pc_i;
    			instvalid = 1'b1;
    		end
    		
    		`OP_LOAD:
    		begin
    			wreg_o = 1'b1;
    			reg1_read_o = 1'b1;
    			reg2_read_o = 1'b0;
    			imm = {{20{inst_i[31]}}, inst_i[31:20]};
    			instvalid = 1'b1;
    		end
    		
    		`OP_STORE:
    		begin
    			wreg_o = 1'b0;
    			reg1_read_o = 1'b1;
    			reg2_read_o = 1'b1;
    			offset = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
    			instvalid = 1'b1;
    		end
    		
    		`OP_BRANCH:
    		begin
				wreg_o = 1'b0;
				reg1_read_o = 1'b1;
				reg2_read_o = 1'b1;
				instvalid = 1'b1;
    		end
    	endcase
    end
    
    always @ (*)
    begin
    	$display("pc=%d, reg1_o=%d, reg2_o=%d, isbranch=%b", pc_i, reg1_o, reg2_o, isbranch);
    	if (opcode == `OP_BRANCH)
    	begin
    		case (funct3)
    			`FUNCT3_BEQ:
    			begin
    				if (reg1_o == reg2_o)
    				begin
    					isbranch = 1'b1;
    					branch_addr = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
    				end
    				else
    					isbranch = 1'b0;
    			end
    			`FUNCT3_BNE:
				begin
					if (reg1_o != reg2_o)
					begin
						isbranch = 1'b1;
						branch_addr = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
					end
					else
						isbranch = 1'b0;
				end
				`FUNCT3_BLT:
				begin
					if (reg1_lt_reg2 == 1'b1)
					begin
						isbranch = 1'b1;
						branch_addr = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
					end
					else
						isbranch = 1'b0;
				end
				`FUNCT3_BLTU:
				begin
					if (reg1_lt_reg2 == 1'b1)
					begin
						isbranch = 1'b1;
						branch_addr = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
					end
					else
						isbranch = 1'b0;
				end
				`FUNCT3_BGE:
				begin
					if (reg1_lt_reg2 == 1'b0)
					begin
						isbranch = 1'b1;
						branch_addr = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
					end
					else
						isbranch = 1'b0;
				end
				`FUNCT3_BGEU:
				begin
					if (reg1_lt_reg2 == 1'b0)
					begin
						isbranch = 1'b1;
						branch_addr = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0} + pc_i;
					end
					else
						isbranch = 1'b0;
				end
    		endcase
    	end
    	$display("And now isbranch = %b", isbranch);
    end
    
    always @ (*)
   	begin
   		stallreq_for_reg1_loadrelate = 1'b0;
    	if (rst == 1'b1)
    		reg1_o = 32'h00000000;
    	else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && ex_wd_i != 5'b00000 && reg1_read_o == 1'b1)
    		stallreq_for_reg1_loadrelate = 1'b1;
    	else if (reg1_read_o == 1'b1)
    	begin
    		if ((ex_wreg_i == 1'b1) && (ex_wd_i == reg1_addr_o))
    			reg1_o = ex_wdata_i;
    		else if ((mem_wreg_i == 1'b1) && (mem_wd_i == reg1_addr_o))
    			reg1_o = mem_wdata_i;
    		else
    			reg1_o = reg1_data_i;
    		//reg1_rdy = 1'b1;
       	end
    	else if (reg1_read_o == 1'b0)
    	begin
    		reg1_o = imm;
    		//reg1_rdy = 1'b1;
    	end
    	else
    		reg1_o = 32'h00000000;
    end
    
    always @ (*)
    begin
    	stallreq_for_reg2_loadrelate = 1'b0;
		if (rst == 1'b1)
			reg2_o = 32'h00000000;
		else if (pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && ex_wd_i != 5'b00000 && reg2_read_o == 1'b1)
			stallreq_for_reg2_loadrelate = 1'b1;
		else if (reg2_read_o == 1'b1)
		begin
			if((ex_wreg_i == 1'b1) && (ex_wd_i == reg2_addr_o))
				reg2_o = ex_wdata_i;
			else if ((mem_wreg_i == 1'b1) && (mem_wd_i == reg2_addr_o))
				reg2_o = mem_wdata_i;
			else
				reg2_o = reg2_data_i;
			//reg2_rdy = 1'b1;
		end
		else if (reg2_read_o == 1'b0)
		begin
			reg2_o = imm;
			//reg2_rdy = 1'b1;
		end
		else
			reg2_o = 32'h00000000;
    end
    
    assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
    
endmodule
