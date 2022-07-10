//////////////////////////////////////////////////////////////
// fsmtb.sv - Traffic Light Controller Testbench
//
// Author: Supreet Gulavani (sg7@pdx.edu)
// Date:  01/25/2022
//
// Description:
// ------------
// This is a testbench to control the traffic lights on SW 4thAvenue and SW Harrison Street .
// Basically an implementation of a Moore Finite State Machine. Inputs to sensors S1, S2, S3 given
// to check the state of the lights L1, L2, L3. 
////////////////////////////////////////////////////////////////
module top();

parameter CLK_PERIOD = 10;

bit Clock, Reset;
logic S1, S2, S3;
logic [1:0] L1, L2, L3;


always begin: clock_generator
	#(CLK_PERIOD / 2) Clock = ~Clock;
end: clock_generator

fsm F0(.*);

initial begin
	$display("	L1	L2	L3\n");
	$monitor("	%b	%b	%b", L1, L2, L3);
end

initial begin
	
	S1 = 1;
	S2 = 1;
	S3 = 0;
	#20;
	S1 = 0;
	S2 = 0;
	S3 = 1;
	#21;
	S1 = 0;
	S2 = 1;
	S3 = 0;
	#22;
	S1 = 0;
	S2 = 1;
	S3 = 1;
	#23;
	S1 = 1;
	S2 = 0;
	S3 = 0;
	#24;
	S1 = 1;
	S2 = 0;
	S3 = 1;
	#25;
	S1 = 1;
	S2 = 1;
	S3 = 0;
	#26;
	S1 = 1;
	S2 = 1;
	S3 = 1;
	#27;
end

initial begin
	Reset = 0;
	#5;
	Reset = 1;
end

endmodule