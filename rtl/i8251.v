module i8251(
  input clk,
  input reset,
  input addr,
  input [7:0] data_in,
  input rd,
  input we,
  output reg [7:0] data_out,
  input ce,
  input rx,
  output tx
);
  wire valid;
  wire tdre;
  wire [7:0] uart_out;
  wire dat_wait;
  
  simpleuart uart(
	.clk(clk),
	.resetn(~reset),

	.ser_tx(tx),
	.ser_rx(rx),

	.cfg_divider(12000000/9600),

	.reg_dat_we(we && (addr==1'b0)),
	.reg_dat_re(rd && (addr==1'b0)),
	.reg_dat_di(data_in),
	.reg_dat_do(uart_out),
	.reg_dat_wait(dat_wait),
	.recv_buf_valid(valid),
	.tdre(tdre)
);

  always @(posedge clk)
  begin
	  `ifdef DEBUG
		if (we)
		begin
			if (addr==1'b0 && ce)
				$write("%c",data_in);
		end
		`endif

		if (rd)
		begin
			if (addr==1'b1)
				data_out <= { 4'b0000,  2'b00, valid, tdre };
			else 
				data_out <= uart_out;
		end
  end
endmodule
