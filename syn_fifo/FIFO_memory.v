// Code your design here
module FIFO_memory(clk,reset,din,read,write,dout,empty,full); 
 
	input clk; 
	input reset; 
    input [31:0]din;	//32-bit data input 
	input read; 
	input write; 
 
    output [31:0]dout; //32-bit data output 
	output empty; 	   //flag to indicate that the memory is empty 
	output full;	   //flag to indicate that the memory is full 
	 
	parameter DEPTH=3, MAX_COUNT=3'b111;	 
//DEPTH is number of bits, 3 bits thus 2^3=8 memory locations and MAX_COUNT is the last memory location. 
	 
	reg [31:0]dout; 
	//reg empty; 
	//reg full; 
 
	/*wptr is write_pointer and rptr is read_pointer*/ 
 
	reg [(DEPTH-1):0]rptr;	 
// rptr(3bits) defines memory pointer location for reading instructions(000 or 001....111) 
	 
	reg [(DEPTH-1):0]wptr;	 
// wptr(3bits) defines memory pointer location for writing instructions(000 or 001....111) 
	 
	reg [(DEPTH-1):0]count;	 
// 3 bits count register[000(0),001(1),010(2),....,111(7)] 
	 
	reg [31:0]fifo_mem[0:MAX_COUNT];  
// fifo memory is having 16 bits data and 8 memory locations 
	 

 
///////// WHEN BOTH READING AND WRITING BUT FIFO IS EMPTY //////// 
/* 
	always @(posedge clk) 
		begin 
			if(reset==1) 
			//reset is pressed															 
				sr_read_write_empty <= 0; 
			else if(read==1 && empty==1 && write==1)	 
			//when fifo is empty and read & write both 1 
				sr_read_write_empty <= 1; 
			else 
				sr_read_write_empty <= 0; 
		end 
*/ 
//////////////////////// COUNTER OPERATION /////////////////////// 
		 
	always @(posedge clk) 
		begin 
			if(reset==1) 
//when reset, the fifo is made empty thus count is set to zero 
				count <= 3'b000;		 
			else 
				begin 
					case({read,write}) 
					//CASE-1:when not reading or writing	 
						2'b00:	count <= count;				 
								//count remains same 
					//CASE-2:when writing only 
						2'b01:	if(!full)			 
									count <= count+1; 
									//count increases 
					//CASE-3:when reading only							 
						2'b10:	if(!empty)				 
									count <= count-1;							 
									//count decreases 
					//CASE-4 
						2'b11:	if(empty)	 
									count <= count+1; //(if) fifo is empty => only w
//(if) fifo is empty => only write, thus count increases			 
								else if(full)
									count <= count-1;
								else
									count <= count; 
//(else) both read and write takes place, thus no change											 
					//DEFAULT CASE			 
						default: count <= count;
                    endcase
                end
        end
////////////////////// EMPTY AND FULL ALERT ///////////////////// 
	
	assign empty = (count==3'b000);
	assign full = (count==MAX_COUNT);
	// Memory empty signal 

///////////// READ AND WRITE POINTER MEMORY LOCATION ///////////// 
 
	// Write operation memory pointer 
	always @(posedge clk)
		begin 
			if(reset) 
			//wptr moved to zero location (fifo is made empty) 
				wptr <= 3'b000;	 
			else 
				begin 
					if(write && !full)	 
					//writing when memory is NOT FULL 
						wptr <= wptr+1; 
				end 
		end 
	// Write operation 
	always @(posedge clk) 
		//IT CAN WRITE WHEN RESET IS USED AS FULL==0	 
		begin 
			if(write && !full) 
			//writing when memory is NOT FULL 
				fifo_mem[wptr] <= din; 
			else									 
			//when NOT WRITING 
				fifo_mem[wptr] <= fifo_mem[wptr]; 
		end  
	// Read operation memory pointer 
		always @(posedge clk) 
			begin 
				if(reset) 
				//rptr moved to zero location (fifo is made empty) 
					rptr <= 3'b000;	 
				else 
					begin 
						if(read && !empty)	 
						//reading when memory is NOT ZERO 
							rptr <= rptr+1; 
					end 
			end 
 
//////////////////// READ AND WRITE OPERATION //////////////////// 
 	// Read operation 
	always @(posedge clk) 
		begin 
			if(reset)						 
			//reset implies output is zero 
				dout <= 32'h0000; 
			else if(read && !empty)	 
			//reading data when memory is NOT EMPTY 
				dout <= fifo_mem[rptr]; 
			else 
			//no change 
				dout <= dout;  
		end 
endmodule

