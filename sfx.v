`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:42:12 12/09/2018 
// Design Name: 
// Module Name:    sfx 
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
module sfx(
	input clk,
	input apple_slice,
	input orange_slice,
	input peach_slice,
	input bomb_slice,
	input [1:0] lost_life,
	input busy,
	input [1:0] state_in,
	output reg sound,
	output reg r);
	
	reg old_apple_slice, old_orange_slice, old_peach_slice, old_state;
	reg old_bomb_slice;
	reg [1:0] old_lost_life;
	reg [7:0] old_high_score;
	reg [24:0] counter= 0;
	reg [2:0] state = 0;
	reg [17:0] freq_counter = 0;
//	reg r= 0;
	
	parameter WAIT = 0;
	parameter PLAY_FRUIT = 1;
	parameter PLAY_BOMB = 2;
	parameter PLAY_LIFE = 3;
	parameter PLAY_HIGHSCORE0 = 6;
	parameter PLAY_HIGHSCORE1 = 4;
	parameter PLAY_HIGHSCORE2 = 5;
	
	always @(posedge clk) begin
		old_apple_slice <= apple_slice;
		old_orange_slice <= orange_slice;
		old_peach_slice <= peach_slice;
		old_bomb_slice <= bomb_slice;
		old_lost_life <= lost_life;
		old_state <= state_in;
		case (state)
			WAIT: begin
				if (~old_bomb_slice && bomb_slice) state <= PLAY_BOMB;
				else if (((~old_apple_slice && apple_slice) || (~old_orange_slice && orange_slice) ||
				(~old_peach_slice && peach_slice)) && (old_state == state_in)) state <= PLAY_FRUIT;
				else if (old_lost_life != lost_life && old_lost_life != 3) state <= PLAY_LIFE;
				//else if (busy) state <= PLAY_HIGHSCORE1;
				else state <= WAIT;
				sound <= 0;
				counter <= 0;
				freq_counter <= 0;
			end
			PLAY_FRUIT: begin
				if (counter < 6500000) counter <= counter + 1; // play for 0.1 sec
				else begin
					freq_counter <= 0;
					counter <= 0;
					state <= WAIT;
				end
				if (freq_counter < 30000) begin
					freq_counter <= freq_counter + 1;
				end
				else begin
					freq_counter <= 0;
					sound <= ~sound;
				end
			end
			PLAY_BOMB: begin
				if (busy) r <= 1;
				if (counter < 30000000) counter <= counter + 1; // play for 0.5 sec
				else begin
					counter <= 0;
					freq_counter <= 0;
					state <= r ? PLAY_HIGHSCORE0 : WAIT;
				end
				if (freq_counter < 150000) begin
					freq_counter <= freq_counter + 1;
				end
				else begin
					freq_counter <= 0;
					sound <= ~sound;
				end
			end
			PLAY_LIFE: begin
				if (busy) r <= 1;
				if (counter < 6500000) counter <= counter + 1; // play for 0.5 sec
				else begin
					counter <= 0;
					freq_counter <= 0;
					state <= (r && lost_life == 3) ? PLAY_HIGHSCORE0 : WAIT;
				end
				if (freq_counter < 150000) begin
					freq_counter <= freq_counter + 1;
				end
				else begin
					freq_counter <= 0;
					sound <= ~sound;
				end
			end
			PLAY_HIGHSCORE0: begin
				if (counter < 30000000) counter <= counter + 1; 
				else begin
					counter <= 0;
					freq_counter <= 0;
					state <= PLAY_HIGHSCORE1; end
			end
			PLAY_HIGHSCORE1: begin
				r <= 0;
				if (counter < 15000000) counter <= counter + 1; // play for 0.1 sec
				else begin
					freq_counter <= 0;
					counter <= 0;
					state <= PLAY_HIGHSCORE2;
				end
				if (freq_counter < 110670) begin
					freq_counter <= freq_counter + 1;
				end
				else begin
					freq_counter <= 0;
					sound <= ~sound;
				end
			end
			PLAY_HIGHSCORE2: begin
				if (counter < 30000000) counter <= counter + 1; // play for 0.1 sec
				else begin
					freq_counter <= 0;
					counter <= 0;
					state <= WAIT;
				end
				if (freq_counter < 82909) begin
					freq_counter <= freq_counter + 1;
				end
				else begin
					freq_counter <= 0;
					sound <= ~sound;
				end
			end
			default: state <= WAIT;
		endcase
	end
endmodule