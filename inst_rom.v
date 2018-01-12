`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/07 15:53:49
// Design Name: 
// Module Name: inst_rom
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


module inst_rom(
	input wire ce,
	input wire [31:0] addr,
	output reg [31:0] inst
    );
    
    reg [31:0] inst_mem [0:1023];
    
    initial $readmemh ("C:/Users/qydyx/Desktop/inst_rom.data", inst_mem);
    
    always @ (*)
    begin
    	if (ce == 1'b0)
    		inst = 32'h00000000;
    	else
    		inst = {inst_mem[addr[11:2]][7:0], inst_mem[addr[11:2]][15:8], inst_mem[addr[11:2]][23:16], inst_mem[addr[11:2]][31:24]};
    end
    
endmodule
