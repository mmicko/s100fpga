`timescale 1ns/1ns 

module z80sbc_tb();
	reg clk = 0;
	reg reset;
	reg rx = 1'b1;
	wire tx;
	
	z80sbc machine(.clk(clk),.reset(reset),.rx(rx),.tx(tx));
	
	always
		#(5) clk <= !clk;

	initial
	begin
		$dumpfile("z80sbc_tb.vcd");
		$dumpvars(0,z80sbc_tb);
		reset = 1;
		#20
		reset = 0;
		#5200000
		$finish;
	end
endmodule
