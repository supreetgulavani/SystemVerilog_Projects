//////////////////////////////////////////////////////////////
// fsm.sv - Traffic Light Controller 
//
// Author: Supreet Gulavani (sg7@pdx.edu)
// Date:  01/25/2022
//
// Description:
// ------------
// This is a module for to control the traffic lights on SW 4thAvenue and SW Harrison Street .
// Basically an implementation of a Moore Finite State Machine. Instantiates a module called
// counter that counts down the time for which signal would remain ON/OFF.
////////////////////////////////////////////////////////////////
typedef enum {ALL_RED_to_L1_GREEN, L1_GREEN, L1_GREEN_WAIT, L1_YELLOW_BEGIN, L1_YELLOW, ALL_RED_to_L23_GREEN, L23_GREEN, L23_GREEN_WAIT, L23_YELLOW_BEGIN, L23_YELLOW, FAILSAFE} state;

module fsm(Clock, Reset, S1, S2, S3, L1, L2, L3);
input Clock;
input Reset;
input			//sensors for approaching vehicles
	S1,		//northbound on SW 4th ave
	S2,		//eastbound on SW Harrison St
	S3;		//westbound on SW Harrison St
output reg [1:0]	//outputs for controlling traffic lights
	L1, 		//light for NB SW 4th Ave
	L2,		//light for EB SW Harrison St
	L3;		//light for WB SW Harrison St

logic load, decr;
logic [7:0] value;
logic timeup;

state st = ALL_RED_to_L1_GREEN;
state ns = ALL_RED_to_L1_GREEN;

counter c0 (.clk(Clock), .reset(~Reset), .load(load), .value(value), .decr(decr), .timeup(timeup)); ///count45

//state logic
always_comb begin
	case(st)
		ALL_RED_to_L1_GREEN: begin	
			ns = L1_GREEN;
			load = 1'b0;
			value = 8'b0;
			decr = 1'b0;
			L1 = 2'b11;
			L2 = 2'b11;
			L3 = 2'b11; 
		end
		L1_GREEN: begin
			load = 1'b1;
			value = 8'b00101100;
			decr = 1'b0;
			L1 = 2'b01;
			L2 = 2'b11;
			L3 = 2'b11;
			ns = L1_GREEN_WAIT;
			
		end
		L1_GREEN_WAIT: begin
			load = 1'b0;
			decr = 1'b1;
			L1 = 2'b01;
			L2 = 2'b11;
			L3 = 2'b11;
			if (timeup & ((S2||S3)))	ns = L1_YELLOW_BEGIN;
			else 				ns = L1_GREEN_WAIT;
		end
		L1_YELLOW_BEGIN: begin
			load = 1'b1;
			value = 8'b00000100;
			decr = 1'b0;
			L1 = 2'b10;
			L2 = 2'b11;
			L3 = 2'b11;
			ns = L1_YELLOW;
		end
		L1_YELLOW: begin
			load = 1'b0;
			decr = 1'b1;
			if(timeup)	ns = ALL_RED_to_L23_GREEN;
			else 		ns = L1_YELLOW;
			L1 = 2'b10;
			L2 = 2'b11;
			L3 = 2'b11;
		end
		ALL_RED_to_L23_GREEN: begin
			L1 = 2'b11;
			L2 = 2'b11;
			L3 = 2'b11;
			ns = L23_GREEN;
		end
		L23_GREEN: begin
			load = 1'b1;
			value = 8'b00001110;
			decr = 1'b0;
			L1 = 2'b11;
			L2 = 2'b01;
			L3 = 2'b01;
			ns = L23_GREEN_WAIT;
		end	
		L23_GREEN_WAIT: begin
			load = 1'b0;
			decr = 1'b1;
			if(timeup)	ns = L23_YELLOW_BEGIN;
			else 		ns = L23_GREEN_WAIT;
		end
		L23_YELLOW_BEGIN: begin
			load = 1'b1;
			value = 8'b00000100;
			decr = 1'b0;
			L1 = 2'b11;
			L2 = 2'b10;
			L3 = 2'b10;
			ns = L23_YELLOW;
		end
		L23_YELLOW: begin
			load = 1'b0;
			decr = 1'b1;
			L1 = 2'b11;
			L2 = 2'b10;
			L3 = 2'b10;
			if(timeup)	ns = ALL_RED_to_L1_GREEN;
			else 		ns = L23_YELLOW;
		end 
	endcase
end

always_ff @(posedge Clock, negedge Reset) begin
	if (!Reset)	st <= ALL_RED_to_L1_GREEN;
	else		st <= ns;
end


endmodule
