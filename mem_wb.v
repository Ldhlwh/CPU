`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 23:16:58
// Design Name: 
// Module Name: mem_wb
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


module mem_wb(
	input wire clk,
	input wire rst,
	
	input wire [4:0] mem_wd,
	input wire mem_wreg,
	input wire [31:0] mem_wdata,
	
	input wire [5:0] stall,
	
	output reg [4:0] wb_wd,
	output reg wb_wreg,
	output reg [31:0] wb_wdata
    );
    
    always @ (posedge clk)
    begin
    	if ((rst == 1'b1) || (stall[4] == 1'b1 && stall[5] == 1'b0))
    	begin
    		wb_wd <= 5'b00000;
    		wb_wreg <= 1'b0;
    		wb_wdata <= 32'h00000000; 
    	end
    	else if (stall[4] == 1'b0)
    	begin
    		wb_wd <= mem_wd;
    		wb_wreg <= mem_wreg;
    		wb_wdata <= mem_wdata;
    	end
    end
    
    
endmodule
