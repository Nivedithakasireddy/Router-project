module router_fsm_tb;
reg clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
	                low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
reg [1:0]data_in;
wire detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy;
reg [1:0] addr;
//instantiation
router_fsm DUT(clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
	                low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,data_in,
			detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state,busy);
initial
	clock = 1'b0;
always
	#10 clock = ~clock;
	
task rst;
 begin
	@(negedge clock)
	resetn = 1'b0;
	@(negedge clock)
	resetn = 1'b1;
 end
endtask

task soft_rst;
 begin
	soft_reset_0 = 1'b0;
	soft_reset_1 = 1'b0;
	soft_reset_2 = 1'b0;
 end
endtask

task case_1;
 begin
	 pkt_valid = 1'b1;
	 data_in[1:0] = 2'b00;
	 fifo_empty_0 = 1'b1;
	 @(negedge clock) // loadd first data
	 @(negedge clock) // unconditionally it will go to load data state
	 pkt_valid = 1'b0;
	 fifo_full = 1'b0;
	 @(negedge clock) // load parity
	 @(negedge clock) // unconditionally it will go to chceck parity error
	 fifo_full = 1'b0; // decode address
 end
endtask

task case_2;
 begin
	 pkt_valid = 1'b1;
	 data_in [1:0] = 2'b01;
	 fifo_empty_1 = 1'b0;
	 @(negedge clock) // wait till empty
	 #10;
	 @(negedge clock) // will remain in same state
	 fifo_empty_1 = 1'b1;
	 addr [1:0] = 2'b01;
	 @(negedge clock) // load first data
	 @(negedge clock) // load data
	 fifo_full = 1'b1;
	 @(negedge clock) // fifo full state
	 fifo_full = 1'b0;
	 @(negedge clock) // load after full
	 parity_done = 1'b0;
	 low_pkt_valid = 1'b1;
	 @(negedge clock) // load parity
	 @(negedge clock) // chech parity error
	 fifo_full = 1'b1;
	 @(negedge clock) // it will go back to fifo full state
	 fifo_full = 1'b0;
	 @(negedge clock) // load after full
	 parity_done = 1'b1; // after load after full it will directly go back to decode address
 end
endtask

task case_3;
 begin
	 pkt_valid = 1'b0;
	 #10;
	 pkt_valid = 1'b1;
	 data_in [1:0] = 2'b10;
	 fifo_empty_2 = 1'b1;
	 @(negedge clock) // load first data
	 @(negedge clock) // load data
	 fifo_full = 1'b1;
	 @(negedge clock)
	 fifo_full = 1'b0; // load after full state
	 @(negedge clock)
	 parity_done = 1'b0;
	 low_pkt_valid = 1'b0;
	 @(negedge clock) // it will go back to load data state
	 fifo_full = 1'b0;
	 pkt_valid = 1'b0;
	 @(negedge clock) // load parity
	 @(negedge clock) // check parity error
	 fifo_full = 1'b0;
 end
endtask

task initialize;
	{clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
	                low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,data_in} = 0;
endtask

initial
 begin
	 initialize;
	 rst;
	 soft_rst;
	 case_1;
	 #10;
	 case_2;
	 #20;
	 case_3;
	 #1000;
	 $finish;
 end
endmodule
