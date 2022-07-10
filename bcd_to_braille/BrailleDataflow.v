//////////////////////////////////////////////////////////////
// BrailleDataflow.v - A BCD to Braille converter module file
//
// Author: Supreet Gulavani (sg7@pdx.edu)
// Date:  01/08/2022
//
// Description:
// ------------
// This module is a behavioral dataflow(using only assign statements) 
// description of BCD to Braille converter that takes in BCD input(0-9) 
// and outputs the corresponding Braille digits.  
////////////////////////////////////////////////////////////////

//Module Declaration
module BrailleDigits(BCD,w,x,y,z);	
input [3:0] BCD;			
output w,x,y,z;

//Behavioral Dataflow using only assign statements
assign w = (BCD[3] ^ BCD[0]) | BCD[2] | BCD[1];
assign x = (BCD[3] & BCD[0]) | (BCD[2] & BCD[1]) | (BCD[1] & BCD[0]) | (~BCD[3] & ~BCD[1] & ~BCD[0]);
assign y = (BCD[2] & BCD[0]) | (~BCD[1] & ~BCD[0]);
assign z =  BCD[3] | (BCD[2] & BCD[1]) | (~BCD[2] & ~BCD[0]);

endmodule