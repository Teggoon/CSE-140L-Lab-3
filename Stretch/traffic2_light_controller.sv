// shell for advanced traffic light controller (stretch goal)
// CSE140L   Summer II  2019
// semi-independent operation of east and west straight and left signals
//  see assignment writeup

module traffic_light_controller(
  input clk,
        reset,
        ew_left_sensor,
        ew_str_sensor,		
        ns_sensor,
  output logic[1:0] ew_left_light,     
  		            ew_str_light,	   	
			        ns_light);					  

  logic[2:0] previous_state, present_state, next_state, last_green_state;
  logic[3:0] ctr_10;
  logic[2:0] ctr_5;
					  
  // sequential part of our state machine
  always_ff @(posedge clk)
    if(reset) begin
	  previous_state <= 'b000;
	  present_state <= 'b000;

	  ctr_10 = 0;
	  ctr_5 = 0;
	 end
	 
	else begin
	  previous_state = present_state;
	  present_state = next_state;
	  
	  if(previous_state != present_state) ctr_10 = 1;
	  else if (ctr_10 < 10) ctr_10 = ctr_10 + 1;
	  else 				ctr_10 = ctr_10;
	  
	  if(previous_state != present_state) ctr_5 = 0;
	  else if (ctr_5 < 5 && !(ew_left_sensor) && !(ew_str_sensor) && !(ns_sensor)) ctr_5 = ctr_5 + 1;
	  else 				ctr_5 = ctr_5;
	
	end
	
	// State table:
	//State | EW straight  |  EW left arrow | NS (straight or unprotected left)
	// 000        Red				   Red                       Red				(No traffic red)
	// 001        Green           Red                       Red
	// 010 		  Yellow			   Red							  Red
	// 011 		  Red				   Green							  Red
	// 100 		  Red             Yellow						  Red
	// 101 		  Red					Red							  Green
	// 110		  Red					Red							  Yellow
	// 111		  Red					Red							  Red				(Transition red)
	
	//Priority Cycling: ew_str_sensor -> ew_left_sensor -> ns_sensor -> ew_str_sensor
	  
// combinational part of state machine
  always_comb begin
		case(present_state)
			
			'b000:  begin
						last_green_state = 3'b000;
						if(ew_left_sensor)        next_state = 'b011;  //EW Left -- G
						else if(ew_str_sensor)    next_state = 'b001;	 //EW Straight -- G
						else if(ns_sensor)					next_state = 'b101;  //NS -- G
						else								   next_state = 'b000;  //Stay -- R
					  end
					  
			'b001:  begin
						last_green_state = 3'b001;
						if((ctr_10 == 10 || !(ew_str_sensor)) && (ew_left_sensor || ns_sensor)) begin
								next_state = 'b010;
						end
						else if(ctr_5 == 5)    begin
							next_state = 'b010;
						end
						else								   next_state = 'b001;
					  end
			
			'b010:  begin
						last_green_state = 3'b001;
						if(ctr_10 == 2)        			next_state = 'b111; // All red after 2 cycles
						else								   next_state = 'b010;
						end
			
			'b011:  begin
						last_green_state <= 3'b011;
						if((ctr_10 == 10 || !(ew_left_sensor)) && (ew_str_sensor || ns_sensor)) begin
								next_state = 'b100;
						end
						else if(ctr_5 == 5)    begin
								next_state = 'b100;
						end
						else								   next_state = 'b011;
					  end
					  
			'b100:  begin
						last_green_state = 3'b011;
						if(ctr_10 == 2)        			next_state = 'b111; // All red after 2 cycles
					  else								   next_state = 'b100;
					  end
			
			'b101:  begin
						last_green_state <= 3'b101;
						if((ctr_10 == 10 || !(ns_sensor)) && (ew_str_sensor || ew_left_sensor)) begin
								next_state = 'b110;
						end
						else if(ctr_5 == 5)    begin
								next_state = 'b110;
						end
						else								   next_state = 'b101;
					  end
					  
			'b110:  begin
						last_green_state = 3'b101;
						if(ctr_10 == 2)        			next_state = 'b111; // All red after 2 cycles
						else								   next_state = 'b110;
					  end	
			
			'b111:  begin
						//------------------- Priority -----------------------------
					   if(last_green_state == 'b001 && ew_left_sensor) begin
							next_state = 'b011; //EW Left -- G
							last_green_state = 3'b001;
					   end
					  
					   else if(last_green_state == 'b011  && ns_sensor) begin
							next_state = 'b101; //NS -- G
							last_green_state = 3'b011;
					   end
					  
					   else if(last_green_state == 'b101 && ew_str_sensor) begin
							next_state = 'b001;	//EW Straight -- G
							last_green_state = 3'b101;
					   end
					
					// --------------------- Non-priority -------------------------  
					  
					   else if(last_green_state == 'b001 && ns_sensor) begin
							next_state = 'b101;  //NS -- G
							last_green_state = 3'b001;
					   end
					  
					   else if(last_green_state == 'b011  && ew_str_sensor) begin
							next_state = 'b001;  //EW Straight -- G
							last_green_state = 3'b011;
					   end
					  
					   else if(last_green_state == 'b101 && ew_left_sensor) begin
							next_state = 'b011;	//EW Left -- G
							last_green_state = 3'b101;
					   end
					  
					   else begin
							next_state = 'b000;
						   last_green_state = 3'b000;
						end
					  
					  end
		endcase
  end

// combination output driver
// green = 10, yellow = 01, red = 00

// State table:
	//State | EW straight  |  EW left arrow | NS (straight or unprotected left)
	// 000        Red				   Red                       Red				(No traffic red)
	// 001        Green           Red                       Red
	// 010 		  Yellow			   Red							  Red
	// 011 		  Red				   Green							  Red
	// 100 		  Red             Yellow						  Red
	// 101 		  Red					Red							  Green
	// 110		  Red					Red							  Yellow
	// 111		  Red					Red							  Red				(Transition red)
  
  always_comb begin    // Moore machine
	 ew_left_light = 2'b00;  // R|R|R
	 ew_str_light = 2'b00;
	 ns_light = 2'b00;
	 
	 case(present_state)
		3'b001: ew_str_light = 2'b10;   // G|R|R
		3'b010: ew_str_light = 2'b01;   // Y|R|R
		3'b011: ew_left_light = 2'b10;  // R|G|R
		3'b100: ew_left_light = 2'b01;  // R|Y|R
		3'b101: ns_light = 2'b10; 		  // R|R|G
		3'b110: ns_light = 2'b01; 		  // R|R|Y
	 endcase
	 
  end


endmodule 