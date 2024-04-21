// Code your testbench here
// or browse Examples
module stimulus;
	reg CLK,
		RESET,
		READ,
		WRITE;
	wire EMPTY,
		 FULL;
	reg [31:0] DIN;
	wire [31:0] DOUT;
	
	FIFO_memory FF1(CLK,RESET,DIN,READ,WRITE,DOUT,EMPTY,FULL);
	initial
		begin
		CLK = 0;
        $dumpfile ("exp.vcd");
		$dumpvars (2,stimulus);
        $monitor("%d  %d",FF1.fifo_mem[0],FF1.fifo_mem[1]);
		RESET=0;READ=0;WRITE=0;
		DIN=32'h0000_0000;
		end
	
	always
	#5 CLK=~CLK;
	
	always
		begin
		#4 RESET=1;
		#4 RESET=0;
        #5 WRITE=1;DIN=$random;
		#11 DIN=$random;
		#11 DIN=$random;
		#11 DIN=$random;
		#11 DIN=$random;
		#11 DIN=$random;
		
		#11 DIN=$random;
		#11 DIN=$random;
		#1 READ = 1;
		#11 DIN=$random;
		#11 DIN=$random;
		#11 DIN=$random;
		#3 WRITE=0;
		#200 $finish;
        end
endmodule