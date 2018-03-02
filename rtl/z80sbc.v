module z80sbc(
	input clk,
	input reset,
	input rx,
	output tx,
	output mreq_n
);
	reg ce = 0;
	reg [7:0] idata;
	wire [15:0] addr;
	wire [7:0] odata;

	wire m1_n;
	wire mreq_n;
	wire iorq_n;
	wire rd_n;
	wire wr_n;
	wire rfsh_n;
	wire halt_n;
	wire busak_n;
	wire wait_n = 1'b1;
	wire int_n = 1'b1;
	wire nmi_n = 1'b1;
	wire busrq_n = 1'b1;
	
	wire [7:0] rom_out;
	wire [7:0] ram_out;	
	wire [7:0] sio_out;
	
	reg wr_ram;
	reg wr_sio;
	reg rd_rom;
	reg rd_ram;
	reg rd_sio;

	mc6850 sio(.clk(clk),.reset(reset),.addr(addr[0]),.data_in(odata),.rd(rd_sio),.we(wr_sio),.data_out(sio_out),.ce(1'b1),.rx(rx),.tx(tx));

	always @(*)
	begin
		rd_rom = 0;
		rd_ram = 0;
		rd_sio = 0;
		wr_ram = 0;
		wr_sio = 0;
		if (addr[15:13]==3'b000)
		begin
			idata = rom_out; 
			rd_rom = ~rd_n;
		end
		else 
		begin
			idata = ram_out;
			rd_ram = ~rd_n;
			wr_ram = ~wr_n;
		end
		casex ({~iorq_n,addr[7:0]})
			// I/O MAP - addr[15:8] == addr[7:0] for this section
			{1'b1,8'b1000000x}: begin idata = sio_out; rd_sio = ~rd_n; wr_sio = ~wr_n; end         // 0x00-0x01 0x10-0x11 
		endcase
	end
	
	tv80n cpu (
		.m1_n(m1_n), .mreq_n(mreq_n), .iorq_n(iorq_n), 
		.rd_n(rd_n), .wr_n(wr_n), .rfsh_n(rfsh_n), .halt_n(halt_n), .busak_n(busak_n),
		.A(addr), .do(odata), 
		.reset_n(~reset), .clk(clk), .wait_n(wait_n), .int_n(int_n), .nmi_n(nmi_n), .busrq_n(busrq_n), .di(idata)
	);
	
	rom_memory #(.ADDR_WIDTH(13),.FILENAME("roms/z80sbc/z80sbc.bin.mem")) rom(.clk(clk),.addr(addr[12:0]),.rd(rd_rom),.data_out(rom_out));
	ram_memory #(.ADDR_WIDTH(16)) ram(.clk(clk),.addr(addr[15:0]),.data_in(odata),.rd(rd_ram),.we(wr_ram),.data_out(ram_out));
endmodule
