`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:52:22 12/07/2018 
// Design Name: 
// Module Name:    blobs 
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
//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////
module blob
   #(parameter WIDTH = 64,            // default width: 64 pixels
               HEIGHT = 64)           // default height: 64 pixels
   (input [23:0] color,
		input clk,
		input [10:0] x,hcount,
		input display,
		input [9:0] y,vcount,
		output reg [23:0] pixel);

   always @ (posedge clk) begin
		if (display) begin
			if ((hcount >= x && hcount < (x+WIDTH)) &&
			(vcount >= y && vcount < (y+HEIGHT)))
				pixel <= color;
			else pixel <= 0; end
		else pixel <= 0;
   end
endmodule

////////////////////////////////////////////////////
//
// play_blob: end screen replay button
//
//////////////////////////////////////////////////
module play_blob
   #(parameter WIDTH = 175,     // default picture width
               HEIGHT = 52)    // default picture height
   (input pixel_clk,
    input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] pixel);

   wire [13:0] image_addr;   // num of bits for 175*52 ROM
   wire [7:0] image_bits, red_mapped;

   // calculate rom address and read the location
   assign image_addr = (hcount-x) + (vcount-y) * WIDTH;
   play rom1(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   play_red rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));

   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk) begin
     if ((hcount >= x && hcount < (x+WIDTH)) &&
          (vcount >= y && vcount < (y+HEIGHT)))
        pixel <= {red_mapped, red_mapped, red_mapped}; // greyscale
//        pixel <= {red_mapped, 8'b0, 8'b0}; // only red hues
        else pixel <= 0;
   end
endmodule
////////////////////////////////////////////////////
//
// replay_blob: end screen replay button
//
//////////////////////////////////////////////////
module replay_blob
   #(parameter WIDTH = 431,     // default picture width
               HEIGHT = 80)    // default picture height
   (input pixel_clk,
    input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] pixel);

   wire [15:0] image_addr;   // num of bits for 431*80 ROM
   wire [7:0] image_bits, red_mapped;

   // calculate rom address and read the location
   assign image_addr = (hcount-x) + (vcount-y) * WIDTH;
   replay rom1(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   replay_red rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));

   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk) begin
     if ((hcount >= x && hcount < (x+WIDTH)) &&
          (vcount >= y && vcount < (y+HEIGHT)))
        pixel <= {red_mapped, red_mapped, red_mapped}; // greyscale
//        pixel <= {red_mapped, 8'b0, 8'b0}; // only red hues
        else pixel <= 0;
   end
endmodule

////////////////////////////////////////////////////
//
// score_blob: end screen score words
//
//////////////////////////////////////////////////
module score_blob
   #(parameter WIDTH = 200,     // default picture width
               HEIGHT = 44)    // default picture height
   (input pixel_clk,
    input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] pixel);

   wire [13:0] image_addr;   // num of bits for 200*44 ROM
   wire [7:0] image_bits, red_mapped;

   // calculate rom address and read the location
   assign image_addr = (hcount-x) + (vcount-y) * WIDTH;
   score rom1(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   score_red rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));

   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk) begin
     if ((hcount >= x && hcount < (x+WIDTH)) &&
          (vcount >= y && vcount < (y+HEIGHT)))
        pixel <= {red_mapped, red_mapped, red_mapped}; // greyscale
//        pixel <= {red_mapped, 8'b0, 8'b0}; // only red hues
        else pixel <= 0;
   end
endmodule

////////////////////////////////////////////////////
//
// hi_blob: high score words
//
//////////////////////////////////////////////////
module hi_blob
   #(parameter WIDTH = 336,     // default picture width
               HEIGHT = 54)    // default picture height
   (input pixel_clk,
    input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] pixel);

   wire [14:0] image_addr;   // num of bits for 299*160 ROM
   wire [7:0] image_bits, red_mapped;

   // calculate rom address and read the location
   assign image_addr = (hcount-x) + (vcount-y) * WIDTH;
   hi rom1(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   hi_red rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
//   hi_green gcm (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
//   hi_blue bcm (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));

   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk) begin
     if ((hcount >= x && hcount < (x+WIDTH)) &&
          (vcount >= y && vcount < (y+HEIGHT)))
        pixel <= {red_mapped, red_mapped, red_mapped};
        else pixel <= 0;
   end
endmodule

////////////////////////////////////////////////////
//
// logo_blob: start screen logo
//
//////////////////////////////////////////////////
module logo_blob
   #(parameter WIDTH = 310,     // default picture width
               HEIGHT = 160)    // default picture height
   (input pixel_clk,
    input [10:0] x,hcount,
    input [9:0] y,vcount,
    output reg [23:0] pixel);

   wire [15:0] image_addr;   // num of bits for 299*160 ROM
   wire [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

   // calculate rom address and read the location
   assign image_addr = (hcount-x) + (vcount-y) * WIDTH;
   logo rom1(.clka(pixel_clk), .addra(image_addr), .douta(image_bits));

   // use color map to create 8 bits R, 8 bits G, 8 bits B
   // since the image is greyscale, just replicate the red pixels
   // and not bother with the other two color maps.
   // use color map to create 8bits R, 8bits G, 8 bits B;
   logo_red rcm (.clka(pixel_clk), .addra(image_bits), .douta(red_mapped));
   logo_green gcm (.clka(pixel_clk), .addra(image_bits), .douta(green_mapped));
   logo_blue bcm (.clka(pixel_clk), .addra(image_bits), .douta(blue_mapped));

   // note the one clock cycle delay in pixel!
   always @ (posedge pixel_clk) begin
     if ((hcount >= x && hcount < (x+WIDTH)) &&
          (vcount >= y && vcount < (y+HEIGHT)))
        pixel <= {red_mapped, green_mapped, blue_mapped};
        else pixel <= 0;
   end
endmodule