`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 19:27:55
// Design Name: 
// Module Name: if_id
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


module if_id(
	input wire clk,
	input wire rst,
	
	input wire [31:0] if_pc,
	input wire [31:0] if_inst,
	
	//input wire isbranch_id,
	
	input wire [5:0] stall,
	
	output reg [31:0] id_pc,
	output reg [31:0] id_inst
    );
    
    always @ (posedge clk)
    begin
    	if ((rst == 1'b1) || (stall[1] == 1'b1 && stall[2] == 1'b0))
		begin
    		id_pc <= 32'h00000000;
    		id_inst <= 32'h00000000;
		end
    	else if (stall[1] == 1'b0)
		begin
    		id_pc <= if_pc;
    		id_inst <= if_inst;
		end
    end
endmodule
