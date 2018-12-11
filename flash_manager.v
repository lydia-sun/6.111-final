`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:54:41 12/05/2018 
// Design Name: 
// Module Name:    flash_manager 
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
module max_score(
	input [15:0] current_score,
	input [15:0] score_from_flash,
	input clk,
	input ready,
	input busy,
	input reset_score,
	output reg reset,
	output reg writing,
	output reg reading,
	output reg up_reset,
	output [15:0] score,
	output reg [15:0] score_to_store,
	output [4:0] state_out);
	
	parameter STARTUP = 7'b00001;
	parameter READ_LOOP = 7'b00011;
	parameter CHECK = 7'b00010; 
	parameter RESET = 7'b00100;
	parameter STORE = 7'b01000; 
	parameter IDLE= 7'b10000; 
	
	reg [4:0] state = STARTUP;
	reg [15:0] high_reg = 0;
	reg [8:0] counter = 0;
	reg old_reset_score;
	
	always @(posedge clk) begin
		old_reset_score <= reset_score;
		case (state)
			STARTUP: begin
				reading <= 1;
				state <= READ_LOOP;
			end
			READ_LOOP: begin
				if (counter < 200) counter <= counter + 1;
				else begin
					counter <= 0;
					state <= CHECK;
					reading <= 0;
				end
			end
			CHECK: begin
				if (~busy) begin
					high_reg <= score_from_flash;
					state <= IDLE; 			
				end
			end
			RESET: begin
				up_reset <= 0;
				reset <= 0;
				if (~busy) begin
					state <= STORE; // if done resetting, go to store state
					writing <= 1;
				end
			end
			STORE: begin
				if (~busy) state <= IDLE; // done storing new score	
			end
			IDLE: begin
				if ((current_score > high_reg) && ready) begin
					writing <= 0;
					state <= RESET;
					reset <= 1;
					up_reset <=1;
					score_to_store <= current_score;
					high_reg <= current_score;
				end
				else if (~old_reset_score && reset_score) begin
					writing <= 0;
					state <= RESET;
					reset<= 1;
					up_reset <= 1;
					score_to_store <= 0;
					high_reg <= 0;
				end
			end
			default: state <= IDLE;
		endcase
	end
	assign score = high_reg;
	assign state_out = state;
	
endmodule

module flasher (
	input [15:0] score_to_store,
	input up,
	output reg [15:0] wdata,
	output reg writemode,
	output reg dowrite,
	output reg [22:0] raddr, // address of where we want to read from flash (playing from flash)
	output reg doread, // tell flash to read from memory
	input busy, // flash is busy, don't read/write when asserted
	input [11:0] fsmstate, //for intense debugging. you mostly likely will not need.
	input [639:0] dots,
	input writing,
	input clk,
	input reading); //FOR EXTREME DEBUGGING. You shouldn't need to look at these. If you do, email me.
	
	reg [4:0] flashcounter=0;
	reg [3:0] counter;

	always @(posedge clk) begin
		 if (up) begin
			  writemode <=1; 
			  dowrite <= 0; 
			  doread <= 0;
			  wdata <= 0; // initial write data = 0
			  raddr <= 0; // initial read address = 0
			  counter <= 0;
			  end
		 else begin
			  if(busy==0) begin
					if(writing) begin
						 if(counter < 15) begin//when fifo has no info, dont do anything. just wait
							  writemode<=1;
							  doread<=0; 
	//                    rd_en_fifo<=0;
							  flashcounter<=1+flashcounter;//2^5 clock cycles between write
							  if (flashcounter==0) begin
	//                        rd_en_fifo<=1;
									counter <= counter + 1;
									dowrite<=1;
									wdata<=score_to_store;
							  end
						 end
					end
					if(reading) begin
						 writemode<=0;
						 doread<=1;
				  raddr<=0;//ADDRESS YOU WANT  
						 end
					end
			  else begin //busy
					if (writing)begin
						 dowrite<=0; 
						 flashcounter<=1;
						 end
			  else begin
				  doread<=0;
			  end
			  end
		 end
	end
endmodule

//manages all the stuff needed to read and write to the flash ROM
module flash_manager(clock, reset, dots, writemode, wdata, dowrite, 
raddr, frdata, doread, busy, flash_data, flash_address, flash_ce_b, 
flash_oe_b, flash_we_b, flash_reset_b, flash_sts, flash_byte_b, fsmstate);

	input reset, clock;			//clock and reset
	output [639:0] dots;		//outputs to dot-matrix to help debug flash, not necessary
	input writemode;				//if true then we're in write mode, else we're in read mode
	input [15:0] wdata;			//data to be written
	input dowrite;					//putting this high tells the manager the data it has is new, write it
	input [22:0] raddr;			//address to read from
	output[15:0] frdata;		//data being read
	reg[15:0]    rdata;
	input doread;					//putting this high tells the manager to perform a read on the current address
	output busy;					//and an output to tell folks we're still working on the last thing
	reg busy;

	inout [15:0] flash_data;					//direct passthrough from labkit to low-level modules (flash_int and test_fsm)
	output [23:0] flash_address;
	output flash_ce_b, flash_oe_b, flash_we_b;
	output flash_reset_b, flash_byte_b;
	input  flash_sts;

	wire flash_busy;		//except these, which are internal to the interface
	wire[15:0] fwdata;
	wire[15:0] frdata;
	wire[22:0] address;							
	wire [1:0] op;	
	
	reg [1:0] mode;
	wire fsm_busy;
	
	reg[2:0] state = 2;					//210
	
	output[11:0] fsmstate;
	wire [7:0] fsmstateinv;
	assign fsmstate = {state,flash_busy,fsm_busy,fsmstateinv[4:0],mode};	//for debugging only
	
										//this guy takes care of /some/ of flash's tantrums
	flash_int flash(reset, clock, op, address, fwdata, frdata, flash_busy, flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_sts, flash_byte_b);
										//and this guy takes care of the rest of its tantrums
	test_fsm  fsm  (reset, clock, op, address, fwdata, frdata, flash_busy, dots, mode, fsm_busy, wdata, raddr, fsmstateinv);

	parameter MODE_IDLE	= 0;
	parameter MODE_INIT	= 1;
	parameter MODE_WRITE = 2;
	parameter MODE_READ	= 3;
	
	parameter HOME 		= 3'd0;
	parameter MEM_INIT 	= 3'd1;
	parameter MEM_WAIT 	= 3'd2;
	parameter WRITE_READY= 3'd3;
	parameter WRITE_WAIT	= 3'd4;
	parameter READ_READY	= 3'd5;
	parameter READ_WAIT 	= 3'd6;
	
	always @ (posedge clock)
		if(reset)
			begin
				busy <= 1;
				state <= HOME;
				mode <= MODE_IDLE;
			end
		else begin		
			case(state)
				HOME://0				//we always start here
					if(!fsm_busy)
						begin
							busy <= 0;
							if(writemode)
								begin
									busy <= 1;
									state <= MEM_INIT;
								end
							else
								begin
									busy <= 1;
									state <= READ_READY;
								end
						end
					else
						mode <= MODE_IDLE;
					
				MEM_INIT://1							//begin wiping the memory
					begin
						busy <= 1;
						mode <= MODE_INIT;
						if(fsm_busy)					//to give the fsm a chance to raise its busy signal
							state <= MEM_WAIT;
					end
					
				MEM_WAIT://2						//finished wiping
					if(!fsm_busy)
						begin
							busy <= 0;
							state<= WRITE_READY;
						end
					else
						mode <= MODE_IDLE;

				WRITE_READY://3					//waiting for data to write to flash
					if(dowrite)
						begin
							busy <= 1;
							mode <= MODE_WRITE;
						end
					else if(busy)
						state <= WRITE_WAIT;
					else if(!writemode)
						state <= READ_READY;
				 
				WRITE_WAIT://4				//waiting for flash to finish writing
					if(!fsm_busy)
						begin
							busy <= 0;
							state <= WRITE_READY;
						end
					else
						mode <= MODE_IDLE;
				
				READ_READY://5				//ready to read data
					if(doread)
						begin
							busy <= 1;
							mode <= MODE_READ;
							if(busy)			//lets the fsm raise its busy level
								state <= READ_WAIT;
						end
					else
						busy <= 0;
				
				READ_WAIT://6			//waiting for flash to give the data up
					if(!fsm_busy)
						begin
							busy <= 0;
							state <= READ_READY;
						end
					else
						mode <= MODE_IDLE;
				
				default: begin		//should never happen...
					state <= 3'd7;
				end
			endcase
	end
endmodule
