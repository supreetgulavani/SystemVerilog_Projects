typedef enum {ALL_RED_to_L1_GREEN, L1_GREEN, L1_GREEN_WAIT, L1_YELLOW_BEGIN, L1_YELLOW, ALL_RED_to_L23_GREEN, L23_GREEN, L23_GREEN_WAIT, L23_YELLOW_BEGIN, L23_YELLOW, FAILSAFE} st;

module fsmassertions(Clock, Reset, S1, S2, S3, L1, L2, L3);
input Clock;
input Reset;
input S1, S2, S3;
input [1:0] L1, L2, L3;
  
logic load, decr;
logic [7:0] value;
logic timeup;
	
reg [3:0] st, Nextst;


//sensor value check
property checkS1;
	@(negedge Clock) 
  	$rose($isunknown(S1)) == 0; 
endproperty : checkS1
assert_checkS1: assert property (checkS1) $display("checkS1 works");
else $error("Unknown S1"); 

  
property checkS2;
	@(negedge Clock) 
  	$rose($isunknown(S2)) == 0; 
endproperty : checkS2
assert_checkS2: assert property (checkS2) $display("checkS2 works");
else $error("Unknown S2");
  
property checkS3;
	@(negedge Clock) 
  	$rose($isunknown(S3)) == 0; 
endproperty : checkS3
assert_checkS3: assert property (checkS3) $display("checkS3 works");
 else $error("Unknown S3");


//L2 L3 always same check
property check_L2_L3;
  	@(negedge Clock) 
  	(L2===L3);
endproperty : check_L2_L3
assert_checkL2L3: assert property(check_L2_L3) $display("L2, L3 same");
else $error("L2 not equal to L3: ACCIDENT ALERT!");
     
        
//if traffic light green, cross traffic red check
property GreenCrossRed;
	not ((st == L1_GREEN && (L1 == 2'b01 && (L2==2'b11 && L3==2'b11))) || (st == L23_GREEN && (L1 == 2'b11 && (L2==2'b01 && L3==2'b01))));
endproperty : GreenCrossRed
assert_checkCTGR: assert property (@ (negedge Clock) GreenCrossRed) $display("Traffic Light Green, Cross Traffic Red");
else $error("Cross traffic light (Green/Red) Violation");
          
//if traffic light yellow, cross traffic red check
property YellowCrossRed;
	 not ((st == L1_YELLOW && (L1 == 2'b10 && (L2==2'b11 && L3==2'b11))) || (st == L23_YELLOW && (L1 == 2'b11 && (L2==2'b10 && L3==2'b10))));
endproperty : YellowCrossRed
assert_checkCTYR: assert property (@ (negedge Clock) YellowCrossRed) $display("Traffic Light Yellow, Cross Traffic Red");
else $error("Cross traffic light (Yellow/Red) Violation");
  
      
//never green to red check
property L1never_green_red;
	@(negedge Clock) 
	L1 == 2'b01 ##1  L1 != 2'b01 |-> L1 !=2'b11;
endproperty : L1never_green_red
assert_check_L1never_green_red: assert property (L1never_green_red) $display("L1 does not go from green to red");
else $error("L1 Transition Violation: Green to Red");
          
property L2never_green_red;
	@(negedge Clock) 
	L2 == 2'b01 ##1  L2 != 2'b01 |-> L2 !=2'b11;
endproperty : L2never_green_red
assert_check_L2never_green_red: assert property(L2never_green_red) $display("L2 does not go from green to red");
else $error("L2 Transition Violation: Green to Red");
          
property L3never_green_red;
	@(negedge Clock) 
	L3 == 2'b01 ##1  L3 != 2'b01 |-> L3 !=2'b11;
endproperty : L3never_green_red
assert_check_L3never_green_red: assert property(L3never_green_red) $display("L3 does not go from green to red");
else $error("L3 Transition Violation: Green to Red");
          

//never red to yellow check
property L1never_red_yellow;
	@(negedge Clock) 
	L1 == 2'b11 ##1  L1 != 2'b11 |-> L1 !=2'b10;
endproperty : L1never_red_yellow
assert_check_L1never_red_yellow: assert property(L1never_red_yellow) $display("L1 does not go from red to yellow");
else $error("L1 Transition Violation: Red to Yellow");
          
property L2never_red_yellow;
	@(negedge Clock) 
	L2 == 2'b11 ##1  L2 != 2'b11 |-> L2 !=2'b10;
endproperty
assert_check_L2never_red_yellow: assert property(L2never_red_yellow) $display("L2 does not go from red to yellow");
else $error("L2 Transition Violation: Red to Yellow");
          
property L3never_red_yellow;
	@(negedge Clock) 
	L3 == 2'b11 ##1  L3 != 2'b11 |-> L3 !=2'b10;
endproperty
assert_check_L3never_red_yellow: assert property(L3never_red_yellow) $display("L3 does not go from red to yellow");
else $error("L3 Transition Violation: Red to Yellow");
          

 //never yellow to green
property L1never_yellow_green;
	@(negedge Clock) 
        L1 == 2'b10 ##1  L1 != 2'b10 |-> L1 !=2'b01;
endproperty
assert property(L1never_yellow_green) $display("L1 does not go from yellow to green");
else $error("L1 Transition Violation: Yellow to Green");
          
property L2never_yellow_green;
	@(negedge Clock) 
         L2 == 2'b10 ##1  L2 != 2'b10 |-> L2 !=2'b01;
endproperty
assert property(L2never_yellow_green) $display("L2 does not go from yellow to green");
else $error("L2 Transition Violation: Yellow to Green");
          
property L3never_yellow_green;
	@(negedge Clock) 
         L3 == 2'b10 ##1  L3 != 2'b10 |-> L3 !=2'b01;
endproperty
assert property(L3never_yellow_green) $display("L3 does not go from yellow to green");
else $error("L3 Transition Violation: Yellow to Green");
          
//harrison green 15 seconds
property HGreenFor15sec;
	@(negedge Clock)
	L2 == 2'b01 ##15 L2 != 2'b01 |-> L2 != 2'b01;
endproperty : HGreenFor15sec
assert property (HGreenFor15sec) $display("Harrison Green for 15 seconds");
else $error("Timing Violation: Harrison Green != 15 seconds");
                
   
//harrison yellow 5 seconds
property HYellowFor5sec;
	@(negedge Clock) 
	L2 == 2'b10 ##5 L2 != 2'b10 |-> L2 != 2'b10;
endproperty : HYellowFor5sec
assert property (HYellowFor5sec) $display("Harrison Yellow for 5 seconds");
else $error("Timing Violation: Harrison Yellow != 5 seconds");
  

//4th avenue yellow 5 seconds
property FourthAveYellowFor5sec;
	@(negedge Clock) 
	L1 == 2'b10 ##5 L1 != 2'b10 |-> L1 != 2'b10; 
endproperty : FourthAveYellowFor5sec
assert property (FourthAveYellowFor5sec) $display("Fourth Ave Yellow for 5 seconds");
else $error("Timing Violation: 4th Avenue Yellow != 5 seconds");

//harrison red 51 seconds
property HRedFor51sec;
	@(negedge Clock) 
	L2 != 2'b01 ##15 L2 != 2'b10 ##5 L2 != 2'b11 ##1 L2 == 2'b11 |-> L2 == 2'b11;
endproperty : HRedFor51sec
assert property (HRedFor51sec) $display("Harrison red for 51 seconds");
else $error("Timing Violation: Harrison Red != 51 seconds");

//4th avenue green 45 seconds
property FourthAveGreenFor45sec;
	@(negedge Clock) 
	L2 == 2'b11 ##15  L2 == 2'b11 ##5 L2 == 2'b11 ##1 L2 == 2'b11 |-> L2 == 2'b11; 
endproperty : FourthAveGreenFor45sec
assert property (FourthAveGreenFor45sec) $display("Fourth Ave Green for 45 seconds");
else $error("Timing Violation: 4th Avenue Green != 45 seconds");

//4th avenue red 21 seconds
property FourthAveRedFor21sec;
	@(negedge Clock) 
	L1 != 2'b01 ##15 L1 != 2'b10 ##5 L1 != 2'b11 ##1 L1 == 2'b11 |-> L1 == 2'b11;
endproperty : FourthAveRedFor21sec
assert property (FourthAveRedFor21sec) $display("Fourth Ave Red for 21 seconds");
else $error("Timing Violation: 4th Avenue Red != 21 seconds");

bind fsmassertions fsm y1(.*);
  
endmodule


module top;

reg Clock;
reg Reset;
reg S1, S2, S3;
wire [1:0] L1, L2, L3;

fsm  f0(.*);
fsmassertions fa(.*);
initial
begin
Clock = 1;
forever #(5) Clock = ~Clock;
end

initial begin
Reset = 1;
repeat (5000) @(negedge Clock) begin
Reset = 0;
	S1 = $random();
	S2 = $random();
	S3 = $random();
end
$finish();
end

endmodule