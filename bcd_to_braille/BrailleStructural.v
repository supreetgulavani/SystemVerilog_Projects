//////////////////////////////////////////////////////////////
// BrailleStructural.v - A BCD to Braille converter module file
//
// Author: Supreet Gulavani (sg7@pdx.edu)
// Date:  01/08/2022
//
// Description:
// ------------
// This module is a strucutal description of BCD to Braille converter 
// that takes in BCD input(0-9) and outputs the corresponding Braille digits.  
////////////////////////////////////////////////////////////////

//Module Declaration
module BrailleDigits(BCD,w,x,y,z);
input [3:0] BCD;
output w,x,y,z;
wire w0, w1, x0, x1, x2, x3, x4, x5, x6, y0, y1, z0, z1, z2;

//Structural description
and #(10) 
	and0(w0, x3, BCD[3]),
	and1(w1, BCD[0], x5),
	and2(x0, BCD[0], BCD[3]),
	and3(x1, BCD[1], BCD[2]),
	and4(x2, BCD[0], BCD[1]),
	and5(x6, x3, x4, x5),
	and6(y0, BCD[0], BCD[2]),
	and7(y1, x4, x3),	
	and8(z0, x1),	
	and9(z2, z1, x3);   
not #(10)
	not1(x3, BCD[0]),
	not2(x4, BCD[1]),
	not3(x5, BCD[3]),
	not6(z1, BCD[2]);
or #(10)
	or1(w, w0, w1, BCD[2], BCD[1]),
	or2(x, x0, x1, x2, x6),
	or3(y, y0, y1),
	or4(z, BCD[3], z0, z2);
	
endmodule


