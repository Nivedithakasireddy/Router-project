//synchronizer acts as mediator between fifo and fsm
//it also generates write enable signals for respective fifo's based on the address bits
 
module router_sync(input clock,resetn,
	           input detect_add,write_enb_reg,
		   input read_enb_0,read_enb_1,read_enb_2,
		   input full_0,full_1,full_2,
		   input empty_0,empty_1,empty_2,
		   input [1:0] data_in,
	           output reg fifo_full,
	           output vld_out_0,vld_out_1,vld_out_2,
		   output reg soft_reset_0,soft_reset_1,soft_reset_2,
		   output reg [2:0]write_enb);	           
	           
// internal registers
reg [1:0]tempd;
reg [4:0]count_0,count_1,count_2;
wire [4:0]w1,w2,w3;

// assign for valid out
// valid out signal is used to indicate the destination that the fifo is not
// empty and it is havin/holding some data and the destination network can
// come and read the data
assign vld_out_0 = ~empty_0;
assign vld_out_1 = ~empty_1;
assign vld_out_2 = ~empty_2;

// assigning count using wires
// count is used for counting 30 clock cycles after valid out becomes high
assign w1 = (count_0 == 5'd29)? 5'b1 : 5'b0;
assign w2 = (count_1 == 5'd29)? 5'b1 : 5'b0;
assign w3 = (count_2 == 5'd29)? 5'b1 : 5'b0;

// tempd is used to cpature the header
always@(posedge clock)
 begin
	 if(!resetn)
		 tempd<=2'b11;
	 else if(detect_add)
		 tempd<=data_in;
	 else
		 tempd<=tempd;
 end

// fifo full is designing using a combinational logic
// we wll be using case for fifo full
always@(*)
 begin
	 case(tempd)
		 2'b00:fifo_full = full_0;
		 2'b01:fifo_full = full_1;
		 2'b10:fifo_full = full_2;
		 //2'b11:fifo_full = 2'b00;
		 default fifo_full=1'b0;
	 endcase
 end

// write enable is 3 bit wide[this will be given as input for 3 fifo's]
// we will be designing this using combinational logic with help of case
always@(*)
 begin
	 if(!resetn)
		 write_enb = 3'b000;
	 else if(write_enb_reg)
	  begin
	    case(tempd)
			2'b00:write_enb = 3'b001; // one hot encoding
			2'b01:write_enb = 3'b010;
			2'b10:write_enb = 3'b100;
			//2'b11:write_enb = 3'b000;
			default write_enb = 3'b000;
		  endcase
	  end
	 else
		 write_enb = 3'b0; // write_enb;
 end

// counter for generating soft reset
// counter_0
always@(posedge clock)
 begin
	 if(!resetn)
		 count_0<=5'h1;
	 else if(!vld_out_0)
		 count_0<=5'h1;
	 else if(read_enb_0)
		 count_0<=5'h1;
	 else if(w1)
		 count_0<=5'h1;
	 else
		 count_0 <= count_0+5'h1;
 end

//counter_1
always@(posedge clock)
 begin
	 if(!resetn)
		 count_1<=5'h1;
	 else if(!vld_out_1)
		 count_1<=5'h1;
	 else if(read_enb_1)
		 count_1<=5'h1;
	 else if(w2)
		 count_1<=5'h1;
	 else
		 count_1 <= count_1+5'h1;
 end

//counter_2 
always@(posedge clock)
 begin
	 if(!resetn)
		 count_2<=5'h1;
	 else if(!vld_out_2)
		 count_2<=5'h1;
	 else if(read_enb_2)
		 count_2<=5'h1;
	 else if(w3)
		 count_2<=5'h1;
	 else
		 count_2 <= count_2+5'h1;
 end

// if read enable is not becoming high for thirty clock cycles soft reset will be generated
// soft reset 0
always@(posedge clock)
 begin
	 if(!resetn)
		 soft_reset_0 <= 1'b0;
	 else if(!vld_out_0)
		 soft_reset_0 <= 1'b0;
	 else if(read_enb_0)
		 soft_reset_0 <= 1'b0;
	 else if(w1)
		 soft_reset_0 <= 1'b1;
	 else
		 soft_reset_0 <= soft_reset_0;
 end

// soft reset 1
always@(posedge clock)
 begin
	 if(!resetn)
		 soft_reset_1 <= 1'b0;
	 else if(!vld_out_1)
		 soft_reset_1 <= 1'b0;
	 else if(read_enb_1)
		 soft_reset_1 <= 1'b0;
	 else	if(w2)
		 soft_reset_1 <= 1'b1;
	  else
		 soft_reset_1 <= soft_reset_1;
 end

// soft reset 2
always@(posedge clock)
 begin
	 if(!resetn)
		 soft_reset_2 <= 1'b0;
	 else if(!vld_out_2)
		 soft_reset_2 <= 1'b0;
	 else if(read_enb_2)
		 soft_reset_2 <= 1'b0;
	 else	if(w3)
		 soft_reset_2 <= 1'b1;
	 else
		 soft_reset_2 <= soft_reset_2;
 end
endmodule 
