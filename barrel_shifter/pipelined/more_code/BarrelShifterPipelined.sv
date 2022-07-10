`define STANDALONE
`ifdef STANDALONE

/*

n-bit 2-to-1 multiplexer with parameterized width and delay

*/

module Multiplexer(A, B, Select, Out);
parameter WIDTH = 8;
parameter DELAY = 5;
input [WIDTH-1:0] A, B;
input Select;
output [WIDTH-1:0] Out;

assign #DELAY Out = (Select ? B : A);
endmodule



/*

n-bit BarrelShifter using series of multiplexors.   Shifts left by ShiftAmount.

*/

module BarrelShifter(Clock, In, ShiftAmount, ShiftIn, Out);
parameter WIDTH = 32;
parameter DELAY = 5;
input Clock;
input [WIDTH-1:0] In;
input [$clog2(WIDTH)-1:0] ShiftAmount;
input ShiftIn;
output [WIDTH-1:0] Out;

// Pipeline register

struct packed {
  logic [WIDTH-1:0] In;
  logic [$clog2(WIDTH)-1:0] ShiftAmount;
  logic ShiftIn;
 } R [$clog2(WIDTH):0];

// inputs for first state of combinational logic -- not actually in registers

assign R[$clog2(WIDTH)].In = In;
assign R[$clog2(WIDTH)].ShiftIn = ShiftIn;
assign R[$clog2(WIDTH)].ShiftAmount = ShiftAmount;

assign Out = R[0].In;							// module output is last stage register output

wire [WIDTH-1:0] StageOut[$clog2(WIDTH)-1:0];		// output for combinational logic

genvar i;

generate
for (i = ($clog2(WIDTH))-1; i >= 0; i = i - 1)
  begin
  always_ff @(posedge Clock)
    begin
    R[i].In <= StageOut[i];
    R[i].ShiftIn <= R[i+1].ShiftIn;
    R[i].ShiftAmount <= R[i+1].ShiftAmount;
    end
   
  Multiplexer #(WIDTH, DELAY) M(R[i+1].In, {R[i+1].In[0 +:(WIDTH-(2**i))], {(2**i){R[i+1].ShiftIn}}}, R[i+1].ShiftAmount[i], StageOut[i]);
  end
endgenerate
endmodule

`endif


module top();
parameter WIDTH = 32;
parameter DELAY = 5;
localparam MAXCLOCKS = $clog2(WIDTH) + 2;

reg Error;

logic [WIDTH-1:0] In;
logic [$clog2(WIDTH)-1:0] ShiftAmount;
logic ShiftIn;
logic [WIDTH-1:0] Out;

logic [2*WIDTH-1:0] Temp;
logic [WIDTH-1:0] Expected;

bit Clock;

int Ticks;	// elapsed clocks since last testcase applied
int Tock;	// randomized number of clocks to wait between successive inputs		
int Empty;

typedef struct {
  logic Valid;
  logic [WIDTH-1:0] In;
  logic [$clog2(WIDTH)-1:0] ShiftAmount;
  logic ShiftIn;
} TestCase;

TestCase Q[$];
TestCase TC;
int ClockCount;

//  Create and insert a queue entry every clock tick
//  If we've reached the number of clock ticks between successive stimulus
//  then put in the generated data so we can check it when it emerges from pipe

task ApplyTest();
Tock = $urandom_range(MAXCLOCKS);
repeat (Tock)
begin
  @(negedge Clock);
  TC.Valid = 0;
  if (++Ticks >= Tock)		// enough clocks between testcases have elapsed
    begin
    Ticks = 0;
    TC.Valid = 1; 
    TC.In = In;
    TC.ShiftAmount = ShiftAmount;
    TC.ShiftIn = ShiftIn;
    end
  Q.push_front(TC);
end
endtask


// BarrelShifter #(WIDTH, DELAY) BS (Clock, In, ShiftAmount, ShiftIn, Out);
 BarrelShifter  BS (Clock, In, ShiftAmount, ShiftIn, Out);

always @(negedge Clock)
	ClockCount <= ClockCount + 1;

always @(negedge Clock)
begin

if (Empty > 2 * MAXCLOCKS)			// quit if more than 2 * MAXCLOCKS without new data
  $finish();
  
TC = Q.pop_back();
if (TC.Valid === 1)
  begin
  Empty = 0;
  Temp = {TC.In, {WIDTH{TC.ShiftIn}}};
  Expected = Temp[2*WIDTH-1-TC.ShiftAmount -: WIDTH];

  if (Out !== Expected)
    begin
    $display("*** Bad result.   In = %b, ShiftIn = %b, ShiftAmount = %d, Expected = %b, Out = %b",TC.In,TC.ShiftIn,TC.ShiftAmount,Expected,Out);
    Error = 1;
    end
  end
else
  Empty++;
end




initial
begin
Error = 0;
ShiftIn = 0;

// Initialize queue with as many entries as there are stages in pipeline

TC.Valid = 0;
for (int t = 0; t < $clog2(WIDTH); t++)
  begin
  Q.push_front(TC);
  end

forever #(DELAY) Clock = ~Clock;   // make clock period be at least as large as combinational delay
end


initial
begin
int i,j;

@(negedge Clock);
// test input of single one/zero  in every bit position surrounded by complement with every shift amount
repeat(2)
begin
for (i = 0; i < WIDTH; i = i + 1)
  begin
  ShiftAmount = i;
  for (j = 0 ; j < WIDTH; j = j + 1)
    begin
    In = (1 << j);
    ApplyTest();
    In = ~In;
    ApplyTest();
    end
  end

// test checkerboard input with every shift amount
In = {WIDTH/2{2'b10}};
for (i = 0; i < WIDTH; i = i + 1)
  begin
  ShiftAmount = i;
    ApplyTest();
  end

// test checkerboard input with every shift amount
In = {WIDTH/2{2'b01}};
for (i = 0; i < WIDTH; i = i + 1)
  begin
  ShiftAmount = i;
    ApplyTest();
  end

ShiftIn = ~ShiftIn;
end

if (Error)
  $display("*** FAILED ***");
else
  $display("*** PASSED ***");


end
endmodule
