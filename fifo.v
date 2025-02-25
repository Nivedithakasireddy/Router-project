module router_fifo(clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,data_out,full,empty);
input clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
input [7:0] data_in;
output reg [7:0]data_out;
output full,empty;
reg [8:0]mem[15:0];
reg temp;
reg [4:0]write_ptr,read_ptr;;
reg [5:0]count;
//reg count_zero = (count==0)?1'b1:1'b0;
integer i;

//lfd state is stored in temp as it comes first where as data in will be delayed by one clock cycle
//lfd is high for header byte and zero for payload
always@(posedge clock)
 begin
         if(!resetn)
                 temp <= 1'b0;
         else
                 temp <= lfd_state;
 end

// write pointer
always@(posedge clock)
 begin
        if(!resetn)
      begin
                        write_ptr<=5'b0;
                        for(i=0;i<16;i=i+1)
                                mem[i]<=9'b0;
                end
        else if(soft_reset)
         begin
                write_ptr<=5'b0;
      for(i=0;i<16;i=i+1)
                        mem[i]<=9'b0;
         end
   else if(write_enb && !full)
    begin
                {mem[write_ptr[3:0]][8],mem[write_ptr[3:0]][7:0]} <= {temp,data_in};
                write_ptr <= write_ptr+1'b1;
         end
        else
                write_ptr <= write_ptr;
 end

// data out & read pointer logic
// data out should be high when out data is completely read(when count is zero) and when soft reset is applied
always@(posedge clock)
 begin
         if(!resetn)
          begin
                  read_ptr <= 5'b0;
                  data_out <= 8'b0;
          end
         else if(soft_reset)
          begin
                  data_out <= 8'bz;
                  read_ptr <= 5'b0;
          end
         else if(read_enb && !empty)
          begin
                  data_out <= mem[read_ptr[3:0]][7:0];
                  read_ptr <= read_ptr+1'b1;
          end
         else if (count == 0 && data_out != 8'b0)
                 data_out <= 8'bz;
         else
                 data_out <= data_out;
 end

//count logic
//we are using counter to indicate whether the data is being completely read
//from fifo or not if count becomes zero as per the specification we have to
//make data out as high impedance
always@(posedge clock)
 begin
         if(!resetn)
                 count <= 6'b0;
         else if(soft_reset)
                 count <= 6'b0;
          else if(mem[read_ptr[3:0]][8] == 1'b1)
                          count <= mem[read_ptr[3:0]][7:2]+1'b1;
         else if(read_enb && !empty)
                 count <= count - 1'b1;
         else
                 count <= count;
 end

assign full = ((write_ptr[4] != read_ptr[4]) && (write_ptr[3:0] == read_ptr[3:0]))? 1'b1: 1'b0;
assign empty = (write_ptr[4:0] == read_ptr[4:0])? 1'b1: 1'b0;
endmodule
