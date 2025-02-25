module router_fifo_tb;
reg clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
reg [7:0]data_in;
wire [7:0]data_out;
wire full,empty;
integer m;

//instantiation
router_fifo DUT(clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,data_out,full,empty);

//clock generation
initial
	clock=1'b0;
always
	#5 clock=~clock;

//initialize
task initialize;
	{clock,resetn,soft_reset,write_enb,read_enb,data_in,lfd_state}=0;
endtask

//active low synchronous reset
task rst;
 begin
	@(negedge clock)
	resetn = 1'b0;
	@(negedge clock)
	resetn = 1'b1;
 end
endtask

//soft reset
task sft_rst;
 begin
	@(negedge clock)
	soft_reset = 1'b1;
	@(negedge clock)
	soft_reset = 1'b0;
 end
endtask

task write;
reg [7:0]payload,header,parity;
reg [5:0]payload_length;
reg [1:0]address;

begin
	@(negedge clock)
		payload_length=6'd4;
		address=2'b01;
		header={payload_length,address};
		data_in=header;
		lfd_state=1'b1;
		write_enb=1'b1;
		for(m=0;m<payload_length;m=m+1)
		begin
			@(negedge clock)
				lfd_state=1'b0;
				payload={$random}%256;
				data_in=payload;
		end
	@(negedge clock)
		parity={$random}%256;
		data_in=parity;
end
endtask

task read;
	@(negedge clock)
	begin
		read_enb=1'b1;
		write_enb=1'b0;
	end
endtask

initial
 begin
	initialize;
	rst;
	sft_rst;
	write;
	#20;
	read;
   #1000 $finish;
 end
endmodule
