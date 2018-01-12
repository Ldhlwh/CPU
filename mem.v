`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 23:13:53
// Design Name: 
// Module Name: mem
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


module mem(
	input wire rst,
	
	input wire [4:0] wd_i,
	input wire wreg_i,
	input wire [31:0] wdata_i,
	
	input wire [6:0] opcode,
	input wire [14:12] funct3,
	input wire [31:0] mem_addr,
	input wire [31:0] mem_reg_data,
	
	input wire [31:0] mem_data,
	
	output reg [4:0] wd_o,
	output reg wreg_o,
	output reg [31:0] wdata_o,
	
	output reg [31:0] mem_addr_o,
	output wire mem_we_o, 	// 1 STORE / 0 LOAD
	output reg [3:0] mem_sel_o,
	output reg [31:0] mem_reg_data_o,
	output reg mem_ce_o
    );
    
    reg mem_we;	//1 store, 0 loas
    assign mem_we_o = mem_we;	// STORE 0100011, LOAD 0000011
    
    always @ (*)
    begin
    	if (rst == 1'b1)
    	begin
    		wd_o = 5'b00000;
    		wreg_o = 1'b0;
    		wdata_o = 32'h00000000;
    		mem_addr_o = 32'h00000000;
    		mem_we = 1'b0;
    		mem_sel_o = 4'b0000;
    		mem_reg_data_o = 32'h00000000;
    		mem_ce_o = 1'b0;
    	end
    	else
    	begin
    		wd_o = wd_i;
    		wreg_o = wreg_i;
    		wdata_o = wdata_i;
    		mem_addr_o = 32'h00000000;
			mem_we = 1'b0;
			mem_sel_o = 4'b1111;
			mem_reg_data_o = 32'h00000000;
			mem_ce_o = 1'b0;
			
			case (opcode)
				`OP_LOAD:
				begin
					case (funct3)
						`FUNCT3_LB:
						begin
							mem_addr_o = mem_addr;
							mem_we = 1'b0;
							mem_ce_o = 1'b1;
							case (mem_addr[1:0])
								2'b11:
								begin
									wdata_o = {{24{mem_data[31]}}, mem_data[31:24]};
									mem_sel_o = 4'b1000;
								end
								2'b10:
								begin
									wdata_o = {{24{mem_data[23]}}, mem_data[23:16]};
									mem_sel_o = 4'b0100;
								end
								2'b01:
								begin
									wdata_o = {{24{mem_data[15]}}, mem_data[15:8]};
									mem_sel_o = 4'b0010;
								end
								2'b00:
								begin
									wdata_o = {{24{mem_data[7]}}, mem_data[7:0]};
									mem_sel_o = 4'b0001;
								end
								default:
									wdata_o = 32'h00000000;
							endcase
						end
						
						`FUNCT3_LBU:
						begin
							mem_addr_o = mem_addr;
							mem_we = 1'b0;
							mem_ce_o = 1'b1;
							case (mem_addr[1:0])
								2'b11:
								begin
									wdata_o = {{24'h000000}, mem_data[31:24]};
									mem_sel_o = 4'b1000;
								end
								2'b10:
								begin
									wdata_o = {{24'h000000}, mem_data[23:16]};
									mem_sel_o = 4'b0100;
								end
								2'b01:
								begin
									wdata_o = {{24'h000000}, mem_data[15:8]};
									mem_sel_o = 4'b0010;
								end
								2'b00:
								begin
									wdata_o = {{24'h000000}, mem_data[7:0]};
									mem_sel_o = 4'b0001;
								end
								default:
									wdata_o = 32'h00000000;
							endcase
						end
						
						`FUNCT3_LH:
						begin
							mem_addr_o = mem_addr;
							mem_we = 1'b0;
							mem_ce_o = 1'b1;
							case (mem_addr[1:0])
								2'b10:
								begin
									wdata_o = {{16{mem_data[31]}}, mem_data[31:16]};
									mem_sel_o = 4'b1100;
								end
								2'b00:
								begin
									wdata_o = {{16{mem_data[15]}}, mem_data[15:0]};
									mem_sel_o = 4'b0011;
								end
								default:
									wdata_o = 32'h00000000;
							endcase
						end
						
						`FUNCT3_LHU:
						begin
							mem_addr_o = mem_addr;
							mem_we = 1'b0;
							mem_ce_o = 1'b1;
							case (mem_addr[1:0])
								2'b10:
								begin
									wdata_o = {{16'h0000}, mem_data[31:16]};
									mem_sel_o = 4'b1100;
								end
								2'b00:
								begin
									wdata_o = {{16'h0000}, mem_data[15:0]};
									mem_sel_o = 4'b0011;
								end
								default:
									wdata_o = 32'h00000000;
							endcase
						end
						
						`FUNCT3_LW:
						begin
							mem_addr_o = mem_addr;
							mem_we = 1'b0;
							wdata_o = mem_data;
							mem_sel_o = 4'b1111;
							mem_ce_o = 1'b1;
						end
					endcase
				end
				`OP_STORE:
				begin
					case (funct3)
						`FUNCT3_SB:
						begin
							mem_addr_o = mem_addr;
							mem_we = 1'b1;
							mem_reg_data_o = {4{mem_reg_data[7:0]}};
							mem_ce_o = 1'b1;
							case (mem_addr[1:0])
								2'b00: mem_sel_o = 4'b0001;
								2'b01: mem_sel_o = 4'b0010;
								2'b10: mem_sel_o = 4'b0100;
								2'b11: mem_sel_o = 4'b1000;
								default: mem_sel_o = 4'b0000;							
							endcase
						end
						
						`FUNCT3_SH:
						begin
							mem_addr_o = mem_addr;
							mem_we = 1'b1;
							mem_reg_data_o = {2{mem_reg_data[15:0]}};
							mem_ce_o = 1'b1;
							case (mem_addr[1:0])
								2'b00: mem_sel_o = 4'b0011;
								2'b10: mem_sel_o = 4'b1100;
								default: mem_sel_o = 4'b0000;
							endcase
						end
						
						`FUNCT3_SW:
						begin
							mem_addr_o = mem_addr;
							mem_we = 1'b1;
							mem_reg_data_o = mem_reg_data;
							mem_sel_o = 4'b1111;
							mem_ce_o = 1'b1;
						end
					endcase
				end
				
			endcase
			
			
    	end
    end
endmodule
