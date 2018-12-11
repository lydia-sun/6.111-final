`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:08:31 11/19/2018 
// Design Name: 
// Module Name:    coord_generator 
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
module coord_generator (input rdy,
								input [2:0] slice,
								input active,
								input vsync, 
								input [4:0] yvel, 
								input backwards, 
								input [9:0] xcostart, 
								output [9:0] x_coord, 
								output reg [2:0] fell, 
								output [9:0] y_coord,
								output reg activeconst,
								output reg [7:0] score,
								output [4:0] yvelocity,
								output reg new);
	
	parameter START = 0;
	parameter CALC = 1;

	reg [9:0] x_coord1;
	reg [9:0] y_coord1;
	reg [4:0] y_vel;
	reg [3:0] x_vel;
	reg y_up;
	reg change;
	reg left;
	reg reachedzero;
	reg [3:0] counter;
	reg state;
	reg oldrdy;
	reg oldslice;

		
	always @(posedge vsync) begin
		oldrdy <= rdy;
		
		if (~rdy && oldrdy) begin 
			fell <= 0; 
			state <= START;
			y_coord1 <= 768;
		end
		
		if (rdy && ~oldrdy) score <= 0;
		
		if (rdy) begin
			case (state)
		
				START: begin 
					activeconst <= active;
					y_coord1 <= 700;
					counter <= 0;
					y_vel <= yvel;
					x_coord1 <= xcostart;
					reachedzero <= 0;
					state <=  CALC; 
					x_vel <= 5;
					left <= backwards;
					new <= 1;
				end
			
				CALC: begin 
					new <= 0;
					oldslice <= ~(slice == 0) && (activeconst);
					
					// change every 8 cycles
					if (counter == 7) begin counter <= 0; change <= 1; end
					else begin counter <= counter + 1; change <= 0; end

					// has the velocity reached zero
					if (y_vel == 0) reachedzero <= 1;

					// which way does velocity change
					y_vel <= (change && !reachedzero)? y_vel - 2: (change && reachedzero)? y_vel + 2: y_vel;

					// does it move up our down
					y_up <= ~reachedzero;

					y_coord1 <= (reachedzero && y_coord1 >768)? 768: (y_up)? (y_coord1 - y_vel) : (y_coord1 + y_vel);

					// wraps around so user has more time to be able to cut the fruit
					x_coord1 <= (left)?	x_coord1 - x_vel: x_coord1 + x_vel;

					state <= (reachedzero && y_coord1 > 768)? START: CALC; 

					fell <= (reachedzero && (y_coord1 > 768) && (slice == 0) && (activeconst)) ? fell + 1: fell; 
					
					score <= ((~(slice == 0) && (activeconst)) && ~oldslice)? score + 1: score;
				end
		
				default: state <= START;
			
			endcase
		end
	end
	assign x_coord = x_coord1; assign y_coord = y_coord1; assign yvelocity = y_vel;
endmodule

module coord_generator_slice (input begincalc,
								input vsync, 
								input [4:0] yvel,
								input new, 
								input backwards, 
								input [9:0] xcostart,
								input [9:0] ycostart,								
								output [9:0] x_coord,
								output [9:0] y_coord);
	
	parameter START = 0;
	parameter CALC = 1;

	reg [9:0] x_coord1;
	reg [9:0] y_coord1;
	reg [4:0] y_vel;
	reg [3:0] x_vel;
	reg y_up;
	reg change;
	reg left;
	reg reachedzero;
	reg [3:0] counter;
	reg state = 0;
	
	always @(posedge vsync) begin
			case (state)
				START: begin 
					counter <= 0;
					y_vel <= 0;
					x_coord1 <= xcostart;
					y_coord1 <= ycostart;
					reachedzero <= 1;
					state <=  (begincalc) ? CALC: START; 
					x_vel <= 4;
					left <= backwards;
				end
			
				CALC: begin 
				// change every 8 cycles
				if (counter == 8) begin counter <= 0; change <= 1; end
				else begin counter <= counter + 1; change <= 0; end

				y_vel <= (change)? y_vel + 2: y_vel;
				
				if (new) state <= START;
				else y_coord1 <= (y_coord1 > 768) ? 768 : y_coord1 + y_vel;
				
				x_coord1 <= (left)?	x_coord1 - x_vel: x_coord1 + x_vel;
				end
				default: state <= START;
			endcase
		end
	assign x_coord = x_coord1; 
	assign y_coord = y_coord1;
endmodule
