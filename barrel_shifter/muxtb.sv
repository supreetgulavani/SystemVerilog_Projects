//////////////////////////////////////////////////////////////
// muxtb.sv - A testbench for 32-bit 2:1 MUX 
//
// Author:	Supreet Gulavani (sg7@pdx.edu) 
// Date:	02/05/2022
//
// Description:
// ------------
// A 32-bit 2:1 MUX that selects an input as the output if the 
// corresponding select line is selected.
////////////////////////////////////////////////////////////////

module muxtop();

parameter CLK_PERIOD = 10;
parameter WIDTH = 32;

logic [WIDTH-1:0] D0, D1, Y;
logic S;

Mux M0(.*);

initial begin
	repeat (10) begin
		S = $random();
		D0 = $random();
		D1 = $random();
		#10 $display("S = 0x%x\tD0:0x%x\tD1:0x%x\tY = 0x%x", S, D0, D1, Y); 
	end
end

endmodule