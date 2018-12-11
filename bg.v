`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: 
// 
// Create Date:    12:55:02 11/19/2018 
// Design Name: 
// Module Name:    bg 
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
module bg(
	input clk,
    input vsync,
    output [23:0] pixel
    );				 
	wire [7:0] green = 164;
	wire [7:0] blue = 255;
	reg [7:0] red = 0;
	reg up = 1;
	reg old_vsync;
	
	always @(posedge clk) begin
		old_vsync <= vsync;
		if (~old_vsync && vsync) begin
			if (up) red <= red + 1;
			else red <= red - 1;
			if (red + 1 == 255 && up) up <= 0;
			else if (red == 1 && ~up) up <= 1;
		end
	end
	
	assign pixel = {red, green, blue};
	
endmodule
