`default_nettype none
///////////////////////////////////////////////////////////////////////////////
//
// Pushbutton Debounce Module (video version - 24 bits)  
//
///////////////////////////////////////////////////////////////////////////////

module debounce (input reset, clock, noisy,
                 output reg clean);

   reg [19:0] count;
   reg new;

   always @(posedge clock)
     if (reset) begin new <= noisy; clean <= noisy; count <= 0; end
     else if (noisy != new) begin new <= noisy; count <= 0; end
     else if (count == 650000) clean <= new;
     else count <= count+1;

endmodule

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
//Started : "Launching Design Summary".

// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2012-Sep-15: Converted to 24bit RGB
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module fruit_ninja   (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       user1, user2, user3, user4,
	       
	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
   // ac97_sdata_in is an input

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b0;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b0;
   assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = 1'b0;
   assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_clk = 1'b0;
   assign ram0_cen_b = 1'b1;
   assign ram0_ce_b = 1'b1;
   assign ram0_oe_b = 1'b1;
   assign ram0_we_b = 1'b1;
   assign ram0_bwe_b = 4'hF;
   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_clk = 1'b0;
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;
   assign clock_feedback_out = 1'b0;
   // clock_feedback_in is an input
   
   // Flash ROM
//   assign flash_data = 16'hZ;
//   assign flash_address = 24'h0;
//   assign flash_ce_b = 1'b1;
//   assign flash_oe_b = 1'b1;
//   assign flash_we_b = 1'b1;
//   assign flash_reset_b = 1'b0;
//   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

   // LED Displays
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
   // disp_data_in is an input

   // Buttons, Switches, and Individual LEDs
   //lab3 assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;
   assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;
			    
   ////////////////////////////////////////////////////////////////////////////
   //
   // fruit ninja
   //
   ////////////////////////////////////////////////////////////////////////////

   // use FPGA's digital clock manager to produce a
   // 65MHz clock (actually 64.8MHz)
   wire clock_65mhz_unbuf,clock_65mhz;
   DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
   // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
   // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
   // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
   // synthesis attribute CLKIN_PERIOD of vclk1 is 37
   BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));

   // power-on reset generation
   wire power_on_reset;    // remain high for first 16 clocks
   SRL16 reset_sr (.D(1'b0), .CLK(clock_65mhz), .Q(power_on_reset),
		   .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
   defparam reset_sr.INIT = 16'hFFFF;

   // ENTER button is user reset
   wire reset,user_reset;
   debounce db1(.reset(power_on_reset),.clock(clock_65mhz),.noisy(~button_enter),.clean(user_reset));
   assign reset = user_reset | power_on_reset;
   
   // UP and DOWN buttons for pong paddle
//   wire up,down;
//   debounce db2(.reset(reset),.clock(clock_27mhz),.noisy(~button_up),.clean(up));
//   debounce db3(.reset(reset),.clock(clock_65mhz),.noisy(~button_down),.clean(down));

   // generate basic XVGA video signals
   wire [10:0] hcount;
   wire [9:0]  vcount;
   wire hsync,vsync,blank;
   xvga xvga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
              .hsync(hsync),.vsync(vsync),.blank(blank));
	
	reg data1,data2, data3;
	wire game_state;

   // feed XVGA signals to fruit ninja game
   wire [23:0] pixel; 
	
	// scorekeeping
	wire [7:0] ultimate_score; 
	wire [15:0] score;
	
	// Sounds
	wire [1:0] fell;
	wire apple_slice, orange_slice, peach_slice, bomb_slice;
	wire [1:0] state;
	
   game_fsm fruit_ninja(.resetbutton(~button_enter), .state_out(state), .vsync(vsync), .serial_data(data3), .vclock(clock_65mhz),.reset(reset),
		.ultimate_score(ultimate_score), .hcount(hcount), .vcount(vcount) ,.pixel(pixel), .game_state(game_state),
		.highscore(score[7:0]), .fell_out(fell), .apple_slice(apple_slice), .orange_slice(orange_slice), 
		.peach_slice(peach_slice), .bomb_slice(bomb_slice));

   reg [23:0] rgb;   
   reg b,hs,vs;
   always @(posedge clock_65mhz) begin
		data1 <= user2[0];
		data2 <= data1;
		data3 <= data2;
		hs <= hsync;
		vs <= vsync;
		b <= blank;
		rgb <= pixel;
   end

   // VGA Output.  In order to meet the setup and hold times of the
   // AD7125, we send it ~clock_65mhz.
   assign vga_out_red = rgb[23:16];
   assign vga_out_green = rgb[15:8];
   assign vga_out_blue = rgb[7:0];
   assign vga_out_sync_b = 1'b1;    // not used
   assign vga_out_blank_b = ~b;
   assign vga_out_pixel_clock = ~clock_65mhz;
   assign vga_out_hsync = hs;
   assign vga_out_vsync = vs;
	
	wire [639:0] dots;
	wire writemode;
	wire [15:0] wdata;
	wire dowrite;
	wire [22:0] raddr;
	wire [15:0] frdata;
	wire doread;
	wire busy;
	wire [11:0] fsmstate;

	wire [4:0] state_out;
	wire [63:0] data_in_display; 
	assign data_in_display= {score, 32'b0, frdata};

	wire [15:0] score_to_store;
	wire writing;
	wire reading;
	wire flash_reset;
	wire up_reset;
	
	wire ready;
	wire [15:0] current_score;

	//display display_16hex (power_on_reset, clock_27mhz, data_in_display, 
	//	 disp_blank, disp_clock, disp_rs, disp_ce_b,
	//	 disp_reset_b, disp_data_out);

	flash_manager flash(.clock(clock_27mhz), .reset(flash_reset), .dots(dots), .writemode(writemode), .wdata(wdata), 
							.dowrite(dowrite), .raddr(raddr), .frdata(frdata), .doread(doread), .busy(busy), 
							.flash_data(flash_data), .flash_address(flash_address), .flash_ce_b(flash_ce_b), 
							.flash_oe_b(flash_oe_b), .flash_we_b(flash_we_b), .flash_reset_b(flash_reset_b), 
							.flash_sts(flash_sts), .flash_byte_b(flash_byte_b), .fsmstate(fsmstate));
							
	flasher my_flash (.clk(clock_27mhz), .busy(busy), .fsmstate(fsmstate), .dots(dots), .writing(writing),
							.reading(reading), .wdata(wdata), 
							.writemode(writemode), .dowrite(dowrite), 
							.raddr(raddr), .doread(doread), 
							.score_to_store(score_to_store), .up(up_reset));
							
	slower slow(.clk(clock_27mhz), .r_in(game_state), .c_in(ultimate_score), .r(ready), .c(current_score));

	max_score my_max (.current_score(current_score), .score_from_flash(frdata), .clk(clock_27mhz), 
	.ready(ready), .busy(busy), .reset(flash_reset), .writing(writing), .reading(reading), .up_reset(up_reset),
	.score(score), .score_to_store(score_to_store), .state_out(state_out), .reset_score(!button_up));	
	
	wire r;
	sfx sounds(.state_in(state), .clk(clock_65mhz), .apple_slice(apple_slice), .orange_slice(orange_slice), .peach_slice(peach_slice), .bomb_slice(bomb_slice), 
	.busy(busy), .sound(user4[0]), .lost_life(fell), .r(r));
	
	assign led[7] = ~r;
	assign led[6] = ~busy;
	assign led[5] = ~game_state;
	assign led[4:0] = 5'b11111;
			
endmodule

module slower(input clk, 
	input r_in, 
	input [6:0] c_in, 
	output reg r, 
	output reg [6:0] c);

	reg a, b, d;
	reg [15:0] one;
	reg [15:0] two;
	reg [15:0] three;
	always @ (posedge clk) begin
		a <= r_in;
		b <= a;
		d <= b;
		one <= c_in;
		two <= one;
		three <= two;
		r <= d;
		c <= three;
	end
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// xvga: Generate XVGA display signals (1024 x 768 @ 60Hz)
//
////////////////////////////////////////////////////////////////////////////////

module xvga(input vclock,
            output reg [10:0] hcount,    // pixel number on current line
            output reg [9:0] vcount,	 // line number
            output reg vsync,hsync,blank);

   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   reg hblank,vblank;
   wire hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount == 1023);    
   assign hsyncon = (hcount == 1047);
   assign hsyncoff = (hcount == 1183);
   assign hreset = (hcount == 1343);

   // vertical: 806 lines total
   // display 768 lines
   wire vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount == 767);    
   assign vsyncon = hreset & (vcount == 776);
   assign vsyncoff = hreset & (vcount == 782);
   assign vreset = hreset & (vcount == 805);

   // sync and blanking
   wire next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always @(posedge vclock) begin
      hcount <= hreset ? 0 : hcount + 1;
      hblank <= next_hblank;
      hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync;  // active low

      vcount <= hreset ? (vreset ? 0 : vcount + 1) : vcount;
      vblank <= next_vblank;
      vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;  // active low

      blank <= next_vblank | (next_hblank & ~hreset);
   end
endmodule

////////////////////////////////////////////////////////////////////////////////
//
// game_fsm: the main game FSM
//
////////////////////////////////////////////////////////////////////////////////

module game_fsm (
	input [7:0] highscore,
   input vclock,	// 65MHz clock
	input vsync,
	input serial_data,
   input reset,		// 1 to initialize module
   input [10:0] hcount,	// horizontal index of current pixel (0..1023)
   input [9:0] 	vcount, // vertical index of current pixel (0..767)
   output [23:0] pixel,	// game's pixel  // r=23:16, g=15:8, b=7:0 
	output [7:0] ultimate_score,
	output game_state,
	output apple_slice,
	output orange_slice,
	output peach_slice,
	output bomb_slice,
	output [1:0] fell_out,
	output [1:0] state_out,
	input resetbutton
   );

	wire [15:0] yeet; wire data;
	//apple wires
	wire [4:0] yvel; wire [9:0] xcostart; wire backwards;
	wire [23:0] apple_pixel; wire [9:0] apple_x; wire [9:0] apple_y;
	//orange wires
	wire [4:0] yvel1; wire [9:0] xcostart1; wire backwards1;
	wire [23:0] orange_pixel; wire [9:0] orange_x; wire [9:0] orange_y;
	//bomb wires
	wire [4:0] yvel2; wire [9:0] xcostart2; wire backwards2;
	wire [23:0] bomb_pixel; wire [9:0] bomb_x; wire [9:0] bomb_y;	
	//peach wires
	wire [4:0] yvel3; wire [9:0] xcostart3; wire backwards3;
	wire [23:0] peach_pixel; wire [9:0] peach_x; wire [9:0] peach_y;	
	//other stuff lol
	wire [23:0] game_pixel;
	wire overlap;
	
	reg [1:0] state = 0;
	parameter START = 0;
	parameter PLAY = 1;
	parameter GAME_OVER = 2;
	
	assign state_out = state;
	
	// Random number generation
	
	randombitsgenerator randos (.clk(vsync), .data(data), .randomnumber(yeet));
	
	lookuptable appletable (.clk(vsync), .randomnumber(yeet[14:12]), .yvel1(yvel), .xcostart1(xcostart), .backwards1(backwards));
	lookuptable orangetable (.clk(vsync), .randomnumber(yeet[2:0]), .yvel1(yvel1), .xcostart1(xcostart1), .backwards1(backwards1));	
	lookuptablebomb bombtable (.clk(vsync), .randomnumber(yeet[8:6]), .yvel1(yvel2), .xcostart1(xcostart2), .backwards1(backwards2));	
	lookuptable peachtable (.clk(vsync), .randomnumber(yeet[3:1]), .yvel1(yvel3), .xcostart1(xcostart3), .backwards1(backwards3));
	
	// Coordinates
	reg ready;
	
	wire [2:0] apple_fell; wire active_apple; wire [7:0] apple_score; wire applenew; wire applesliced; wire [4:0] yvelocity_apple; 
	coord_generator apple_coords(.yvelocity(yvelocity_apple), .new(applenew), .score(apple_score), .active(yeet[0]), .activeconst(active_apple), 
	.rdy(ready), .slice(applesliced), .vsync(vsync), .yvel(yvel), .xcostart(xcostart), .backwards(backwards), 
									.x_coord(apple_x), .y_coord(apple_y), .fell(apple_fell));
	
	wire [2:0] orange_fell; wire active_orange; wire [7:0] orange_score; wire orangenew; wire orangesliced; wire [4:0] yvelocity_orange;
	coord_generator orange_coords(.yvelocity(yvelocity_orange), .new(orangenew), .score(orange_score), .active(yeet[1]), .activeconst(active_orange), 
	.rdy(ready), .slice(orangesliced), .vsync(vsync), .yvel(yvel1), .xcostart(xcostart1), .backwards(backwards1), 
									.x_coord(orange_x), .y_coord(orange_y), .fell(orange_fell));
									
	wire [2:0] bomb_fell; wire active_bomb; wire [3:0] bomb_score;
	coord_generator bomb_coords(.score(bomb_score), .active(yeet[2]), .activeconst(active_bomb), .rdy(ready), 
	.slice(0), .vsync(vsync), .yvel(yvel2), .xcostart(xcostart2), .backwards(backwards2), 
									.x_coord(bomb_x), .y_coord(bomb_y), .fell(bomb_fell));
									
	wire [2:0] peach_fell; wire active_peach; wire [7:0] peach_score; wire peachnew; wire peachsliced; wire [4:0] yvelocity_peach;
	coord_generator peach_coords(.yvelocity(yvelocity_peach), .new(peachnew), .score(peach_score), .active(yeet[5]), .activeconst(active_peach), 
	.rdy(ready), .slice(peachsliced), .vsync(vsync), .yvel(yvel3), .xcostart(xcostart3), .backwards(backwards3), 
									.x_coord(peach_x), .y_coord(peach_y), .fell(peach_fell));
	
	assign ultimate_score = apple_score + orange_score + peach_score;
									
	// Fruit & bombs
	wire [9:0] apple_x2, peach_x2, orange_x2;
	wire [9:0] orange_y2, apple_y2, peach_y2;
	
	apple appley(.active(active_apple), .slice(applesliced), .pixel_clk(vclock), .hcount(hcount), 
	.xslice(apple_x2), .yslice(apple_y2), .vcount(vcount), .x(apple_x), .y(apple_y), .pixel(apple_pixel));
	
	orange orangey(.active(active_orange), .slice(orangesliced), .pixel_clk(vclock), .hcount(hcount), 
	.vcount(vcount), .x(orange_x), .y(orange_y), .xslice(orange_x2), .yslice(orange_y2), .pixel(orange_pixel));
					
	bomb bomby(.active(active_bomb), .slice(0), .pixel_clk(vclock), .hcount(hcount), 
	.vcount(vcount), .x(bomb_x), .y(bomb_y), .pixel(bomb_pixel));		
					
	peach peachy(.active(active_peach), .slice(peachsliced), .pixel_clk(vclock), .hcount(hcount), 
	.vcount(vcount), .x(peach_x), .y(peach_y), .xslice(peach_x2), .yslice(peach_y2), .pixel(peach_pixel));				
	
	// Flying slices
	coord_generator_slice apple_slice_coords (.yvel(0), .begincalc(applesliced), .vsync(vsync), .new(applenew), .backwards(~backwards), 
	.xcostart(apple_x), .ycostart(apple_y + 75), .x_coord(apple_x2), .y_coord(apple_y2));
	
	coord_generator_slice orange_slice_coords (.yvel(0), .begincalc(orangesliced), .vsync(vsync), .new(orangenew), .backwards(~backwards1),
	.xcostart(orange_x), .ycostart(orange_y + 75), .x_coord(orange_x2), .y_coord(orange_y2));
	
	coord_generator_slice peach_slice_coords (.yvel(0), .begincalc(peachsliced), .vsync(vsync), .new(peachnew), .backwards(~backwards3),
	.xcostart(peach_x), .ycostart(peach_y + 75), .x_coord(peach_x2), .y_coord(peach_y2));
	
	assign apple_slice = applesliced && (state == PLAY);
	assign peach_slice = peachsliced && (state == PLAY);
	assign orange_slice = orangesliced && (state == PLAY);
	assign fell_out = apple_fell + orange_fell + peach_fell;
	
	// Lives

	wire [23:0] pixel_life1; reg display_life1;
	blob life1 (.color(24'hFF_FF_FF), .x(100), .y(100), .clk(vclock), .hcount(hcount), .vcount(vcount), .display(display_life1), .pixel(pixel_life1));
	wire [23:0] pixel_life2; reg display_life2;
	blob life2 (.color(24'hFF_FF_FF), .x(170), .y(100), .clk(vclock),.hcount(hcount), .vcount(vcount), .display(display_life2), .pixel(pixel_life2));
	wire [23:0] pixel_life3; reg display_life3;
	blob life3 (.color(24'hFF_FF_FF), .x(240), .y(100), .clk(vclock),.hcount(hcount), .vcount(vcount), .display(display_life3), .pixel(pixel_life3));
	
	// Cursor
	wire [23:0] cursor_pixel;
	wire [15:0] cursor_x;
	wire [15:0] cursor_y;
	wire [7:0] button;
	
	cursor_coords generator (.serial_data(serial_data), .clk(vclock), .x_coord(cursor_x), .y_coord(cursor_y), 
	.button(button));
	
	blob #(.WIDTH(10), .HEIGHT(10)) cursor (.color(24'hFF_FF_00), .clk(vclock), .x(cursor_x[10:0]), 
	.y(cursor_y[9:0]), .hcount(hcount), .vcount(vcount), .display(1), .pixel(cursor_pixel));
				
	// Slice management

	slice_dealer slicey (.peachactive(active_peach), .appleactive(active_apple), .orangeactive(active_orange), 
	.clk(vclock), .apple_new(applenew), .orange_new(orangenew), .peach_new(peachnew), .applepix(apple_pixel), 
	.cursorpix(cursor_pixel), .orangepix(orange_pixel), .peachpix(peach_pixel), .applesliced(applesliced), 
	.orangesliced(orangesliced), .peachsliced(peachsliced));
				
	// Background
	
	wire [23:0] bg_pixel;
	bg background(.vsync(vsync), .clk(vclock), .pixel(bg_pixel));

	// Start and end screens
	
	wire [23:0] start_pixel;
	wire [23:0] logo_pixel;
	wire [23:0] play_pixel;
	
	logo_blob logo_picture (.pixel_clk(vclock), .x(362), .y(200), .hcount(hcount), 
		.vcount(vcount), .pixel(logo_pixel));
	
	play_blob play_text(.pixel_clk(vclock), .x(424), .y(400), .hcount(hcount), .vcount(vcount), .pixel(play_pixel));
	
	assign start_pixel = play_pixel | logo_pixel;
	
	wire [23:0] end_pixel;
	wire [23:0] replay_pixel;
	wire [23:0] score_pixel;
	wire [23:0] high_score_pixel;
	
	replay_blob replay_button(.pixel_clk(vclock), .x(297), .y(244), .hcount(hcount), 
		.vcount(vcount), .pixel(replay_pixel));
			
	score_blob score_text (.pixel_clk(vclock), .x(297), .y(350), .hcount(hcount), 
		.vcount(vcount), .pixel(score_pixel));	

	hi_blob high_score (.pixel_clk(vclock), .x(297), .y(425), .hcount(hcount), .vcount(vcount), .pixel(high_score_pixel));
	
	// number scores
	wire [23:0] top_left_1; reg display_1; reg [9:0] x1; reg [8:0] y1;
	blob #(.WIDTH(10), .HEIGHT(44)) s_10(.clk(vclock), .display(display_1), .color(24'hFF_FF_FF), .x(x1), .y(y1), .hcount(hcount), 
		.vcount(vcount), .pixel(top_left_1));
	wire [23:0] top_1; reg display_2; reg [9:0] x2; reg [8:0] y2;
	blob #(.WIDTH(44), .HEIGHT(10)) s_11(.clk(vclock), .display(display_2), .color(24'hFF_FF_FF), .x(x2), .y(y2), .hcount(hcount), 
		.vcount(vcount), .pixel(top_1));
	wire [23:0] top_right_1; reg display_3; reg [9:0] x3; reg [8:0] y3;
	blob #(.WIDTH(10), .HEIGHT(44)) s_12(.clk(vclock), .display(display_3), .color(24'hFF_FF_FF), .x(x3), .y(y3), .hcount(hcount), 
		.vcount(vcount), .pixel(top_right_1));
	wire [23:0] bottom_left_1; reg display_4; reg [9:0] x4; reg [8:0] y4;
	blob #(.WIDTH(10), .HEIGHT(44)) s_13(.clk(vclock), .display(display_4), .color(24'hFF_FF_FF), .x(x4), .y(y4), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_left_1));
	wire [23:0] bottom_right_1; reg display_5; reg [9:0] x5; reg [8:0] y5;
	blob #(.WIDTH(10), .HEIGHT(54)) s_14(.clk(vclock), .display(display_5), .color(24'hFF_FF_FF), .x(x5), .y(y5), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_right_1));
	wire [23:0] middle_1; reg display_6; reg [9:0] x6; reg [8:0] y6;
	blob #(.WIDTH(44), .HEIGHT(10)) s_15(.clk(vclock), .display(display_6), .color(24'hFF_FF_FF), .x(x6), .y(y6), .hcount(hcount), 
		.vcount(vcount), .pixel(middle_1));
	wire [23:0] bottom_1; reg display_7; reg [9:0] x7; reg [8:0] y7;
	blob #(.WIDTH(44), .HEIGHT(10)) s_16(.clk(vclock), .display(display_7), .color(24'hFF_FF_FF), .x(x7), .y(y7), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_1));

	wire [23:0] top_left_2; reg display_8; reg [9:0] x8; reg [8:0] y8;
	blob #(.WIDTH(10), .HEIGHT(44)) s_20(.clk(vclock),.display(display_8), .color(24'hFF_FF_FF), .x(x8), .y(y8), .hcount(hcount), 
		.vcount(vcount), .pixel(top_left_2));
	wire [23:0] top_2; reg display_9; reg [9:0] x9; reg [8:0] y9;
	blob #(.WIDTH(44), .HEIGHT(10)) s_21(.clk(vclock),.display(display_9), .color(24'hFF_FF_FF), .x(x9), .y(y9), .hcount(hcount), 
		.vcount(vcount), .pixel(top_2));
	wire [23:0] top_right_2; reg display_10; reg [9:0] x10; reg [8:0] y10;
	blob #(.WIDTH(10), .HEIGHT(44)) s_22(.clk(vclock),.display(display_10), .color(24'hFF_FF_FF), .x(x10), .y(y10), .hcount(hcount), 
		.vcount(vcount), .pixel(top_right_2));
	wire [23:0] bottom_left_2; reg display_11; reg [9:0] x11; reg [8:0] y11;
	blob #(.WIDTH(10), .HEIGHT(44)) s_23(.clk(vclock),.display(display_11), .color(24'hFF_FF_FF), .x(x11), .y(y11), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_left_2));
	wire [23:0] bottom_right_2; reg display_12; reg [9:0] x12; reg [8:0] y12;
	blob #(.WIDTH(10), .HEIGHT(54)) s_24(.clk(vclock),.display(display_12), .color(24'hFF_FF_FF), .x(x12), .y(y12), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_right_2));
	wire [23:0] middle_2; reg display_13; reg [9:0] x13; reg [8:0] y13;
	blob #(.WIDTH(44), .HEIGHT(10)) s_25(.clk(vclock), .display(display_13), .color(24'hFF_FF_FF), .x(x13), .y(y13), .hcount(hcount), 
		.vcount(vcount), .pixel(middle_2));
	wire [23:0] bottom_2; reg display_14; reg [9:0] x14; reg [8:0] y14;
	blob #(.WIDTH(44), .HEIGHT(10)) s_26(.clk(vclock), .display(display_14), .color(24'hFF_FF_FF), .x(x14), .y(y14), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_2));
	
	// high score instantiations
	wire [23:0] top_left_3; reg display_15; 
	blob #(.WIDTH(10), .HEIGHT(44)) s_30(.clk(vclock), .display(display_15), .color(24'hFF_FF_FF), .x(x1+ 60 + 65), .y(y1 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(top_left_3));
	wire [23:0] top_3; reg display_16;
	blob #(.WIDTH(44), .HEIGHT(10)) s_31(.clk(vclock), .display(display_16), .color(24'hFF_FF_FF), .x(x2 + 60 + 65), .y(y2 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(top_3));
	wire [23:0] top_right_3; reg display_17; 
	blob #(.WIDTH(10), .HEIGHT(44)) s_32(.clk(vclock), .display(display_17), .color(24'hFF_FF_FF), .x(x3 + 60 + 65), .y(y3 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(top_right_3));
	wire [23:0] bottom_left_3; reg display_18; 
	blob #(.WIDTH(10), .HEIGHT(44)) s_33(.clk(vclock), .display(display_18), .color(24'hFF_FF_FF), .x(x4 + 60 + 65), .y(y4 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_left_3));
	wire [23:0] bottom_right_3; reg display_19;
	blob #(.WIDTH(10), .HEIGHT(54)) s_34(.clk(vclock), .display(display_19), .color(24'hFF_FF_FF), .x(x5+ 60 + 65), .y(y5 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_right_3));
	wire [23:0] middle_3; reg display_20; 
	blob #(.WIDTH(44), .HEIGHT(10)) s_35(.clk(vclock), .display(display_20), .color(24'hFF_FF_FF), .x(x6 + 60 + 65), .y(y6 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(middle_3));
	wire [23:0] bottom_3; reg display_21; 
	blob #(.WIDTH(44), .HEIGHT(10)) s_36(.clk(vclock), .display(display_21), .color(24'hFF_FF_FF), .x(x7 + 60 + 65), .y(y7+ 78), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_3));

	wire [23:0] top_left_4; reg display_22; 
	blob #(.WIDTH(10), .HEIGHT(44)) s_40(.clk(vclock),.display(display_22), .color(24'hFF_FF_FF), .x(x8+ 60 + 65), .y(y8 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(top_left_4));
	wire [23:0] top_4; reg display_23; 
	blob #(.WIDTH(44), .HEIGHT(10)) s_41(.clk(vclock),.display(display_23), .color(24'hFF_FF_FF), .x(x9 + 60 + 65), .y(y9 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(top_4));
	wire [23:0] top_right_4; reg display_24; 
	blob #(.WIDTH(10), .HEIGHT(44)) s_42(.clk(vclock),.display(display_24), .color(24'hFF_FF_FF), .x(x10 + 60 + 65), .y(y10 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(top_right_4));
	wire [23:0] bottom_left_4; reg display_25; 
	blob #(.WIDTH(10), .HEIGHT(44)) s_43(.clk(vclock),.display(display_25), .color(24'hFF_FF_FF), .x(x11 + 60 + 65), .y(y11 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_left_4));
	wire [23:0] bottom_right_4; reg display_26; 
	blob #(.WIDTH(10), .HEIGHT(54)) s_44(.clk(vclock),.display(display_26), .color(24'hFF_FF_FF), .x(x12 + 60 + 65), .y(y12 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_right_4));
	wire [23:0] middle_4; reg display_27; 
	blob #(.WIDTH(44), .HEIGHT(10)) s_45(.clk(vclock), .display(display_27), .color(24'hFF_FF_FF), .x(x13 + 60 + 65), .y(y13 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(middle_4));
	wire [23:0] bottom_4; reg display_28; 
	blob #(.WIDTH(44), .HEIGHT(10)) s_46(.clk(vclock), .display(display_28), .color(24'hFF_FF_FF), .x(x14 + 60 + 65), .y(y14 + 78), .hcount(hcount), 
		.vcount(vcount), .pixel(bottom_4));
		
	reg [7:0] scoreboard; reg [7:0] hiscore;
	reg [7:0] subtractor; reg [7:0] subtractorhi;

	wire [23:0] score; wire [23:0] highestscore;
	assign score = top_left_1 | top_1 | top_right_1 | bottom_left_1 | bottom_right_1 | middle_1 | bottom_1 |
						top_left_2 | top_2 | top_right_2 | bottom_left_2 | bottom_right_2 | middle_2 | bottom_2;
						
	assign highestscore = top_left_3 | top_3 | top_right_3 | bottom_left_3 | bottom_right_3 | middle_3 | bottom_3 |
						top_left_4 | top_4 | top_right_4 | bottom_left_4 | bottom_right_4 | middle_4 | bottom_4;
						
	assign end_pixel = score_pixel | score | replay_pixel | high_score_pixel | highestscore;
	
	wire play_overlap = cursor_x > 424 && cursor_x < 589 && cursor_y > 400 && cursor_y < 442;
	
	wire replay_overlap = cursor_x > 297 && cursor_x < 718 && cursor_y > 244 && cursor_y < 314;
	// Game State Machine
	
	reg old_up; reg oldresetbutton;

	always @(posedge vclock) begin
	
	hiscore <= highscore;
	scoreboard <= ultimate_score;
		
		if (scoreboard < 10) subtractor <= 0; else if (scoreboard >= 10 && scoreboard < 20) subtractor <= 10; else if (scoreboard >= 20 && scoreboard < 30) subtractor <= 20;
		else if (scoreboard >= 30 && scoreboard < 40) subtractor <= 30; else if (scoreboard >= 40 && scoreboard < 50) subtractor <= 40;
		else if (scoreboard >= 50 && scoreboard < 60) subtractor <= 50; else if (scoreboard >= 60 && scoreboard < 70) subtractor <= 60;
		else if (scoreboard >= 70 && scoreboard < 80) subtractor <= 70; else if (scoreboard >= 80 && scoreboard < 90) subtractor <= 80;
		else if (scoreboard >= 90 && scoreboard < 150) subtractor <= 90;
		
		case (scoreboard - subtractor)
			0: begin display_6 <= 0; display_1 <= 1; display_2 <= 1; display_3 <= 1; display_4 <= 1; display_5 <= 1; display_7 <= 1; end
			1: begin display_6 <= 0; display_1 <= 0; display_2 <= 0; display_3 <= 1; display_4 <= 0; display_5 <= 1; display_7 <= 0; end
			2: begin display_6 <= 1; display_1 <= 0; display_2 <= 1; display_3 <= 1; display_4 <= 1; display_5 <= 0; display_7 <= 1; end
			3: begin display_6 <= 1; display_1 <= 0; display_2 <= 1; display_3 <= 1; display_4 <= 0; display_5 <= 1; display_7 <= 1; end
			4: begin display_6 <= 1; display_1 <= 1; display_2 <= 0; display_3 <= 1; display_4 <= 0; display_5 <= 1; display_7 <= 0; end
			5: begin display_6 <= 1; display_1 <= 1; display_2 <= 1; display_3 <= 0; display_4 <= 0; display_5 <= 1; display_7 <= 1; end
			6: begin display_6 <= 1; display_1 <= 1; display_2 <= 1; display_3 <= 0; display_4 <= 1; display_5 <= 1; display_7 <= 1; end
			7: begin display_6 <= 0; display_1 <= 1; display_2 <= 1; display_3 <= 1; display_4 <= 0; display_5 <= 1; display_7 <= 0; end
			8: begin display_6 <= 1; display_1 <= 1; display_2 <= 1; display_3 <= 1; display_4 <= 1; display_5 <= 1; display_7 <= 1; end
			9: begin display_6 <= 1; display_1 <= 1; display_2 <= 1; display_3 <= 1; display_4 <= 0; display_5 <= 1; display_7 <= 0; end
			default: begin display_6 <= 1; display_1 <= 1; display_2 <= 1; display_3 <= 1; display_4 <= 0; display_5 <= 1; display_7 <= 0; end
		endcase
	
		if(scoreboard < 10) begin display_13 <= 0; display_8 <= 1; display_9 <= 1; display_10 <= 1; display_11 <= 1; display_12 <= 1; display_14 <= 1; end
		else if (scoreboard >= 10 && scoreboard < 20) begin display_13 <= 0; display_8 <= 0; display_9 <= 0; display_10 <= 1; display_11 <= 0; display_12 <= 1; display_14 <= 0; end
		else if (scoreboard >= 20 && scoreboard < 30) begin display_13 <= 1; display_8 <= 0; display_9 <= 1; display_10 <= 1; display_11 <= 1; display_12 <= 0; display_14 <= 1; end
		else if (scoreboard >= 30 && scoreboard < 40) begin display_13 <= 1; display_8 <= 0; display_9 <= 1; display_10 <= 1; display_11 <= 0; display_12 <= 1; display_14 <= 1; end
		else if (scoreboard >= 40 && scoreboard < 50) begin display_13 <= 1; display_8 <= 1; display_9 <= 0; display_10 <= 1; display_11 <= 0; display_12 <= 1; display_14 <= 0; end
		else if (scoreboard >= 50 && scoreboard < 60) begin display_13 <= 1; display_8 <= 1; display_9 <= 1; display_10 <= 0; display_11 <= 0; display_12 <= 1; display_14 <= 1; end
		else if (scoreboard >= 60 && scoreboard < 70)begin display_13 <= 1; display_8 <= 1; display_9 <= 1; display_10 <= 0; display_11 <= 1; display_12 <= 1; display_14 <= 1; end
		else if (scoreboard >= 70 && scoreboard < 80) begin display_13 <= 0; display_8 <= 1; display_9 <= 1; display_10 <= 1; display_11 <= 0; display_12 <= 1; display_14 <= 0; end
		else if (scoreboard >= 80 && scoreboard < 90) begin display_13 <= 1; display_8 <= 1; display_9 <= 1; display_10 <= 1; display_11 <= 1; display_12 <= 1; display_14 <= 1; end
		else if (scoreboard >= 90 && scoreboard < 150) begin display_13 <= 1; display_8 <= 1; display_9 <= 1; display_10 <= 1; display_11 <= 0; display_12 <= 1; display_14 <= 0; end
		
		if (hiscore < 10) subtractorhi <= 0; else if (hiscore >= 10 && hiscore < 20) subtractorhi <= 10; else if (hiscore>= 20 && hiscore < 30) subtractorhi <= 20;
		else if (hiscore >= 30 && hiscore < 40) subtractorhi <= 30; else if (hiscore >= 40 && hiscore < 50) subtractorhi <= 40;
		else if (hiscore >= 50 && hiscore < 60) subtractorhi <= 50; else if (hiscore >= 60 && hiscore < 70) subtractorhi <= 60;
		else if (hiscore >= 70 && hiscore < 80) subtractorhi <= 70; else if (hiscore >= 80 && hiscore < 90) subtractorhi <= 80;
		else if (hiscore >= 90 && hiscore < 150) subtractorhi <= 90;
		
		case (hiscore - subtractorhi)
			0: begin display_20 <= 0; display_15 <= 1; display_16 <= 1; display_17 <= 1; display_18 <= 1; display_19 <= 1; display_21 <= 1; end
			1: begin display_20 <= 0; display_15 <= 0; display_16 <= 0; display_17 <= 1; display_18 <= 0; display_19 <= 1; display_21 <= 0; end
			2: begin display_20 <= 1; display_15 <= 0; display_16 <= 1; display_17 <= 1; display_18 <= 1; display_19<= 0; display_21 <= 1; end
			3: begin display_20 <= 1; display_15 <= 0; display_16 <= 1; display_17 <= 1; display_18 <= 0; display_19 <= 1; display_21 <= 1; end
			4: begin display_20 <= 1; display_15 <= 1; display_16 <= 0; display_17 <= 1; display_18 <= 0; display_19 <= 1; display_21 <= 0; end
			5: begin display_20 <= 1; display_15 <= 1; display_16 <= 1; display_17 <= 0; display_18 <= 0; display_19 <= 1; display_21 <= 1; end
			6: begin display_20 <= 1; display_15 <= 1; display_16 <= 1; display_17 <= 0; display_18 <= 1; display_19 <= 1; display_21 <= 1; end
			7: begin display_20 <= 0; display_15 <= 1; display_16 <= 1; display_17 <= 1; display_18 <= 0; display_19 <= 1; display_21 <= 0; end
			8: begin display_20 <= 1; display_15 <= 1; display_16 <= 1; display_17 <= 1; display_18 <= 1; display_19 <= 1; display_21 <= 1; end
			9: begin display_20 <= 1; display_15 <= 1; display_16 <= 1; display_17 <= 1; display_18 <= 0; display_19 <= 1; display_21<= 0; end
			default: begin display_20 <= 1; display_15 <= 1; display_16 <= 1; display_17 <= 1; display_18 <= 0; display_19 <= 1; display_21 <= 0; end
		endcase
	
		if(hiscore < 10) begin display_27 <= 0; display_22 <= 1; display_23 <= 1; display_24 <= 1; display_25 <= 1; display_26 <= 1; display_28 <= 1; end
		else if (hiscore >= 10 && hiscore < 20) begin display_27 <= 0; display_22 <= 0; display_23 <= 0; display_24 <= 1; display_25 <= 0; display_26 <= 1; display_28 <= 0; end
		else if (hiscore >= 20 && hiscore < 30) begin display_27 <= 1; display_22 <= 0; display_23 <= 1; display_24 <= 1; display_25 <= 1; display_26 <= 0; display_28 <= 1; end
		else if (hiscore >= 30 && hiscore < 40) begin display_27 <= 1; display_22 <= 0; display_23 <= 1; display_24 <= 1; display_25 <= 0; display_26 <= 1; display_28 <= 1; end
		else if (hiscore >= 40 && hiscore < 50) begin display_27 <= 1; display_22 <= 1; display_23 <= 0; display_24 <= 1; display_25 <= 0; display_26 <= 1; display_28 <= 0; end
		else if (hiscore >= 50 && hiscore < 60) begin display_27 <= 1; display_22 <= 1; display_23 <= 1; display_24 <= 0; display_25 <= 0; display_26 <= 1; display_28 <= 1; end
		else if (hiscore>= 60 && hiscore < 70)begin display_27 <= 1; display_22 <= 1; display_23 <= 1; display_24 <= 0; display_25 <= 1; display_26 <= 1; display_28 <= 1; end
		else if (hiscore >= 70 && hiscore < 80) begin display_27 <= 0; display_22 <= 1; display_23 <= 1; display_24 <= 1; display_25 <= 0; display_26 <= 1; display_28 <= 0; end
		else if (hiscore >= 80 && hiscore < 90) begin display_27 <= 1; display_22 <= 1; display_23 <= 1; display_24 <= 1; display_25 <= 1; display_26 <= 1; display_28 <= 1; end
		else if (hiscore >= 90 && hiscore < 150) begin display_27 <= 1; display_22 <= 1; display_23 <= 1; display_24 <= 1; display_25 <= 0; display_26 <= 1; display_28 <= 0; end
		
		old_up <= button[0];
		oldresetbutton <= resetbutton;
		
		case (state)
			START: if (button[0] && ~old_up && play_overlap) begin
				//ready <= 1;
				state <= PLAY;
				display_life3 <= 1; display_life2 <= 1; display_life1 <= 1;
				end
				else begin 
					state <= state; 
					ready <= 0;
				end
			PLAY: if (apple_fell + orange_fell + peach_fell>= 3 || ((|cursor_pixel && |bomb_pixel) && active_bomb)) begin 
					ready <= 0;
					state <= GAME_OVER; end
				else if (resetbutton && ~oldresetbutton) 
					state <= START;
				else begin
				x1 <= 900; y1 <= 100; x2 <= 900; y2 <= 100; x3 <= 934; y3 <= 100; x4 <= 900; y4 <= 134; x5 <= 934; y5 <= 134; x6 <= 900; y6 <= 134; x7 <= 900; y7 <= 178;
				x8 <= 850; y8 <= 100; x9 <= 850; y9 <= 100; x10 <= 884; y10 <= 100; x11 <= 850; y11 <= 134; x12 <= 884; y12 <= 134; x13 <= 850; y13 <= 134; x14 <= 850; y14 <= 178;
					case (apple_fell + orange_fell + peach_fell) 
						0: begin display_life3 <= 1; display_life2 <= 1; display_life1 <= 1; end
						1: begin display_life3 <= 0; display_life2 <= 1; display_life1 <= 1; end
						2: begin display_life3 <= 0; display_life2 <= 0; display_life1 <= 1; end
						3: begin display_life3 <= 0; display_life2 <= 0; display_life1 <= 0; end
						default : begin display_life3 <= 1; display_life2 <= 1; display_life1 <= 1; end
					endcase
					ready <= 1;
					state <= state; 
				end
			GAME_OVER: if ((button[0] && ~old_up && replay_overlap)) begin //&& (|cursor_pixel && |replay_pixel)) begin
					state <= PLAY; 
					//ready <= 1;
				end
				else if (resetbutton && ~oldresetbutton) state <= START;
				else begin 
					x1 <= 572; y1 <= 325; x2 <= 572; y2 <= 325; x3 <= 606; y3 <= 325; x4 <= 572; y4 <= 359; x5 <= 606; y5 <= 359; x6 <= 572; y6 <= 359; x7 <= 572; y7 <= 403;
					x8 <= 512; y8 <= 325; x9 <= 512; y9 <= 325; x10 <= 546; y10 <= 325; x11 <= 512; y11 <= 359; x12 <= 546; y12 <= 359; x13 <= 512; y13 <= 359; x14 <= 512; y14 <= 403;
					state <= state;
					ready <= 0;
				end
			default: state <= START;
		endcase
	end
	
	wire [23:0] fruit_pixel;
	wire bomb_first;
	wire apple_first; 
	wire peach_first;
	
	assign bomb_first = ((|bomb_pixel) && (|orange_pixel)) || ((|bomb_pixel) && (|apple_pixel)) || ((|bomb_pixel) && (|peach_pixel));
	assign apple_first = (|apple_pixel) && (|orange_pixel) || (|apple_pixel) && (|peach_pixel);
	assign peach_first = (|peach_pixel) && (|orange_pixel);
	
	assign fruit_pixel = bomb_first ? bomb_pixel : apple_first ? apple_pixel : peach_first? peach_pixel: apple_pixel | orange_pixel | bomb_pixel | peach_pixel;
	assign game_pixel = ((state == PLAY) ? fruit_pixel | pixel_life1 | pixel_life2 | pixel_life3 | cursor_pixel | score : (state == START) ? start_pixel | cursor_pixel : end_pixel | cursor_pixel);
	assign overlap = ((|game_pixel) && (|bg_pixel));
	assign pixel = overlap ? game_pixel : bg_pixel;
	
	assign game_state = (state == GAME_OVER);
	
	assign bomb_slice = (|cursor_pixel && |bomb_pixel) && active_bomb && (state == PLAY);

endmodule
//////////////////////////////////////////////////////////////////////
//
// lookuptable: for random numbers
//
//////////////////////////////////////////////////////////////////////
module lookuptable (input clk, input [2:0] randomnumber,
			output reg [4:0] yvel1, output reg backwards1, output reg [9:0] xcostart1);
							
	always@(posedge clk) begin
		case (randomnumber)
		3'b00: begin yvel1 <= 16; xcostart1 <= 100; backwards1 <= 1; end
		3'b01: begin yvel1 <= 12; xcostart1 <= 200; backwards1 <= 0; end
		3'b10: begin yvel1 <= 16; xcostart1 <= 300; backwards1 <= 0; end
		3'b11: begin yvel1 <= 14; xcostart1 <= 400; backwards1 <= 0; end
		3'b100: begin yvel1 <= 10; xcostart1 <= 500; backwards1 <= 1; end
		3'b101: begin yvel1 <= 14; xcostart1 <= 600; backwards1 <= 0; end
		3'b110: begin yvel1 <= 14; xcostart1 <= 250; backwards1 <= 1; end
		3'b111: begin yvel1 <= 14; xcostart1 <= 300; backwards1 <= 1; end
		endcase
	end
endmodule

module lookuptablebomb (input clk, input [2:0] randomnumber,
			output reg [4:0] yvel1, output reg backwards1, output reg [9:0] xcostart1);
							
	always@(posedge clk) begin
		case (randomnumber)
		3'b00: begin yvel1 <= 16; xcostart1 <= 500; backwards1 <= 0; end
		3'b01: begin yvel1 <= 14; xcostart1 <= 400; backwards1 <= 0; end
		3'b10: begin yvel1 <= 16; xcostart1 <= 200; backwards1 <= 1; end
		3'b11: begin yvel1 <= 14; xcostart1 <= 300; backwards1 <= 0; end
		3'b100: begin yvel1 <= 10; xcostart1 <= 300; backwards1 <= 0; end
		3'b101: begin yvel1 <= 14; xcostart1 <= 510; backwards1 <= 1; end
		3'b110: begin yvel1 <= 14; xcostart1 <= 300; backwards1 <= 0; end
		3'b111: begin yvel1 <= 14; xcostart1 <= 300; backwards1 <= 0; end
		endcase
	end
endmodule