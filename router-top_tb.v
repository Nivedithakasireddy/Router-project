module router_top_tb;
reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
reg [7:0]data_in;
wire valid_out_0,valid_out_1,valid_out_2,error,busy;
wire [7:0]data_out_0,data_out_1,data_out_2;
integer i;

router_top DUT(.clock(clock),.resetn(resetn),.read_enb_0(read_enb_0),.read_enb_1(read_enb_1),.read_enb_2(read_enb_2),.pkt_valid(pkt_valid),.data_in(data_in),
               .valid_out_0(valid_out_0),.valid_out_1(valid_out_1),.valid_out_2(valid_out_2),.error(error),.busy(busy),.data_out_0(data_out_0),.data_out_1(data_out_1),.data_out_2(data_out_2));

initial
 clock = 1'b0;
	always #10 clock = ~clock;

task reset;
 begin
	@(negedge clock)
	resetn = 1'b0;
	@(negedge clock)
	resetn = 1'b1;
 end
endtask

task initialize;
	{clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid} = 0;
endtask

task pkt_0;
 reg [7:0] payload_data,header,parity;
 reg [5:0] payload_len;
 reg [1:0] addr;
 
 begin
	@(negedge clock)
		wait(~busy)
	@(negedge clock)
	 begin
		payload_len = 6'd14;
		addr = 2'b10;
		header = {payload_len,addr};
		data_in = header;
		parity = 8'b0;
		pkt_valid = 1'b1;
		parity = parity ^ header;
	 end
	@(negedge clock)
	 begin
		wait(~busy)
		for(i=0;i<payload_len;i=i+1)
		@(negedge clock)
		 begin
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ data_in;
		 end
	 end
	@(negedge clock)
	 begin
		//wait(~busy)
		pkt_valid = 1'b0;
		data_in = parity;
	 end
 end
endtask

/*task pkt_1;
 reg [7:0] payload_data,header,parity;
 reg [5:0] payload_len;
 reg [1:0] addr;
  begin
	@(negedge clock)
		//wait(~busy)
	@(negedge clock)
	 begin
		payload_len = 6'd8;
		addr = 2'b01;
		header = {payload_len,addr};
		data_in = header;
		parity = 8'b0;
		pkt_valid = 1'b1;
		parity = parity ^ header;
	 end
	@(negedge clock)
	 begin
		//wait(~busy)
		for(i=0;i<payload_len;i=i+1)
		 begin
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ data_in;
		 end
	 end
	@(negedge clock)
	 begin
		//wait(~busy)
		pkt_valid = 1'b0;
		data_in = parity;
	 end
 end
endtask */

/* task pkt_2;
 reg [7:0] payload_data,header,parity;
 reg [5:0] payload_len;
 reg [1:0] addr;
  begin
	@(negedge clock)
		wait(~busy)
	@(negedge clock)
	 begin
		payload_len = 6'd28;
		addr = 2'b01;
		header = {payload_len,addr};
		data_in = header;
		parity = 8'b0;
		pkt_valid = 1'b1;
		parity = parity ^ header;
	 end
	@(negedge clock)
	 begin
		wait(~busy)
		for(i=0;i<payload_len;i=i+1)
		@(negedge clock)
		 begin
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ data_in;
		 end
	 end
	@(negedge clock)
	 begin
		wait(~busy)
		pkt_valid = 1'b0;
		data_in = parity;
	 end
 end
endtask */

initial
 begin
	initialize;
	reset;
	//repeat(3)
	@(negedge clock)
	//pkt_0;
	//#10;
	//pkt_1;
	//#50;
	pkt_2;
	/*@(negedge clock)
	//begin
	 read_enb_1 = 1'b1;
	 //read_enb_2 = 1'b1;
	 //wait(~valid_out_2)
	 wait(~valid_out_1)
	//end
	//@(negedge clock)
	//read_enb_2 = 1'b0;
	read_enb_1 = 1'b0; */
 end
 
initial
 begin
	repeat(25)
	@(negedge clock)
	read_enb_1 = 1'b1;
	@(negedge clock)
	read_enb_1 = 1'b0;
 end 
endmodule 
