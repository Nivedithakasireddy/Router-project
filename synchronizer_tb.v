module router_sync_tb;
reg clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;
reg full_0,full_1,full_2;
reg empty_0,empty_1,empty_2;
reg [1:0] data_in;
wire fifo_full;
wire vld_out_0,vld_out_1,vld_out_2;
wire soft_reset_0,soft_reset_1,soft_reset_2;
wire [2:0]write_enb;

router_sync DUT(clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2,data_in,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,write_enb);

// clock instatntiation
initial
begin
 clock = 1'b0;
	forever #10 clock = ~clock;
end

task reset;
 begin
	@(negedge clock)
	resetn = 1'b0;
	@(negedge clock)
	resetn = 1'b1;
 end
endtask
 
task initialize;
  {clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,full_0,full_1,full_2,empty_0,empty_1,empty_2,data_in} = 0;
endtask

task detect_addr;
 begin
	@(negedge clock)
	detect_add = 1'b1;
	data_in = 2'b10;
	#20;
	@(negedge clock)
	detect_add = 1'b0;
 end
endtask

task write_enable;
 begin
	write_enb_reg = 1'b1;
	#10; write_enb_reg = 1'b0;
 end
endtask

task full;
 begin
	full_0 = 1'b0;
	full_1 = 1'b1;
	full_2 = 1'b1;
 end
endtask

task empty;
 begin
	empty_0 = 1'b1;
	empty_1 = 1'b0;
	empty_2 = 1'b0;
 end
endtask

task read_enable;
 begin
	read_enb_0 = 1'b1;
	read_enb_1 = 1'b0;
	read_enb_2 = 1'b1;
 end
endtask

initial
 begin
	initialize;
	reset;
	detect_addr;
	write_enable;
	full;
	empty;
	#20;
	read_enable;
	#1000 $finish;
 end
endmodule 
