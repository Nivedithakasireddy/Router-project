module router_reg_tb;
reg clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add;
reg ld_state,laf_state,full_state,lfd_state;
reg [7:0] data_in;
wire parity_done,err,low_pkt_valid;
wire[7:0]dout;
integer i;

router_reg DUT(clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,
                  ld_state,laf_state,full_state,lfd_state,data_in,
						parity_done,err,low_pkt_valid,dout);

initial
 clock = 1'b0;
always
 #10 clock = ~clock;

task initialize;
	{clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,data_in}=0;
endtask

task reset;
 begin
	@(negedge clock)
	resetn = 1'b0;
	@(negedge clock)
	resetn = 1'b1;
 end
endtask

task pkt;
 
 reg [7:0] payload_data,parity,header;
 reg [5:0] payload_length;
 reg [1:0] addr;
 
 begin
	@(negedge clock)
	 begin
		payload_length = 6'd18;
		addr = 2'b01;
		header = {payload_length,addr};
		lfd_state = 1'b1;
		pkt_valid = 1'b1;
		detect_add = 1'b1;
		//rst_int_reg = 1'b1;
		data_in = header;
		//parity = 8'b0;
		parity = 8'b00 ^ header;
	 end
	@(negedge clock)
	 begin
	   //lfd_state = 1'b1;
		detect_add = 1'b0;
		//full_state = 1'b0;
		//fifo_full = 1'b0;
		//laf_state = 1'b0;
		for(i=0;i<payload_length;i=i+1)
		begin
			@(negedge clock)
			lfd_state = 1'b0;
			ld_state = 1'b1;
			pkt_valid = 1'b1;
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ data_in;
		end
	 end
	@(negedge clock)
	 begin
		pkt_valid = 1'b0;
		//ld_state = 1'b1;
		data_in = parity;
	@(negedge clock)
		ld_state = 1'b0;
	 end
 end
endtask

initial
 begin
	initialize;
	reset;
	pkt;
	#1000;
	$finish;
 end
endmodule 
