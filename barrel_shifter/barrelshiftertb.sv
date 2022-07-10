//////////////////////////////////////////////////////////////
// barrelshiftertb.sv - A self checking testbench for a 
//			32-bit Barrel Shifter implemented using 2:1 MUX
//
// Author:	Supreet Gulavani (sg7@pdx.edu) 
// Date:	02/05/2022
//
// Description:
// ------------
// A self-checking testbench for a 32-bit Barrel Shifter 
// implemented using five 2:1 MUXs in a dataflow style.
// This testbench will also show the correct expected output.
////////////////////////////////////////////////////////////////

module top();

logic [31:0] In, Out , OutNew, Output;
logic [4:0] ShiftAmount;
logic ShiftIn;

BarrelShifter BS1(.*);

initial begin
	repeat(100) begin
		ShiftAmount = $random();
		ShiftIn = $random();
		//In = 32'b11111111111111111111111111111111;
		In = $random();
		unique case(ShiftAmount)
			5'b00000:
				OutNew =In;
			5'b00001:
				OutNew  = {In[30:0],{1{ShiftIn}}};
			5'b00010:
				OutNew = {In[29:0],{2{ShiftIn}}};
			5'b00011:
				OutNew = {In[28:0],{3{ShiftIn}}};
			5'b00100:
				OutNew = {In[27:0],{4{ShiftIn}}};
			5'b00101:
				OutNew = {In[26:0],{5{ShiftIn}}};
			5'b00110:
				OutNew = {In[25:0],{6{ShiftIn}}};
			5'b00111:
				OutNew = {In[24:0],{7{ShiftIn}}};
			5'b01000:
				OutNew = {In[23:0],{8{ShiftIn}}};
			5'b01001:
				OutNew = {In[22:0],{9{ShiftIn}}};
			5'b01010:
				OutNew = {In[21:0],{10{ShiftIn}}};
			5'b01011:
				OutNew = {In[20:0],{11{ShiftIn}}};
			5'b01100:
				OutNew = {In[19:0],{12{ShiftIn}}};
			5'b01101:
				OutNew = {In[18:0],{13{ShiftIn}}};
			5'b01110:
				OutNew = {In[17:0],{14{ShiftIn}}};
			5'b01111:
				OutNew = {In[16:0],{15{ShiftIn}}};
			5'b10000:
				OutNew = {In[15:0],{16{ShiftIn}}};
			5'b10001:
				OutNew = {In[14:0],{17{ShiftIn}}};
			5'b10010:
				OutNew = {In[13:0],{18{ShiftIn}}};
			5'b10011:
				OutNew = {In[12:0],{19{ShiftIn}}};
			5'b10100:
				OutNew = {In[11:0], {20{ShiftIn}}};
			5'b10101:
				OutNew = {In[10:0],{21{ShiftIn}}};
			5'b10110:
				OutNew = {In[9:0],{22{ShiftIn}}};
			5'b10111:
				OutNew = {In[8:0],{23{ShiftIn}}};
			5'b11000:
				OutNew = {In[7:0], {24{ShiftIn}}};
			5'b11001:
				OutNew = {In[6:0],{25{ShiftIn}}};
			5'b11010:
				OutNew = {In[5:0],{26{ShiftIn}}};
			5'b11011:	
				OutNew = {In[4:0],{27{ShiftIn}}};
			5'b11100:
				OutNew = {In[3:0],{28{ShiftIn}}};
			5'b11101:
				OutNew = {In[2:0],{29{ShiftIn}}};
			5'b11110:
				OutNew = {In[1:0],{30{ShiftIn}}};
			5'b11111:
				OutNew = {In[0],{31{ShiftIn}}};
		endcase
		#100 $display("ShiftAmount: 0x%x\tShitftIn: 0x%x\tModule Input: 0x%x\tModule Output: 0x%x\tExpected Output: 0x%x", ShiftAmount, ShiftIn, In, Out, OutNew );
		if (OutNew != Out)	$display("You messed up. Resolve the bugs. You'll get there\n");
		else			$display("Beautiful! Success is now yours!\n");
	end
end
endmodule

