`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:10:15 11/19/2018 
// Design Name: 
// Module Name:    randombitsgenerator 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module randombitsgenerator(
    input clk,
	 input data,
    output [15:0] randomnumber
    );
	 
	reg [15:0] shift_reg = 16'hFF_FF; // initial value

	always @(posedge clk) begin // reset all counters
		shift_reg[0] <= shift_reg[15] ^ data;
		shift_reg[1] <= shift_reg[0];
		shift_reg[2] <= shift_reg[1] ^ shift_reg[15] ^ data;
		shift_reg[14:3] <= shift_reg[13:2];
		shift_reg[15] <= shift_reg[14] ^ shift_reg[15] ^ data;
	end

	assign randomnumber = shift_reg;
	
endmodule
