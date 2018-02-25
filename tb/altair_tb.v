`timescale 1ns/1ns 

module altair_tb();
	reg clk = 0;
	reg reset;
	reg rx = 1'b1;
	wire tx;
	
	altair machine(.clk(clk),.reset(reset),.rx(rx),.tx(tx));
	
	always
		#(5) clk <= !clk;

	initial
	begin
		$dumpfile("altair_tb.vcd");
		$dumpvars(0,altair_tb);
		reset = 1;
		#20
		reset = 0;
		#2200000
		$finish;
	end
endmodule
