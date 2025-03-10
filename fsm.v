module router_fsm(input clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
	                low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,
		  input [1:0] data_in,
		  output detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy);
reg [2:0] present_state,next_state;
reg [1:0] addr;
parameter decode_address  = 3'b000,
	  load_first_data = 3'b001,
	  wait_till_empty = 3'b010,
	  load_data       = 3'b011,
	  load_parity     = 3'b100,
	  fifo_full_state = 3'b101,
	  load_after_full = 3'b110,
	  check_parity_error = 3'b111;

always@(posedge clock)
 begin
	 if(!resetn)
		 addr <= 2'b0;
	 else
		 addr <= data_in;
 end

// present state
// present state should be written as sequential(non blocking statements)
always@(posedge clock)
 begin
	 if(!resetn)
		 present_state <= 3'b0;
	 else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
		 present_state <= 3'b0;
	 else
		 present_state <= next_state;
 end

// next state
// next state should be written as combinational(blocking statements)
always@(*)
 begin
	 next_state = decode_address;
	 case(present_state)
		 decode_address : begin
									if ( (pkt_valid && (data_in [1:0] == 0) && fifo_empty_0) || 
			                       (pkt_valid && (data_in [1:0] == 1) && fifo_empty_1) ||
			                       (pkt_valid && (data_in [1:0] == 2) && fifo_empty_2 ) )
				      
												next_state = load_first_data;

									else if ((pkt_valid && (data_in [1:0] == 0) && !fifo_empty_0)|| 
					                 (pkt_valid && (data_in [1:0] == 1) && !fifo_empty_1) ||
			                       (pkt_valid && (data_in [1:0] == 2) && !fifo_empty_2) )

												next_state = wait_till_empty;

									else
												next_state = decode_address;
								end

		wait_till_empty : begin
				              if ((fifo_empty_0 && (addr == 2'b00)) ||
			                    (fifo_empty_1 && (addr == 2'b01)) ||
                             (fifo_empty_2 && (addr == 2'b10)))
				                   next_state = load_first_data;
			                 else
					                next_state = wait_till_empty;
								end

		load_data       : 
									if (!fifo_full && !pkt_valid)
										next_state = load_parity;
									else if(fifo_full)
										next_state = fifo_full_state;
									else
										next_state = load_data;

		fifo_full_state : if (!fifo_full)
		                     next_state = load_after_full;
				           else
					            next_state = fifo_full_state;
		load_after_full : if (!parity_done && low_pkt_valid)
		                     next_state = load_parity;
				            else if (!parity_done && !low_pkt_valid)
					            next_state = load_data;
				            else if (parity_done)
					            next_state = decode_address;
				            else
					            next_state = next_state;
		check_parity_error : if (fifo_full)
		                          next_state = fifo_full_state;
				               else if (!fifo_full)
					                 next_state = decode_address;
				               else
					                 next_state = next_state;
		load_first_data : next_state = load_data;
		load_parity : next_state = check_parity_error;
		
	endcase
 end

// output
assign busy = ((present_state == load_first_data) || (present_state == fifo_full_state) || (present_state == load_after_full) || (present_state == load_parity) || (present_state == check_parity_error) || (present_state == wait_till_empty)) ? 1'b1:1'b0;
assign detect_add = (present_state == decode_address) ? 1'b1:1'b0;
assign ld_state = (present_state == load_data) ? 1'b1:1'b0;
assign laf_state = (present_state == load_after_full) ? 1'b1:1'b0;
assign full_state = (present_state == fifo_full_state) ? 1'b1:1'b0;
assign write_enb_reg = ((present_state == load_data) || (present_state == load_parity) || (present_state == load_after_full)) ? 1'b1:1'b0;
assign rst_int_reg = (present_state == wait_till_empty) ? 1'b1:1'b0;
assign lfd_state = (present_state == load_first_data) ? 1'b1:1'b0;

endmodule
