//////////////////////////////////////////////////////////////
// barrelshifter.sv - A pipelined 32-bit Barrel Shifter implemented using 2:1 MUX
//
// Author:	Supreet Gulavani (sg7@pdx.edu) 
// Date:	02/11/2022
//
// Description:
// ------------
// A pipelined 32-bit Barrel Shifter implemented using 5 2:1 MUXs
////////////////////////////////////////////////////////////////
module BarrelShifter(Clock, In, ShiftAmount, ShiftIn, Out);

parameter WIDTH = 32;

input logic Clock, ShiftIn;
input logic [WIDTH-1:0] In;
input logic [4:0] ShiftAmount;
output logic [WIDTH-1:0] Out;

var logic [WIDTH-1:0] In1, a, b, c, d, itmout; 

struct {
	logic [WIDTH-1:0] inp;
	logic [WIDTH-1:0] inp1;
	logic [4:0] shamt;
	logic shiftin;
}buf1;	

struct {
	logic [WIDTH-1:0] inp;
	logic [WIDTH-1:0] inp1;
	logic [4:0] shamt;
	logic shiftin;
}buf2;	

struct {
	logic [WIDTH-1:0] inp;
	logic [WIDTH-1:0] inp1;
	logic [4:0] shamt;
	logic shiftin;
}buf3;;	

struct {
	logic [WIDTH-1:0] inp;
	logic [WIDTH-1:0] inp1;
	logic [4:0] shamt;
}buf4;	


Mux m0 (In, In1, ShiftAmount[4], a);
Mux m1 (buf1.inp, buf1.inp1, buf1.shamt[3], b);
Mux m2 (buf2.inp, buf2.inp1, buf2.shamt[2], c);
Mux m3 (buf3.inp, buf3.inp1, buf3.shamt[1], d);
Mux m4 (buf4.inp, buf4.inp1, buf4.shamt[0], itmout);

assign In1 = (In << 16) | {16{ShiftIn}};

always_ff @(posedge Clock) begin
	buf1.inp <= a;
	buf1.inp1 <= (a << 8) | {8{ShiftIn}};;
	buf1.shiftin <= ShiftIn;
	buf1.shamt <= ShiftAmount;
	buf2.inp <= b;
	buf2.inp1 <= (b << 4) | {4{buf1.shiftin}};;
	buf2.shamt <= buf1.shamt;
	buf2.shiftin <= buf1.shiftin;
	buf3.inp <= c;
	buf3.inp1 <= (c << 2) | {2{buf2.shiftin}};;
	buf3.shamt <= buf2.shamt;
	buf3.shiftin <= buf2.shiftin;
	buf4.inp <= d;
	buf4.inp1 <= (d << 1) |  buf3.shiftin;
	buf4.shamt <= buf3.shamt;
	Out <= itmout; 
end
endmodule