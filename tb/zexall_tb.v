`timescale 1ns/1ns 

module zexall_tb();
	reg clk = 0;
	reg reset;
	reg rx = 1'b1;
	wire tx;
	
	zexall machine(.clk(clk),.reset(reset),.rx(rx),.tx(tx));
	
	always
		#(5) clk <= !clk;

	initial
	begin
		//$dumpfile("zexall_tb.vcd");
		//$dumpvars(0,zexall_tb);
		reset = 1;
		#20
		reset = 0;
		#52000000
		$finish;
	end
endmodule
