`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/10 14:02:32
// Design Name: 
// Module Name: ctrl
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


module ctrl(
	input wire rst,
	input wire stallreq_from_id,
	input wire stallreq_from_ex,
	output reg [5:0] stall
    );
    
    always @ (*)
    begin
    	if (rst == 1'b1)
    		stall = 6'b000000;
    	else if (stallreq_from_ex == 1'b1)
    		stall = 6'b001111;
    	else if (stallreq_from_id == 1'b1)
    		stall = 6'b000111;
    	else
    		stall = 6'b000000;
    end
    
    
endmodule
