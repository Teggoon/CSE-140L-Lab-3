// test bench 1 for Lab 3
// CSE140L   Fall 2019
module traffic_tb;

logic clk = 1'b0;
logic reset = 1'b1;
logic ew_left_sensor,		  // left traffic on e-w street
	  ew_str_sensor,		  // thru traffic on e-w street
	  ns_sensor;              // traffic on n-s street
wire [1:0] ew_left_light,     // left arrow
	       ew_str_light,	  // straight ahead e-w
	       ns_light;
typedef enum logic[1:0] {red,yellow,green} color;

// your controller goes here
// input ports = logics above (traffic sensors)
// output ports = wires above (each 2 bits wide)
traffic_light_controller dut(.*);

color ew_l, ew_s, ns;			       // type enum
assign ew_l = color'(ew_left_light);   // cast binary as enum
assign ew_s = color'(ew_str_light);
assign ns   = color'(ns_light);

always begin				  // digital clock for our state machine
  #5ns clk = 1'b1;
  #5ns clk = 1'b0;
// print yellow and green states on transcript
  case({ew_left_light,ew_str_light,ns_light})
    6'b00_00_00: $display("           %t",$time);
	6'b01_00_00: $display("y          %t",$time);
	6'b10_00_00: $display("g          %t",$time);
	6'b00_01_00: $display("   y       %t",$time);
	6'b00_10_00: $display("   g       %t",$time);
	6'b00_00_01: $display("       y   %t",$time);
	6'b00_00_10: $display("       g   %t",$time);
	default    : $display("***ERROR** %t",$time);
  endcase 
end

logic [3:0] test_cnt = 4'b0;
initial begin
  $display("e   e   n");	   // header for y, g status display
  $display("w   w   s");
  $display("l   s    ");
  ew_left_sensor = 1'b0;
  ew_str_sensor  = 1'b0;
  ns_sensor      = 1'b0;
  #20ns reset    = 1'b0;
  #10ns;

// Test EW_LEFT to red without more traffic
// Should go green for 8 clock cycles, then yellow for 2, then red.
  test_cnt++;
  ew_left_sensor = 1'b1;
  #30ns ew_left_sensor = 1'b0;
  #200ns;

// Now see traffic at NS. Should go to NS green for 9 cycles
  test_cnt++;
  ns_sensor = 1'b1;
  #40ns ns_sensor = 1'b0;
  #200ns;

// Check NS again, but hold as EW_STR is detected.  
// NS should time out at 10, then yellow for 2, all red, then EW_STR green
  test_cnt++;
  ns_sensor = 1'b1;
  #20ns ew_str_sensor = 1'b1;
  #150ns ns_sensor = 1'b0;
  #150ns ew_str_sensor = 1'b0;
  #200ns;

// All three sensors become 1 at once.  
// EW_STR should come first, then EW_LEFT, then NS
  test_cnt++;
  ew_left_sensor = 1'b1;
  ew_str_sensor = 1'b1;
  ns_sensor = 1'b1;
  #1000ns;
  ew_left_sensor = 1'b0;
  ew_str_sensor = 1'b0;
  ns_sensor = 1'b0;
  #200ns;

// All
  test_cnt++;// = test_cnt++ 4'd1;
  $stop;
end

endmodule
