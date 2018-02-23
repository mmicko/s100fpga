module prom_memory(
  input clk,
  input [7:0] addr,
  input rd,
  output reg [7:0] data_out
);
	parameter FILENAME = "";

  reg [7:0] rom[0:255] /* verilator public_flat */;
  
  initial
  begin
    if (FILENAME!="")
		  $readmemh(FILENAME, rom);
  end

  always @(posedge clk)
  begin
	if (rd)
		data_out <= rom[addr];
  end
endmodule
