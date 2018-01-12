`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 19:17:07
// Design Name: 
// Module Name: pc_reg
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


module pc_reg(
    input wire rst,
    input wire clk,
    
    input wire [5:0] stall,
    input wire isbranch_id,
    input wire [31:0] new_addr,
    
    output reg [31:0] pc,
    output reg ce
    );
    
    reg [31:0] pc_saved;
    
    always @ (posedge clk)
    	ce <= (rst == 1'b1) ? 1'b0 : 1'b1;
    
    always @ (posedge clk)
    begin
    	if (ce == 1'b0)
    		pc <= 32'h00000000;
    	else if (stall[0] == 1'b0)
    	begin
    		pc <= pc + 4'h4;
    		pc_saved <= pc + 4'h4;
    	end
    end
    
    always @ (*)
    begin
    	if(isbranch_id == 1'b1)
    		pc = new_addr;
    	else if (isbranch_id == 1'b0)
    		pc = pc_saved;
    end
endmodule
