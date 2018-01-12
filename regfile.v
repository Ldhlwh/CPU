`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/06 19:36:16
// Design Name: 
// Module Name: regfile
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


module regfile(
	input wire clk,
	input wire rst,
	
	input wire we,
	input wire [4:0] waddr,
	input wire [31:0] wdata,
	
	input wire re1,
	input wire [4:0] raddr1,
	output reg [31:0] rdata1,
	
	input wire re2,
	input wire [4:0] raddr2,
	output reg [31:0] rdata2
    );
    
    reg [31:0] regs [31:0];
    
    initial
    	regs[0] = 32'h00000000;
    
    always @ (*)
    begin
    	if (rst == 1'b0)
    	begin
    		if ((we == 1'b1) && (waddr != 5'b00000))
    		begin
    			regs[waddr] = wdata;
    		end
    	end
    end
    
    always @ (*)
    begin
    	if (rst == 1'b1)
    	begin
    		rdata1 = 32'h00000000;
    	end
    	else if (raddr1 == 5'b00000)
    	begin
    		rdata1 = 32'h00000000;
    	end
    	else if ((raddr1 == waddr) && (we == 1'b1) && (re1 == 1'b1))
    	begin
    		rdata1 = wdata;
    	end
    	else if (re1 == 1'b1)
    	begin
    		rdata1 = regs[raddr1];
    	end
    	else
    	begin
    		rdata1 = 32'h00000000;
    	end
    end
    	
    always @ (*)
	begin
		if (rst == 1'b1)
			rdata2 = 32'h00000000;
		else if (raddr2 == 5'b00000)
			rdata2 = 32'h00000000;
		else if ((raddr2 == waddr) && (we == 1'b1) && (re2 == 1'b1))
			rdata2 = wdata;
		else if (re2 == 1'b1)
			rdata2 = regs[raddr2];
		else
			rdata2 = 32'h00000000;
	end
    
endmodule
