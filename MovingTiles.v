//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

//
// This is the template for Part 1 of Lab 8.
//
// Paul Chow
// November 2021
//

// iColour is the colour for the box
//
// oX, oY, oColour and oPlot should be wired to the appropriate ports on the VGA controller
//

// Some constants are set as parameters to accommodate the different implementations
// X_SCREEN_PIXELS, Y_SCREEN_PIXELS are the dimensions of the screen
//       Default is 160 x 120, which is size for fake_fpga and baseline for the DE1_SoC vga controller
// CLOCKS_PER_SECOND should be the frequency of the clock being used.

module MovingTiles
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		SW,
		LEDR,
		PS2_CLK,
		PS2_DAT,
		HEX0,
		HEX1,
		HEX2,
		HEX3,
		HEX4,
		HEX5,
		HEX6,
		HEX7,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]	
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;		
	// Declare your inputs and outputs here
	input [9:0] SW;
	
		// Bidirectionals
	inout				PS2_CLK;
	inout				PS2_DAT;

	// Outputs
	output		[6:0]	HEX0;
	output		[6:0]	HEX1;
	output		[6:0]	HEX2;
	output		[6:0]	HEX3;
	output		[6:0]	HEX4;
	output		[6:0]	HEX5;
	output		[6:0]	HEX6;
	output		[6:0]	HEX7;
	output 		[9:0] LEDR;
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire done;
	
	wire [7:0] ps2_key_data;
	wire ps2_key_pressed;
	


	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	PS2_Demo p0(CLOCK_50, KEY[3:0], PS2_CLK, PS2_DAT, HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7,LEDR[9:0], ps2_key_data, ps2_key_pressed);
	vga v1(resetn,CLOCK_50,ps2_key_pressed, x,y,colour,writeEn,done);

	
endmodule


module vga(iResetn,iClock,iClick, oX,oY,oColour,oPlot, oDone);
   input wire 	    iResetn;
   input wire 	    iClock;
	input wire 		 iClick;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel drawn enable
   output wire       oDone;

   parameter
     X_BOXSIZE = 8'd40,   // Box X dimension
     Y_BOXSIZE = 7'd20,   // Box Y dimension
		X_SCREEN_PIXELS = 8'd160,
		Y_SCREEN_PIXELS = 7'd120,

     CLOCKS_PER_SECOND = 50000000, // 5 KHZ for fake_fpga
     X_MAX = X_SCREEN_PIXELS - 1 - X_BOXSIZE, // 0-based and account for box width
     Y_MAX = Y_SCREEN_PIXELS - 1 - Y_BOXSIZE,

     FRAMES_PER_UPDATE = 15,
     PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60
	       ;

   //
   // Your code goes here
	wire gameover, clear;
	
	wire DelayCounter,nextFrame;
	wire[6:0] FrameCounter;
	
	wire ld_play, ld_wait, ld_clear, ld_reset, ld_red, ld_check;
	
	control c0(iClock, iResetn, iClick,  clear, nextFrame, gameover, oDone, ld_play, ld_wait, ld_clear, ld_reset, ld_red, ld_check, oPlot);
	
	datapath #(X_BOXSIZE, Y_BOXSIZE, X_SCREEN_PIXELS, Y_SCREEN_PIXELS, CLOCKS_PER_SECOND,X_MAX, Y_MAX, FRAMES_PER_UPDATE,PULSES_PER_SIXTIETH_SECOND) d0(iClock, iResetn, iClick, ld_play, ld_wait, ld_clear, ld_reset, ld_red, ld_check, clear, nextFrame, gameover,DelayCounter, FrameCounter, oX, oY, oDone, oColour);
	
   //


endmodule // part1


module control(iClock, iResetn, iClick,  clear, nextFrame, gameover, oDone, ld_play, ld_wait, ld_clear, ld_reset, ld_red, ld_check, oPlot);
	
	input iClock, iResetn, iClick, oDone, gameover, clear, nextFrame;
	output reg ld_play, ld_wait, ld_clear, ld_reset, ld_red, ld_check, oPlot;

	reg [3:0] current_state, next_state;
	
	reg temp;
	
	localparam 	S_START = 4'd0,
					S_PLAY = 4'd1,
					S_CLEAR= 4'd2,
					S_WAIT = 4'd3,
					S_LOST = 4'd4,
					S_START_WAIT = 4'd5,
					S_PLAY_WAIT = 4'd6,
					S_CHECK_CORRECT = 4'd7;
					
					
	always@(*)
   begin: state_table
			case(current_state)
				S_START: next_state = iClick ? S_START_WAIT: S_START;
				S_START_WAIT: next_state = iClick ? S_START_WAIT : S_PLAY;
				S_PLAY: begin
//					if(oDone)
//						next_state = S_WAIT;
//					else 
//						next_state = S_PLAY;
//					end
//				begin
					if(iClick) next_state = S_PLAY_WAIT;
					else if(gameover) next_state = S_LOST;
					else next_state = oDone? S_WAIT : S_PLAY;
				end
				S_CHECK_CORRECT: next_state = gameover ? S_LOST : S_PLAY_WAIT;
				S_PLAY_WAIT: next_state = iClick ? S_PLAY_WAIT : S_CLEAR;
				S_CLEAR: next_state = oDone? S_PLAY : S_CLEAR;
				S_WAIT: begin if(iClick) next_state = S_PLAY_WAIT;
									else next_state = nextFrame ? S_PLAY : S_WAIT;
				end
				S_LOST: next_state = S_LOST;
				default next_state = S_LOST;
			endcase
	end
			
	always @(*)
   begin: enable_signals
		
		ld_play = 1'b0;
		oPlot = 1'b0;
		ld_wait = 1'b0;
		ld_clear = 1'b0;
		ld_reset = 1'b0;
		ld_red = 1'b0;
		ld_check = 1'b0;
		
		case(current_state)
			S_START: begin
				ld_clear = 1'b1;
			end
			S_PLAY: begin
				ld_play = 1'b1;
				oPlot = 1'b1;
				
			end
			S_CLEAR: begin
				
				ld_clear = 1'b1;
				oPlot = 1'b1;
				
			end
			S_WAIT: begin
				ld_wait = 1'b1;
			end
			S_LOST: begin
				ld_clear = 1'b1;
				ld_red = 1'b1;
				oPlot = 1'b1;
			end
			S_PLAY_WAIT: begin
				ld_reset = 1'b1;
			end
			S_START_WAIT: begin
				ld_clear = 1'b1;
			end
			S_CHECK_CORRECT: begin
				ld_check = 1'b1;
			end
		endcase
	end

	always@(posedge iClock)
    begin: state_FFs
        if(~iResetn) 
            current_state <= S_START;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module datapath(iClock, iResetn, iClick, ld_play, ld_wait, ld_clear, ld_reset, ld_red, ld_check,  clear, nextFrame, gameover, DelayCounter, FrameCounter, oX, oY, oDone, oColour);

	parameter
     X_BOXSIZE = 8'd40,   // Box X dimension
     Y_BOXSIZE = 7'd20,   // Box Y dimension
		X_SCREEN_PIXELS = 8'd160,
		Y_SCREEN_PIXELS = 7'd120,

     CLOCKS_PER_SECOND = 50000000, // 5 KHZ for fake_fpga
     X_MAX = X_SCREEN_PIXELS - 1 - X_BOXSIZE, // 0-based and account for box width
     Y_MAX = Y_SCREEN_PIXELS - 1 - Y_BOXSIZE,

     FRAMES_PER_UPDATE = 15,
     PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60;

	input iClock, iResetn, iClick, ld_play, ld_wait, ld_clear, ld_reset, ld_red, ld_check;
	
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColour;
	output reg oDone, clear, nextFrame, gameover, DelayCounter; 
	output reg[6:0] FrameCounter;
	
	reg [7:0] X;
	reg [6:0] Y;
	reg [2:0] Colour;
	
	reg[4:0] speed;
	reg [1:0] score;
	
	reg[7:0] lfsr;
	
	reg [7:0] CountX, CountY;
	reg black, predone;
	reg [$clog2(PULSES_PER_SIXTIETH_SECOND):0] Counter;
	
	always@(posedge iClock) begin
        if(~iResetn) begin
				lfsr <= 8'b01001101;
            X <= 8'b0;
            Y <= 7'b0;
            Colour <= 3'b0; 
				oDone <= 1'b0;
				oX <= 1'b0;
				oY <= 1'b0;
				oColour <= 3'b0;
				CountX <= 8'd0;
				CountY <= 8'd0;
				black <= 1'b0;
				predone <= 1'b0;
				clear <= 1'b0;
				nextFrame <= 1'b0;
				gameover <= 1'b0;
				Counter <= 1'd0;
				DelayCounter <= 1'b0;
				FrameCounter <= 7'd0;
				speed <= 5'd7;
				score <= 0;
				
        end
        else begin
				
				nextFrame <= 1'b0;
				oDone <= 1'b0;
				Counter <= Counter + 1'b1;
				clear = 1'b0;
				
				if(ld_play) begin
					black = 1'b0;
					oX <= X + CountX;
					oY <= Y + CountY;
					if(Y + CountY == Y_SCREEN_PIXELS) begin
						gameover = 1'b1;
						Y <= 7'd0;
						oX <= 8'd0;
						oY <= 7'd0;
						oDone <= 1'b1;
					end else if(CountX == X_BOXSIZE-1 & CountY == Y_BOXSIZE)begin
						oDone <= 1'b1;
					end else if(CountX == X_BOXSIZE-1) begin
						CountY <= CountY + 1'b1;
						CountX <= 1'b0;
					end else 
						CountX <= CountX + 1'b1;
					if(CountY == 2'b0) begin
						oColour <= 3'b0;
					end else 
						oColour <= 3'b111;
							
				end
				if(ld_wait) begin
					if(Counter >= PULSES_PER_SIXTIETH_SECOND) begin
						DelayCounter <= 1'b1;
						Counter <= 1'b0;
						FrameCounter <= FrameCounter + 7'd1;
						
					end else begin
						DelayCounter <= 1'b1;
					end
					if(FrameCounter == speed) begin
						Y <= Y + 1'd1;
						nextFrame <= 1'b1;
						FrameCounter <= 6'd0;
						CountX <= 3'b0;
						CountY <= 3'b0;
					end
				end
				if(ld_reset) begin
					if(~black) begin
						X <= lfsr[1:0]*8'd40;
						Y <= 1'b0;
						FrameCounter <= 6'd0;
						CountX <= 3'b0;
						CountY <= 3'b0;
						oX <= 8'd0;
						oY <= 7'd0;
						score <= score + 2'd1;
						if(score == 2'd3) begin
							if(speed <= 5'd1) speed <= 5'd1;
							else
							speed <= speed - 5'd1;
							score <= 2'd0;
						
						end
						black = 1'b1;
						lfsr[6] <= lfsr[7];
						lfsr[5] <= lfsr[6];
						lfsr[4] <= lfsr[5];
						lfsr[3] <= lfsr[4];
						lfsr[2] <= lfsr[3];
						lfsr[1] <= lfsr[2];
						lfsr[0] <= lfsr[1];
						lfsr[7] <= lfsr[0]^lfsr[1];
					end
					
				end
				if(ld_check)begin
					
				end
				if(ld_clear) begin
					
						
						Y <= 7'd0;
						oColour <= 3'b000;
//						oX <= 8'd10;
//						oY <= 7'd10;
						if(ld_red) oColour <= 3'b100;
						
						if(oX >= 8'd160 & oY >= 7'd120) begin
							oDone <= 1'b1;
							black <= 1'b0;
							oX <= 8'd0;
							oY <= 7'd0;
						end else if(oX >= X_SCREEN_PIXELS) begin
						
							oX <= 8'd0;
							oY <= oY + 7'd1;
							
						end else
							oX <= oX + 8'd1;
					
				end
				
		end
	end
	
	
endmodule

