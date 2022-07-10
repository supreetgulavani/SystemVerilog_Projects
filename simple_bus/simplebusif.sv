//////////////////////////////////////////////////////////////
// simplebusif.sv   -	A 24-bit Simple Bus implementation   
//
// Author:	Supreet Gulavani (sg7@pdx.edu) 
// Date:	02/20/2022
//
// Description:
// ------------
//A 24-bit Simple Bus implementation with one processor interface and multiple
//memory interfaces.
////////////////////////////////////////////////////////////////
module top #(parameter NUMMEM = 10);
 
//NUMMEM: defines number of memory interfaces to be allowed on the bus

logic clock = 1;
logic resetN = 0;
tri dataValid, start, read;
tri [7:0] data, address;

always #5 clock = ~clock;

initial #2 resetN = 1;

//interface instantitation
MainBus mb(clock, resetN);

//Processor module instantiation
ProcessorIntThread p0(mb.ProcessorIntThread);

//multiple memory interfaces modules generation and instantiation
genvar i;
generate 
	for(i = 0; i < NUMMEM; i++) begin
		MemoryIntThread #(.BaseAddr(i)) m0  (mb.MemoryIntThread);
	end
endgenerate
endmodule

//Inteface with two modports
interface MainBus(input logic clock, input logic resetN);
	logic start;
	logic read;
	wire dataValid;
	logic [7:0] address;
	wire [7:0] data;

	modport ProcessorIntThread (
		input clock,
    		input resetN,
    		output start, 
		output read,
    		inout  dataValid,
    		output address,
    		inout  data
 	);
 	 
  	modport MemoryIntThread (
    		input clock, 
		input resetN,
   		input start,
		input read,
    		inout dataValid,
    		input address,
    		inout data
  	);
endinterface

//Processor Interface module
module ProcessorIntThread(MainBus mb);

	logic en_AddrBase, en_AddrUp, en_AddrLo, ld_Data, en_Data, access = 0;
	logic doRead, wDataRdy, dv;
	logic [7:0] DataReg;
	logic [24:0] AddrReg;

	enum {MA,MI,MB,MC,MD} State, NextState;

	assign mb.data = (en_Data) ? DataReg : 'bz;
	assign mb.dataValid = (State == MD) ? dv : 1'bz;

	always_comb 
		if (en_AddrLo) mb.address = AddrReg[7:0];
	  	else if (en_AddrUp) mb.address = AddrReg[15:8];
		else if (en_AddrBase) mb.address = AddrReg[23:16];
	    	else mb.address = 'bz;

    
	always_ff @(posedge mb.clock)
		if (ld_Data) DataReg <= mb.data;
   	
	//reset logic 
	always_ff @(posedge mb.clock, negedge mb.resetN) begin
		if (!mb.resetN) State <= MA;
	    	else State <= NextState;
	end
    
    	//next state logic
	always_comb begin
		mb.start = 0;
		en_AddrBase = 0;
    		en_AddrUp = 0;
	   	en_AddrLo = 0;
	   	mb.read = 0;
	    	ld_Data = 0;
	    	en_Data = 0;
	   	dv = 0;
    
	   	case(State)
	    		MA: begin
	    			NextState = (access) ? MI : MA;
	    			mb.start = (access) ? 1 : 0;
	    			en_AddrBase = (access) ? 1 : 0;
	    		end
			MI: begin
				NextState = MB;
				en_AddrUp = 1;
			end
	   		 MB: begin
	    			NextState = (doRead) ? MC : MD;
	    			en_AddrLo = 1;
	    			mb.read = (doRead) ? 1 : 0;
	    		end
	    		MC: begin
	    			NextState = (mb.dataValid) ? MA : MC;
	    			ld_Data = (mb.dataValid) ? 1 : 0;
	    		end
	   		MD: begin
	    			NextState = (wDataRdy) ? MA : MD;
	    			en_Data = (wDataRdy) ? 1 : 0;
	    			dv = (wDataRdy) ? 1 : 0;
	    		end
	   	endcase
	end

	task WriteMem(input [23:0] Avalue, input [7:0] Dvalue); begin
		access <= 1;
		doRead <= 0;
		wDataRdy <= 1;
		AddrReg <= Avalue;
		DataReg <= Dvalue;
		@(posedge mb.clock) access <= 0;
		@(posedge mb.clock);
		wait (State == MA); 
		repeat (2) @(posedge mb.clock);
		end
	endtask

	task ReadMem(input [23:0] Avalue);   
	begin
		access <= 1;
		doRead <= 1;
		wDataRdy <= 0;
		AddrReg <= Avalue;
		@(posedge mb.clock) access <= 0;
		@(posedge mb.clock);
		wait (State == MA); 
		repeat (2) @(posedge mb.clock);
	end
	endtask


	initial begin
		//extremely exhaustive test case gen. change NUMMEM to 256 for this one
		/*@(posedge mb.clock);
		for (int k = 0; k < 131072; k++) begin
			WriteMem(k, 8'hAC);
			ReadMem(k); 
		end*/
		repeat (1) @(posedge mb.clock);
		WriteMem(24'h000406, 8'hAC);
		ReadMem(24'h000406);
		WriteMem(24'h010000, 8'hAB);
		WriteMem(24'h0200FF, 8'hBA);
		ReadMem(24'h010000);
		WriteMem(24'h030000, 8'hAA);
		WriteMem(24'h040AB0, 8'hBB);	
		ReadMem(24'h0200FF);
		WriteMem(24'h0500CA, 8'hCB);
		ReadMem(24'h030000);
		ReadMem(24'h040AB0);
		WriteMem(24'h060034, 8'hBC);
		WriteMem(24'h073400, 8'h00);
		WriteMem(24'h080110, 8'h10);
		ReadMem(24'h0500CA);
		WriteMem(24'h090999, 8'hFF);
		ReadMem(24'h060034);
		ReadMem(24'h073400);
		ReadMem(24'h080110);
		ReadMem(24'h090999);
		$finish;
	end
endmodule

//Memory Interface
module MemoryIntThread #(parameter BaseAddr = 0)(MainBus mb);

	logic [7:0] Mem[24'hFFFF:0], MemData;
	logic ld_AddrBase, ld_AddrUp, ld_AddrLo, memDataAvail = 0;
	logic en_Data, ld_Data, dv;
	logic [7:0] DataReg;
	logic [23:0] AddrReg;
	logic [7:0] BaseAddrReg = BaseAddr;

	enum {SA, SI, SB, SC, SD} State, NextState;
	
	initial begin
		for (int i = 0; i < 24'hFFFF; i++)
	       		Mem[i] <= 0;
	end
    
	assign mb.data = (en_Data) ? MemData : 'bz;
	assign mb.dataValid = (State == SC) ? dv : 1'bz;
	
	always @(AddrReg, ld_Data)
		MemData = Mem[AddrReg];
 	
	always_ff @(posedge mb.clock)
		if (ld_AddrBase) AddrReg[23:16] <= mb.address;
   
	always_ff @(posedge mb.clock)
		if (ld_AddrUp) AddrReg[15:8] <= mb.address;
    
	always_ff @(posedge mb.clock)
    		if (ld_AddrLo) AddrReg[7:0] <= mb.address;

	always @(posedge mb.clock) begin
    		if (ld_Data) begin
        		DataReg <= mb.data;
        		Mem[AddrReg] <= mb.data;
        	end
    	end
    	
	//reset logic
	always_ff @(posedge mb.clock, negedge mb.resetN)
  		if (!mb.resetN) State <= SA;
  		else State <= NextState;
 
	//next state logic
	always_comb begin
		ld_AddrBase = 0;
   		ld_AddrUp = 0;
	    	ld_AddrLo = 0;
	    	dv = 0;
	    	en_Data = 0;
	    	ld_Data = 0;
	    
	    	case (State)
			SA: begin
				NextState = (mb.start) ? SI : SA;
		    		ld_AddrBase = (mb.start) ? 1 : 0;
		    	end
			SI: begin							//new state to check memory interface to load
				NextState = (AddrReg[23:16] === BaseAddrReg) ? SB : SA;	
				ld_AddrUp = 1;
			end
	    		SB: begin
		    		NextState = (mb.read) ? SC : SD;
		    		ld_AddrLo = 1;
		    	end
		   	SC: begin
			    	NextState = (memDataAvail) ? SA : SC;
			    	dv = (memDataAvail) ? 1 : 0;
			    	en_Data = (memDataAvail) ? 1 : 0;
		    	end
			SD: begin
			    	NextState = (mb.dataValid) ? SA: SD;
			    	ld_Data = (mb.dataValid) ? 1 : 0;
		    	end
		endcase
	end
    
	//testbench code
	always @(State)
    		begin
    		bit [2:0] delay;
    		memDataAvail <= 0;
    		if (State == SC) begin
    			delay = $random;
    			repeat (2 + delay)
    			@(posedge mb.clock);
    			memDataAvail <= 1;
    		end
   	end
    
endmodule