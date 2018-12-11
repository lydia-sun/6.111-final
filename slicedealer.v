`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:17:02 12/01/2018 
// Design Name: 
// Module Name:    slicedealer 
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
module slice_dealer(input clk, input appleactive, input orangeactive, input peachactive, input apple_new, input orange_new, input peach_new, input [23:0] cursorpix, input [23:0] applepix, input [23:0] orangepix, input [23:0] peachpix, output reg  applesliced, output reg orangesliced, output reg peachsliced);

	parameter WAIT = 0;
	parameter SLICE = 1;
	reg state_apple;
	reg state_orange;
	reg state_peach;

	always@(posedge clk) begin
		case (state_apple)
			WAIT: begin 
					if (|cursorpix && |applepix) begin applesliced <= 1; state_apple <= SLICE; end
					else applesliced <= 0;
					end
			SLICE: begin 
					if (apple_new && appleactive) begin state_apple <= WAIT; applesliced <= 0; end
					else applesliced <= 1;
					end
			default: state_apple <= SLICE;
		endcase
		case (state_orange)
			WAIT: begin state_orange<= (|cursorpix && |orangepix)? SLICE: WAIT; orangesliced <= 0; end
			SLICE: begin orangesliced <= 1; state_orange <= (orange_new && orangeactive)? WAIT: SLICE; end
			default: state_orange <= WAIT;
		endcase
		case (state_peach)
			WAIT: begin state_peach <= (|cursorpix && |peachpix)? SLICE: WAIT; peachsliced <= 0; end
			SLICE: begin peachsliced <= 1; state_peach <= (peach_new && peachactive)? WAIT: SLICE; end
			default: state_peach <= WAIT;
		endcase
	end
	
	
endmodule
