//////////////////////////////////////////////////////////////
// barrelshifter.sv - A 32-bit Barrel Shifter implemented using 2:1 MUX
//
// Author:	Supreet Gulavani (sg7@pdx.edu) 
// Date:	02/05/2022
//
// Description:
// ------------
// A 32-bit Barrel Shifter implemented using 5 2:1 MUXs in a dataflow style.
////////////////////////////////////////////////////////////////

module BarrelShifter(In, ShiftAmount, ShiftIn, Out);

parameter WIDTH = 32;

input logic [WIDTH-1:0] In;
input logic [4:0] ShiftAmount;
input logic ShiftIn;
output logic [WIDTH-1:0] Out;

wire [WIDTH-1:0] In1, a, a1, b, b1, c, c1, d, d1;

Mux m0 (In, In1, ShiftAmount[4], a);
Mux m1 (a, a1, ShiftAmount[3], b);
Mux m2 (b, b1, ShiftAmount[2], c);
Mux m3 (c, c1, ShiftAmount[1], d);
Mux m4 (d, d1, ShiftAmount[0], Out);


assign In1 = (In << 16) | {16{ShiftIn}}; //{In << 16, {16{ShiftIn}}};
assign a1 = (a << 8) | {8{ShiftIn}};//{a << 8, {8{ShiftIn}}};
assign b1 = (b << 4) | {4{ShiftIn}};//{b << 4, {4{ShiftIn}}};
assign c1 = (c << 2) | {2{ShiftIn}};//{c << 2, {2{ShiftIn}}};
assign d1 = (d << 1) |  ShiftIn ;//{d << 1, {1{ShiftIn}}};

endmodule