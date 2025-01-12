
module PS2_Demo (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7,
	LEDR,
	ps2_key_data,
	ps2_key_pressed
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

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
output 	reg	[9:0] LEDR;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
output wire		[7:0]	ps2_key_data;
output wire		ps2_key_pressed;

// Internal Registers
reg		[7:0]	last_data_received;

reg 		counter;
reg		[3:0] onesDigit;	
reg 		[3:0] tensDigit; 



// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

//Sending signals to LEDs to light up when a,s,d,f keys are pressed
always @(posedge CLOCK_50)
begin
    LEDR[9] = 1'b0;
    LEDR[8] = 1'b0;
    LEDR[7] = 1'b0;
    LEDR[6] = 1'b0;
	 LEDR[5] = 1'b0;
    LEDR[4] = 1'b0;
    LEDR[3] = 1'b0;
    LEDR[2] = 1'b0;
	 LEDR[1] = 1'b0;
	 counter <= 0;
//	 iClick <= 1'b0;
		
      if(ps2_key_data == 8'h1C)
      begin
            LEDR[9] <= 1'b1;
				counter <= 1;
//				iClick <= 1'b1;
      end
      if(ps2_key_data == 8'h1B)
      begin 
            LEDR[8] <= 1'b1;
				counter <= 1;
//				iClick <= 1'b1;
      end
      if(ps2_key_data == 8'h23)
      begin 
            LEDR[7] <= 1'b1;
				counter <= 1;
//				iClick <= 1'b1;
      end
      if(ps2_key_data == 8'h2B)
      begin 
            LEDR[6] <= 1'b1;
				counter <= 1;
//				iClick <= 1'b1;
      end
end
always @(posedge ps2_key_pressed)
begin
	if (KEY[0] == 1'b0)
	begin
		onesDigit <= 4'b0000;
		tensDigit <= 4'b0000;
	end
	else if(last_data_received != ps2_key_data && counter == 1)
	begin
		if(onesDigit == 4'b1001)
		begin
			onesDigit <= 4'b0000;
			if(tensDigit == 4'b1001)
			begin
				tensDigit <= 4'b0000;
			end else
			begin 
				tensDigit <= tensDigit + 1;
			end
		end else
		begin 
			onesDigit <= onesDigit + 1;
		end
		
	end
end




        //8'h1C: keyNum  = 2b'00;
        //8'h1B: keyNum  = 4b'0000;
        //8'h23: keyNum  = 4b'0000;
        //8'h2B: keyNum  = 4b'0000;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

//assign HEX2 = 7'h7F;
//assign HEX3 = 7'h7F;
assign HEX4 = 7'h7F;
assign HEX5 = 7'h7F;
assign HEX6 = 7'h7F;
assign HEX7 = 7'h7F;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(last_data_received[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);
Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(last_data_received[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);


hex_decoder Segment2(
	
	// Inputs
	.c			(onesDigit),
	
	// Outputs
	.display	(HEX2)

);
hex_decoder Segment3(
	
	// Inputs
	.c			(tensDigit),
	
	// Outputs
	.display	(HEX3)

);


endmodule


module hex_decoder(c, display);
   input [3:0] c;
	output [6:0] display;
	
    assign display[0] = ~((c[1]&~c[3]) | (c[3]&~c[0]) | (~c[1]&c[3]&~c[2]) | (~c[0]&~c[3]&~c[2]) | (~c[3]&c[2]&c[0]) | (c[3]&c[2]&c[1]));
    assign display[1] = ~((~c[3]&~c[2]) | (~c[2]&~c[0]) | (~c[3]&~c[1]&~c[0]) | (~c[3]&c[1]&c[0]) | (c[3]&~c[1]&c[0]));
    assign display[2] = ~((~c[3]&c[2]) | (c[3]&~c[2]) | (~c[1]&c[0]) | (~c[3]&~c[1]) | (~c[3]&c[0]));
    assign display[3] = ~((c[3]&~c[1]) | (~c[2]&~c[0]&~c[1])|(~c[2]&~c[3]&c[1])|(c[2]&~c[0]&c[1])|(~c[2]&c[3]&c[0])|(c[2]&c[0]&~c[1]));
    assign display[4] = ~((~c[2]&~c[0]) | (c[1]&~c[0]) | (c[3]&c[1]) | (c[3]&c[2]));
    assign display[5] = ~((c[1]&c[3])|(~c[1]&~c[0])|(~c[1]&~c[3]&c[2])|(c[3]&~c[2]&~c[1])|(c[1]&~c[0]&c[2]));
    assign display[6] = ~((c[0]&c[3])|(c[1]&~c[2])|(c[3]&~c[2])|(c[1]&~c[0])|(~c[3]&c[2]&~c[1]));

endmodule // hex_decoder
