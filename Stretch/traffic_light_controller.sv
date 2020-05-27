// shell for advanced traffic light controller (stretch goal)
// CSE140L   Summer II  2019
// semi-independent operation of east and west straight and left signals
//  see assignment writeup

module traffic_light_controller(
  input clk,
        reset,
		  e_left_sensor,		  // e-bound left turn traffic
		  e_str_sensor,		      // e-bound thru traffic
		  w_left_sensor,		  // w-bound left turn traffic
		  w_str_sensor,           // w-bound thru traffic
		  ns_sensor,              // traffic on n-s street
  output logic[1:0]  e_left_light,      // left arrow e turn onto n
							e_str_light,	      // straight ahead e
							w_left_light,      // left arrow w turn onto s
							w_str_light,       // straight ahead w
							ns_light);	      // n-s (no left/thru differentiation)					  

  logic[3:0] previous_state, present_state, next_state, last_green_state;
  logic[3:0] ctr_10;
  logic[2:0] ctr_5;
  logic[2:0] pri = 0;
					  
  // sequential part of our state machine
  always_ff @(posedge clk)
    if(reset) begin
	  previous_state <= 'b0000;
	  present_state <= 'b0000;

	  ctr_10 = 0;
	  ctr_5 = 0;
	 end
	 
	 
	else begin
	//$display(ctr_10);
	  previous_state = present_state;
	  present_state = next_state;
	  
	  if(previous_state != present_state) begin ctr_10 = 1; 
	  //$display("reset ctr_10"); 
	  end
	  else if (ctr_10 < 10) ctr_10 = ctr_10 + 1;
	  else 				ctr_10 = ctr_10;
	  
	  if(previous_state != present_state) ctr_5 = 2;
	  else if (ctr_5 < 5 && !(e_left_sensor) && !(e_str_sensor) && !(w_left_sensor) && !(w_str_sensor) && !(ns_sensor)) ctr_5 = ctr_5 + 1;
	  else 				ctr_5 = ctr_5;
	
	end
	
	// State table:
	//State | E straight  |  E left arrow | W straight  |  W left arrow | NS (straight)
	// 0000       Red				   Red           Red            Red					Red    (No traffic red)
	// 0001       Green				Red           Green          Red					Red    
	// 0010       Yellow				Red           Yellow         Red					Red    
   // 0011       Red					Green         Red         	  Green				Red  
   // 0100       Red					Yellow        Red            Yellow				Red
   // 0101       Red					Red           Green          Green				Red
   // 0110       Red					Red           Yellow         Yellow				Red  
   // 0111       Green				Green         Red         	  Red					Red  
   // 1000       Yellow				Yellow        Red            Red					Red
   // 1001       Red					Red           Red         	  Red					Green  
   // 1010       Red					Red           Red            Red					Yellow
	// 1011       Red				   Red           Red            Red					Red    (transition red)
	//Priority Cycling: ew_str_sensor -> ew_left_sensor -> ns_sensor -> ew_str_sensor
	  
// combinational part of state machine
  always_comb begin
		case(present_state)
			
			'b0000:  begin
					last_green_state = 4'b0000;
					case(pri)
						0: begin
							if	((e_str_sensor || w_str_sensor) && !(w_left_sensor || e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor) && !(w_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E left and str
								pri = 2;
								end
							else if	((w_left_sensor) && !(e_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W left and str
								pri = 2;
								end
							else if	((w_left_sensor && e_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
								
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
								
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	(!(e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor) && ns_sensor) 
								begin
								next_state = 'b1001;  	// NS
								pri = 0;
								end
							else begin
								next_state = 'b0000;  	// Red
								pri = 0;
								end
						end
						1: begin
						if (!ns_sensor) begin
							if	((e_str_sensor || w_str_sensor) && !(w_left_sensor || e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor) && !(w_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E left and str
								pri = 2;
								end
							else if	((w_left_sensor) && !(e_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W left and str
								pri = 2;
								end
							else if	((w_left_sensor && e_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin 
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else begin
								next_state = 'b0000;  	// Red
								pri = 0;
								end
							end
							else begin //ns_sensor = 1
							
							if	((e_left_sensor) && !(w_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E left and str
								pri = 2;
								end
							else if	((w_left_sensor) && !(e_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W left and str
								pri = 2;
								end
							else if	((w_left_sensor && e_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin 
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else begin
								next_state = 'b1001;  	// NS
								pri = 0;
								end
								
							/*if	((e_left_sensor || w_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin 
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else begin
								next_state = 'b1001;  	// NS
								pri = 0;
								end
							end
							*/
							end
						end
						2: begin
						if (!ns_sensor) begin
							if	((e_str_sensor || w_str_sensor) && !(w_left_sensor || e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor) && !(w_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E left and str
								pri = 2;
								end
							else if	((w_left_sensor) && !(e_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W left and str
								pri = 2;
								end
							else if	((w_left_sensor && e_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
								
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
								
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	(!(e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor) && ns_sensor) 
								begin
								next_state = 'b1001;  	// NS
								pri = 0;
								end
							else begin
								next_state = 'b0000;  	// Red
								pri = 0;
								end
						end
						else begin // ns_sensor == 1
							pri = 0;
							next_state= 'b1001;
						end
						end
						default: begin
							pri = 0;
							next_state= 'b0000;
							
						end
						/*
						else if	(e_left_sensor && w_left_sensor) next_state = 'b0011;  	// EW left
						else if	(w_left_sensor && w_str_sensor) 	next_state = 'b0101;  	// W str and left
						else if	(e_left_sensor && e_str_sensor) 	next_state = 'b0111;  	// E str and left
						else if	(ns_sensor) 							next_state = 'b1001;  	// NS str
						else													next_state = 'b0000;  	// Stay: R
						*/
						endcase
					  end
					  
			'b0001:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state = 4'b0001;
						if((ctr_10 == 10 ) && (e_left_sensor || w_left_sensor || ns_sensor || (!e_str_sensor && !w_str_sensor))) begin
								next_state = 'b0010;
						end
						else if(ctr_5 == 5)    begin
							next_state = 'b0010;
						end
						else	next_state = 'b0001;
					  end
			
			'b0010:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state = 4'b0001;
						if(ctr_10 == 2)        			next_state = 'b1011; // All red after 2 cycles
						else								   next_state = 'b0010;
						end
			
			'b0011:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state <= 4'b0011;
						if((ctr_10 == 10 ) && (e_str_sensor || w_str_sensor || ns_sensor || (!e_left_sensor && !w_left_sensor))) begin
								next_state = 'b0100;
						end
						else if(ctr_5 == 5)    begin
								next_state = 'b0100;
						end
						else								   next_state = 'b0011;
					  end
					  
			'b0100:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state = 4'b0011;
						if(ctr_10 == 2)        			next_state = 'b1011; // All red after 2 cycles
					  else								   next_state = 'b0100;
					  end
			
			'b0101:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state <= 4'b0101;
						if((ctr_10 == 10 ) && (e_str_sensor || e_left_sensor || ns_sensor || (!w_str_sensor && !w_left_sensor))) begin
								next_state = 'b0110;
						end
						else if(ctr_5 == 5)    begin
								next_state = 'b0110;
						end
						else								   next_state = 'b0101;
					  end
					  
			'b0110:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state = 4'b0101;
						if(ctr_10 == 2)        			next_state = 'b1011; // All red after 2 cycles
						else								   next_state = 'b0110;
					  end	
			
			'b0111:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state <= 4'b0111;
						if((ctr_10 == 10 ) && (w_str_sensor || w_left_sensor || ns_sensor|| (!e_str_sensor && !e_left_sensor))) begin
								next_state = 'b1000;
						end
						else if(ctr_5 == 5)    begin
								next_state = 'b1000;
						end
						else								   next_state = 'b0111;
					  end
					  
			'b1000:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state = 4'b0111;
						if(ctr_10 == 2)        			next_state = 'b1011; // All red after 2 cycles
						else								   next_state = 'b1000;
					  end	
					  
			'b1001:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state <= 4'b1001;
						//$display(ctr_5);
						if(ctr_10 == 10 && ((!ns_sensor) || (w_str_sensor || w_left_sensor || e_str_sensor || e_left_sensor))) begin
								next_state = 'b1010;
								//$display("At least display your 10");
						end
						else if(ctr_5 == 5)    begin
								//$display("At least display your 5");
								next_state = 'b1010;
						end
						else								   next_state = 'b1001;
					  end
					  
			'b1010:  begin
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						last_green_state = 4'b1001;
						if(ctr_10 == 2)        			next_state = 'b1011; // All red after 2 cycles
						else								   next_state = 'b1010;
					  end	
			
			'b1011:  begin
					last_green_state = 4'b0000;
					
					case(pri)
						0: begin
							if	((e_str_sensor || w_str_sensor) && !(w_left_sensor || e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor) && !(w_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E left and str
								pri = 2;
								end
							else if	((w_left_sensor) && !(e_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W left and str
								pri = 2;
								end
							else if	((w_left_sensor && e_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
								
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
								
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	(!(e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor) && ns_sensor) 
								begin
								next_state = 'b1001;  	// NS
								pri = 0;
								end
							else begin
								next_state = 'b0000;  	// Red
								pri = 0;
								end
						end
						1: begin
						if (!ns_sensor) begin
							if	((e_str_sensor || w_str_sensor) && !(w_left_sensor || e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor) && !(w_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E left and str
								pri = 2;
								end
							else if	((w_left_sensor) && !(e_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W left and str
								pri = 2;
								end
							else if	((w_left_sensor && e_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin 
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else begin
								next_state = 'b0000;  	// Red
								pri = 0;
								end
							end
							else begin //ns_sensor = 1
							
							if	((e_left_sensor) && !(w_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E left and str
								pri = 2;
								end
							else if	((w_left_sensor) && !(e_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W left and str
								pri = 2;
								end
							else if	((w_left_sensor && e_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin 
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0101;  	// W str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else begin
								next_state = 'b1001;  	// NS
								pri = 0;
								end
								
							/*if	((e_left_sensor || w_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin 
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0111;  	// E str + E Left
								pri = 2;
								end
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else begin
								next_state = 'b1001;  	// NS
								pri = 0;
								end
							end
							*/
							end
						end
						2: begin
						if (!ns_sensor) begin
							if	((e_str_sensor || w_str_sensor) && !(w_left_sensor || e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor) && !(w_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0111;  	// E left and str
								pri = 2;
								end
							else if	((w_left_sensor) && !(e_left_sensor || w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0101;  	// W left and str
								pri = 2;
								end
							else if	((w_left_sensor && e_left_sensor) && !(w_str_sensor || e_str_sensor)) 
								begin
								next_state = 'b0011;  	// EW left
								pri = 2;
								end
							else if	((e_left_sensor && w_str_sensor) && !(w_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_left_sensor && e_str_sensor) && !(e_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_left_sensor && e_str_sensor) && !(w_left_sensor || w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_left_sensor && w_str_sensor) && !(e_left_sensor || e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_str_sensor && w_str_sensor && e_left_sensor) && !(w_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((e_str_sensor && w_str_sensor && w_left_sensor) && !(e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
								
							else if	((e_str_sensor && e_left_sensor && w_left_sensor) && !(w_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	((w_str_sensor && e_left_sensor && w_left_sensor) && !(e_str_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
								
							else if	((e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor)) 
								begin
								next_state = 'b0001;  	// EW straight
								pri = 1;
								end
							else if	(!(e_str_sensor && w_str_sensor && w_left_sensor && e_left_sensor) && ns_sensor) 
								begin
								next_state = 'b1001;  	// NS
								pri = 0;
								end
							else begin
								next_state = 'b0000;  	// Red
								pri = 0;
								end
						end
						else begin // ns_sensor == 1
							pri = 0;
							next_state= 'b1001;
						end
						end
						default: begin
							pri = 0;
							next_state= 'b0000;
							
						end
						/*
						else if	(e_left_sensor && w_left_sensor) next_state = 'b0011;  	// EW left
						else if	(w_left_sensor && w_str_sensor) 	next_state = 'b0101;  	// W str and left
						else if	(e_left_sensor && e_str_sensor) 	next_state = 'b0111;  	// E str and left
						else if	(ns_sensor) 							next_state = 'b1001;  	// NS str
						else													next_state = 'b0000;  	// Stay: R
						*/
						endcase
					  
					 end
			 default: begin next_state = 'b0000; 
						last_green_state = 4'b0000;
						if (pri == 0) pri = 0;
						else if (pri == 1) pri = 1;
						else pri = 2;
						end
			
		endcase
  end

// combination output driver
// green = 10, yellow = 01, red = 00

  
  always_comb begin    // Moore machine
	 e_left_light = 2'b00;  // R|R|R
	 e_str_light = 2'b00;
	 w_left_light = 2'b00; 
	 w_str_light = 2'b00;
	 ns_light = 2'b00;
	 
	 case(present_state)
		4'b0001: begin
			e_str_light = 2'b10; 
			w_str_light = 2'b10; 
		end
		4'b0010: begin
			e_str_light = 2'b01; 
			w_str_light = 2'b01; 
		end
		4'b0011: begin
			e_left_light = 2'b10; 
			w_left_light = 2'b10; 
		end
		4'b0100: begin
			e_left_light = 2'b01; 
			w_left_light = 2'b01; 
		end
		4'b0101: begin
			w_str_light = 2'b10; 
			w_left_light = 2'b10; 
		end
		4'b0110: begin
			w_str_light = 2'b01; 
			w_left_light = 2'b01; 
		end
		4'b0111: begin
			e_str_light = 2'b10; 
			e_left_light = 2'b10; 
		end
		4'b1000: begin
			e_str_light = 2'b01; 
			e_left_light = 2'b01; 
		end
		4'b1001: begin
			ns_light = 2'b10; 
		end
		4'b1010: begin
			ns_light = 2'b01; 
		end
	 endcase
	 
  end


endmodule 