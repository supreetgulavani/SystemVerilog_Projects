//////////////////////////////////////////////////////////////
// BrailleTestbench.v - A BCD to Braille converter testbench file
//
// Author: Supreet Gulavani (sg7@pdx.edu)
// Date:  01/08/2022
//
// Description:
// ------------
// This file is a testbench for BCD to Braille converter 
// that takes in BCD input(0-9) and outputs the corresponding Braille digits.  
////////////////////////////////////////////////////////////////

//Module Description
module top;

reg [3:0] BCD;
wire w, x, y, z;
integer i;

//Instantiation
BrailleDigits BD( .BCD(BCD), .w(w), .x(x), .y(y), .z(z));

//Design Testing
initial begin
$display("BCD to Braille Conversion has begun!");
for(i = 0; i<10; i=i+1) begin
	BCD = i;
	$display("BCD:%b",BCD);
	#30 $display("Braille:%b%b%b%b\n",w, x, y, z);
	end
$display("It is done!");
end
endmodule