`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/11 22:56:03
// Design Name: 
// Module Name: data_ram
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


module data_ram(
	input wire clk,
	input wire ce,
	input wire we,
	input wire [31:0] addr,
	input wire [3:0] sel,
	input wire [31:0] data_i,
	
	output reg [31:0] data_o
    );
    
    reg [7:0] data_mem[0:131070];	//128K RAM
    
    always @ (posedge clk)
    begin
    	if (ce == 1'b0)
    		data_o <= 32'h00000000;
    	else if (we == 1'b1)
    	begin
    		if (sel[3] == 1'b1)
    			data_mem[{addr[31:2], 2'b11}] <= data_i[31:24];
    		if (sel[2] == 1'b1)
    			data_mem[{addr[31:2], 2'b10}] <= data_i[23:16];
    		if (sel[1] == 1'b1)
    			data_mem[{addr[31:2], 2'b01}] <= data_i[15:8];
    		if (sel[0] == 1'b1)
    			data_mem[{addr[31:2], 2'b00}] <= data_i[7:0];    	
    	end
    end
    
    always @ (*)
    begin
    	if (ce == 1'b0)
    		data_o = 32'h00000000;
    	else if (we == 1'b0)
    		data_o = {data_mem[{addr[31:2], 2'b11}], data_mem[{addr[31:2], 2'b10}], data_mem[{addr[31:2], 2'b01}], data_mem[{addr[31:2], 2'b00}]};
		else
    		data_o = 32'h00000000;
    end
endmodule
