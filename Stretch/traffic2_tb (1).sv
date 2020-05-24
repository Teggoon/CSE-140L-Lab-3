// test bench 2 for Lab 3 stretch with independent left/straight
// CSE140L   Fall 2019
// expanded version -- try the simpler traffic_tb first if
//  you do not pass this one
//
`timescale 1ns/1ns;
module traffic1_tb;

logic clk;
logic reset;				  // should put your design in all-red
logic e_left_sensor,		  // e-bound left turn traffic
	  e_str_sensor,		      // e-bound thru traffic
	  w_left_sensor,		  // w-bound left turn traffic
	  w_str_sensor,           // w-bound thru traffic
	  ns_sensor;              // traffic on n-s street
wire [1:0] e_left_light,      // left arrow e turn onto n
	       e_str_light,	      // straight ahead e
		   w_left_light,      // left arrow w turn onto s
		   w_str_light,       // straight ahead w
	       ns_light;	      // n-s (no left/thru differentiation)
typedef enum logic[1:0] {red,yellow,green} color;

// your controller goes here
// input ports = logics above
// output ports = wires above (each 2 bits wide)
traffic_light_controller dut(.*);

color e_l, e_s, w_l, w_s, ns;
assign e_l = color'(e_left_light);
assign e_s = color'(e_str_light);
assign w_l = color'(w_left_light);
assign w_s = color'(w_str_light);
assign ns  = color'(ns_light);

always begin
  #5ns clk = 1'b0;
  #5ns clk = 1'b1;
// print yellow and green states on transcript
  case(e_l)
	green:   $write("g   ");
	yellow:	 $write("y   ");
	default: $write("    ");
  endcase
  case(e_s)
	green:   $write("g   ");
	yellow:	 $write("y   ");
	default: $write("    ");
  endcase
  case(w_l)
	green:   $write("g   ");
	yellow:	 $write("y   ");
	default: $write("    ");
  endcase
  case(w_s)
	green:   $write("g   ");
	yellow:	 $write("y   ");
	default: $write("    ");
  endcase
  case(ns)
    green:   $display("g   %t",$time);
	yellow:  $display("y   %t",$time);
	default: $display("   %t",$time);
  endcase
  if(e_left_light && (w_str_light || ns_light)) $display("*****error*****");
  if(w_left_light && (e_str_light || ns_light)) $display("*****error*****");
  if(w_str_light && ns_light) 				   $display("*****error*****");
  if(e_str_light && ns_light)                  $display("*****error*****");

/*  case({ew_left_light,ew_str_light,ns_light})
    6'b00_00_00: $display("           %t",$time);
	6'b01_00_00: $display("y          %t",$time);
	6'b10_00_00: $display("g          %t",$time);
	6'b00_01_00: $display("   y       %t",$time);
	6'b00_10_00: $display("   g       %t",$time);
	6'b00_00_01: $display("       y   %t",$time);
	6'b00_00_10: $display("       g   %t",$time);
	default    : $display("***ERROR** %t",$time);
  endcase 	 */
end

logic [3:0] test_cnt;          // lets testbench track tests
initial begin
  $display("e   e   w   w   n");	   // header for y, g status display
  $display("l   s   l   s   s");
  test_cnt       = 4'd0;
  reset          = 1'b1;
  e_left_sensor = 1'b0;
  e_str_sensor  = 1'b0;
  w_left_sensor = 1'b0;
  w_str_sensor  = 1'b0;
  ns_sensor      = 1'b0;
  #20ns reset    = 1'b0;
  #10ns;
// Test E_LEFT to W_STR without more traffic
  test_cnt++                 ;
  e_left_sensor       = 1'b1 ;
  #30ns w_left_sensor = 1'b1 ;
  #60ns e_left_sensor = 1'b0 ;
  #20ns e_str_sensor  = 1'b1 ;
  #30ns w_str_sensor  = 1'b1 ;
  #60ns e_str_sensor  = 1'b0 ;
  #10ns w_str_sensor  = 1'b0;
  #30ns w_left_sensor = 1'b0;
  #200ns;

// Now set traffic at NS. Green NS lasts past sensor falling
  test_cnt++                  ;
  ns_sensor           = 1'b1  ;
  #60ns ns_sensor     = 1'b0  ;
  #200ns;

// Check NS again, but hold for more than 5 cycles.
//   NS should cycle green-yellow-red when side traffic appears
  test_cnt++;
  ns_sensor              = 1'b1;
  #100ns e_left_sensor   = 1'b1;
  #200ns ns_sensor       = 1'b0;
  #20ns  e_left_sensor   = 1'b0;
  #100ns;

// All five sensors become 1 at once.
//  EW_STR should come first, then LEFT, then NS
  test_cnt++;
  e_left_sensor  = 1'b1;
  e_str_sensor   = 1'b1;
  w_left_sensor  = 1'b1;
  w_str_sensor   = 1'b1;
  ns_sensor      = 1'b1;
  #1000ns;
  w_left_sensor  = 1'b0;
  #200ns;
  e_str_sensor   = 1'b0;
  ns_sensor      = 1'b0;
  #40ns;
  w_str_sensor   = 1'b0;
  #20ns;
  e_left_sensor  = 1'b0;
  #200ns;

// All
  test_cnt++;
  $stop;
end

endmodule
