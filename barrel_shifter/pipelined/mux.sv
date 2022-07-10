//////////////////////////////////////////////////////////////
// mux.sv - A 32-bit 2:1 MUX
//
// Author:	Supreet Gulavani (sg7@pdx.edu) 
// Date:	02/05/2022
//
// Description:
// ------------
// A 32-bit 2:1 MUX that selects an input as the output if the 
// corresponding select line is selected.
////////////////////////////////////////////////////////////////

module Mux (D0, D1, S, Y);
	
	parameter WIDTH = 32;

	input logic [WIDTH-1:0] D0, D1;
	input logic S;
	output logic [WIDTH-1:0] Y;

	assign #5 Y = (S == 0) ? D0 : D1;

endmodule