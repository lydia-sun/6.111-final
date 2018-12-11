`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:32:27 11/04/2018 
// Design Name: 
// Module Name:    fruit_and_bomb 
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
////////////////////////////////////////////////////
//
// apple: display an apple blob
//
//////////////////////////////////////////////////
module apple
   #(parameter WIDTH = 150,     // default picture width
               HEIGHT = 150)    // default picture height
   (input pixel_clk,
	 input [2:0] slice,
    input [10:0] x, xslice, hcount,
    input [9:0] y, yslice, vcount,
	 input active,
    output reg [23:0] pixel);
	
	reg [14:0] image_addr;
   wire [14:0] image_addr_1; wire [14:0] image_addr_2;   // num of bits for 256*240 ROM
//	wire [7:0] image_bits_1, red_mapped_1, green_mapped_1, blue_mapped_1;
   wire [7:0] image_bits, red_mapped, green_mapped, blue_mapped;
	reg currentinactive; reg oldnotinair;

   // calculate rom address and read the location
   assign image_addr_1 = (hcount-x) + (vcount-y) * WIDTH;
   rom2 apple_rom2(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));
	assign image_addr_2 = (hcount-xslice) + (vcount-yslice) * WIDTH + (WIDTH * HEIGHT/2);
//	rom2 apple_rom(.clka(pixel_clk), .addra(image_addr_1), .douta(image_bits_1));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   apple_red_rom rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
   apple_green_rom gcm (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
   apple_blue_rom bcm (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));

//	apple_red_rom rcm1 (.clka(pixel_clk), .addra(image_bits_1), .douta(red_mapped_1));
//   apple_green_rom gcm1 (.clka(pixel_clk), .addra(image_bits_1), .douta(green_mapped_1));
//   apple_blue_rom bcm1 (.clka(pixel_clk), .addra(image_bits_1), .douta(blue_mapped_1));
	
	parameter SLICE_WIDTH = 10;
   // note the one clock cycle delay in pixel!
   always @(posedge pixel_clk) begin
		if (active) begin
			if ((hcount >= x && hcount < (x+WIDTH)) && (vcount >= y && vcount < (y+HEIGHT)))
				case (slice)
					0: begin
							pixel <= {red_mapped,green_mapped, blue_mapped};
							image_addr <= image_addr_1;
						end
					1: begin 
							if (((vcount >= y + HEIGHT/2 )) && (hcount >= x && hcount < (x+WIDTH))) pixel <= 0; 
							else begin
								pixel <= {red_mapped,green_mapped, blue_mapped};
								image_addr <= image_addr_1;
							end
						end
					default: begin
						pixel <= {red_mapped,green_mapped, blue_mapped};
						image_addr <= image_addr_1;
					end
				endcase
			else pixel <= 0;
			
			if ((hcount >= xslice && hcount < (xslice+WIDTH)) && (vcount >= yslice && vcount < (yslice+HEIGHT)))
				if (slice == 1) begin
					if (((vcount < yslice + HEIGHT/2) && (vcount > yslice)) && (hcount >= xslice && hcount < (xslice+WIDTH))) begin
						pixel <= {red_mapped,green_mapped,blue_mapped};
						image_addr <= image_addr_2;
					end
				end 	
			end
		else pixel <= 0;
	end
endmodule

module bomb
   #(parameter WIDTH = 150,     // default picture width
               HEIGHT = 150)    // default picture height
   (input pixel_clk,
	 input [2:0] slice,
    input [10:0] x,hcount,
    input [9:0] y,vcount,
	 input active,
    output reg [23:0] pixel);

   wire [14:0] image_addr;   // num of bits for 256*240 ROM
   wire [7:0] image_bits, red_mapped, green_mapped, blue_mapped;
	reg currentinactive; reg oldnotinair;

   // calculate rom address and read the location
   assign image_addr = (hcount-x) + (vcount-y) * WIDTH;
   bomb_rom bomb(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   bomb_red_rom rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
   bomb_green_rom gcm (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
   bomb_blue_rom bcm (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));
	
	parameter SLICE_WIDTH = 10;
   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk) begin
		if (active) begin
			if ((hcount >= x && hcount < (x+WIDTH)) && (vcount >= y && vcount < (y+HEIGHT)))
				pixel = {red_mapped, green_mapped, blue_mapped};
			else pixel = 0;
		end
	end
endmodule

module peach
   #(parameter WIDTH = 132,     // default picture width
               HEIGHT = 150)    // default picture height
   (input pixel_clk,
	 input [2:0] slice,
    input [10:0] x, xslice, hcount,
    input [9:0] y, yslice, vcount,
	 input active,
    output reg [23:0] pixel);
	
	wire [14:0] image_addr_1, image_addr_2;
   reg [14:0] image_addr;   // num of bits for 256*240 ROM
   wire [7:0] image_bits;
	wire [7:0] red_mapped, green_mapped, blue_mapped;
	reg [7:0] clockimagebits;
	reg currentinactive; reg oldnotinair;

   // calculate rom address and read the location
   assign image_addr_1 = (hcount-x) + (vcount-y) * WIDTH;
	assign image_addr_2 = (hcount-xslice) + (vcount-yslice) * WIDTH + (WIDTH * HEIGHT/2);
	
   peach_rom peach(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   peach_red_rom rcm (.clka(pixel_clk), .addra(clockimagebits), .douta(red_mapped));
   peach_green_rom gcm (.clka(pixel_clk), .addra(clockimagebits), .douta(green_mapped));
   peach_blue_rom bcm (.clka(pixel_clk), .addra(clockimagebits), .douta(blue_mapped));
	
	parameter SLICE_WIDTH = 10;
   // note the one clock cycle delay in pixel!
//   always @ (posedge pixel_clk) begin
//		if (active) begin
//			if ((hcount >= x && hcount < (x+WIDTH)) && (vcount >= y && vcount < (y+HEIGHT)))
//			case (slice)
//				0: pixel = {red_mapped, green_mapped, blue_mapped};
//				2: if (((hcount >= x + WIDTH/2 - SLICE_WIDTH/2) && hcount < (x+WIDTH/2 + SLICE_WIDTH/2)) && (vcount >= y && vcount < (y+HEIGHT))) pixel = 0; 
//					else pixel = {red_mapped, green_mapped, blue_mapped};
//				1: if (((vcount >= y + HEIGHT/2 - SLICE_WIDTH/2) && vcount < (y+HEIGHT/2 + SLICE_WIDTH/2)) && (hcount >= x && hcount < (x+WIDTH))) pixel = 0; 
//					else pixel = {red_mapped, green_mapped, blue_mapped};
//				3: if (((vcount - y) <= (hcount - x) + SLICE_WIDTH/2) && ((vcount - y) >= (hcount - x) - SLICE_WIDTH/2)) pixel = 0;
//					else pixel = {red_mapped, green_mapped, blue_mapped};
//				4: if (((vcount - y) <= (x-hcount) + SLICE_WIDTH/2 + HEIGHT) && ((vcount - y) >= (x-hcount) - SLICE_WIDTH/2 + HEIGHT)) pixel = 0;
//					else pixel = {red_mapped, green_mapped, blue_mapped};
//				default: pixel = {red_mapped, green_mapped, blue_mapped};
//			endcase
//			else pixel = 0; end
//		else pixel = 0;
//		
//	end
	always @(posedge pixel_clk) begin
	clockimagebits <= image_bits;
		if (active) begin
			if ((hcount >= x && hcount < (x+WIDTH)) && (vcount >= y && vcount < (y+HEIGHT)))
				case (slice)
					0: begin
							pixel <= {red_mapped,green_mapped, blue_mapped};
							image_addr <= image_addr_1;
						end
					1: begin 
							if (((vcount >= y + HEIGHT/2 )) && (hcount >= x && hcount < (x+WIDTH))) pixel <= 0; 
							else begin
								pixel <= {red_mapped,green_mapped, blue_mapped};
								image_addr <= image_addr_1;
							end
						end
					default: begin
						pixel <= {red_mapped,green_mapped, blue_mapped};
						image_addr <= image_addr_1;
					end
				endcase
			else pixel <= 0;
			
			if ((hcount >= xslice && hcount < (xslice+WIDTH)) && (vcount >= yslice && vcount < (yslice+HEIGHT)))
				if (slice == 1) begin
					if (((vcount < yslice + HEIGHT/2) && (vcount > yslice)) && (hcount >= xslice && hcount < (xslice+WIDTH))) begin
						pixel <= {red_mapped,green_mapped,blue_mapped};
						image_addr <= image_addr_2;
					end
				end 	
			end
		else pixel <= 0;
	end
endmodule

module orange
   #(parameter WIDTH = 150,     // default picture width
               HEIGHT = 150)    // default picture height
   (input pixel_clk,
	 input [2:0] slice,
    input [10:0] x, xslice, hcount,
    input [9:0] y, yslice, vcount,
	 input active,
    output reg [23:0] pixel);

   reg [14:0] image_addr;   // num of bits for 150*150 ROM
	wire [14:0] image_addr_1, image_addr_2;
   wire [7:0] image_bits, red_mapped, green_mapped, blue_mapped;
	reg currentinactive; reg oldnotinair;

   // calculate rom address and read the location
   assign image_addr_1 = (hcount-x) + (vcount-y) * WIDTH;
	assign image_addr_2 = (hcount-xslice) + (vcount-yslice) * WIDTH + (WIDTH * HEIGHT/2);
   orange_rom apple_rom2(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   orange_red_rom rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
   orange_green_rom gcm (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
   orange_blue_rom bcm (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));
	
	parameter SLICE_WIDTH = 10;
   // note the one clock cycle delay in pixel!
//   always @ (posedge pixel_clk) begin
//		if (active) begin
//			if ((hcount >= x && hcount < (x+WIDTH)) && (vcount >= y && vcount < (y+HEIGHT)))
//			case (slice)
//				0: pixel = {red_mapped, green_mapped, blue_mapped};
//				2: if (((hcount >= x + WIDTH/2 - SLICE_WIDTH/2) && hcount < (x+WIDTH/2 + SLICE_WIDTH/2)) && (vcount >= y && vcount < (y+HEIGHT))) pixel = 0; 
//					else pixel = {red_mapped, green_mapped, blue_mapped};
//				1: if (((vcount >= y + HEIGHT/2 - SLICE_WIDTH/2) && vcount < (y+HEIGHT/2 + SLICE_WIDTH/2)) && (hcount >= x && hcount < (x+WIDTH))) pixel = 0; 
//					else pixel = {red_mapped, green_mapped, blue_mapped};
//				3: if (((vcount - y) <= (hcount - x) + SLICE_WIDTH/2) && ((vcount - y) >= (hcount - x) - SLICE_WIDTH/2)) pixel = 0;
//					else pixel = {red_mapped, green_mapped, blue_mapped};
//				4: if (((vcount - y) <= (x-hcount) + SLICE_WIDTH/2 + HEIGHT) && ((vcount - y) >= (x-hcount) - SLICE_WIDTH/2 + HEIGHT)) pixel = 0;
//					else pixel = {red_mapped, green_mapped, blue_mapped};
//				default: pixel = {red_mapped, green_mapped, blue_mapped};
//			endcase
//			else pixel = 0; end
//		else pixel = 0;
//	end
	always @(posedge pixel_clk) begin
		if (active) begin
			if ((hcount >= x && hcount < (x+WIDTH)) && (vcount >= y && vcount < (y+HEIGHT)))
				case (slice)
					0: begin
							pixel <= {red_mapped,green_mapped, blue_mapped};
							image_addr <= image_addr_1;
						end
					1: begin 
							if (((vcount >= y + HEIGHT/2 )) && (hcount >= x && hcount < (x+WIDTH))) pixel <= 0; 
							else begin
								pixel <= {red_mapped,green_mapped, blue_mapped};
								image_addr <= image_addr_1;
							end
						end
					default: begin
						pixel <= {red_mapped,green_mapped, blue_mapped};
						image_addr <= image_addr_1;
					end
				endcase
			else pixel <= 0;
			
			if ((hcount >= xslice && hcount < (xslice+WIDTH)) && (vcount >= yslice && vcount < (yslice+HEIGHT)))
				if (slice == 1) begin
					if (((vcount < yslice + HEIGHT/2) && (vcount > yslice)) && (hcount >= xslice && hcount < (xslice+WIDTH))) begin
						pixel <= {red_mapped,green_mapped,blue_mapped};
						image_addr <= image_addr_2;
					end
				end 	
			end
		else pixel <= 0;
	end
endmodule