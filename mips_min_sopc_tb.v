`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/07 16:33:02
// Design Name: 
// Module Name: mips_min_sopc_tb
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


module mips_min_sopc_tb(
    );
    
    reg CLOCK_50;
    reg rst;
    
    initial
    begin
    	CLOCK_50 = 1'b0;
    	forever #10 CLOCK_50 = ~CLOCK_50;
    end
    
    initial
    begin
    	rst = 1'b1;
    	#195 rst = 1'b0;
    	#2000 $stop;
    end
    
    mips_min_sopc mips_min_sopc0(
    	.clk(CLOCK_50),
    	.rst(rst)
    );
    
endmodule
