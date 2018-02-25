module isbc8010(
	input clk,
	input reset,
	input rx,
	output tx,
	output sync
);
	reg ce = 0;
	reg intr = 0;	
	reg [7:0] idata;
	wire [15:0] addr;
	wire rd;
	wire wr_n;
	wire inta_n;
	wire [7:0] odata;
	wire inte_o;
	wire sync;

	// Memory is sync so need one more clock to write/read
	// This slows down CPU
	always @(posedge clk) begin
		ce <= !ce;
	end

	reg[7:0] sysctl;
	
	wire [7:0] rom1_out;
	wire [7:0] rom2_out;
	wire [7:0] ram_out;
	wire [7:0] sio_out;
	
	reg wr_ram;
	reg wr_sio;
	
	reg rd_ram;
	reg rd_rom1;
	reg rd_rom2;
	reg rd_sio;
	
	always @(*)
	begin
		rd_ram = 0;
		rd_rom1 = 0;
		rd_rom2 = 0;
		rd_sio = 0;
		casex ({sysctl[6],addr[15:8]})
			// MEM MAP
			{1'b0,8'b000000xx}: begin idata = rom1_out; rd_rom1 = rd; end         // 0x0000-0x03ff
			{1'b0,8'b000001xx}: begin idata = rom2_out; rd_rom2 = rd; end         // 0x0400-0x07ff

			{1'b0,8'b001111xx}: begin idata = ram_out; rd_ram = rd; end           // 0x3c00-0x3fff
			// I/O MAP - addr[15:8] == addr[7:0] for this section
			{1'b1,8'b111011xx}: begin idata = sio_out; rd_sio = rd; end           // 0xec-0xed and mirror 0xee-0xef
		endcase
	end

	always @(*)
	begin
		wr_ram = 0;
		wr_sio = 0;

		casex ({sysctl[4],addr[15:8]})
			// MEM MAP
													// 0x0000-0x0fff read-only
			{1'b0,8'b001111xx}: wr_ram     = ~wr_n; // 0x3c00-0x3fff
										  		    
			// I/O MAP - addr[15:8] == addr[7:0] for this section
			{1'b1,8'b111011xx}: wr_sio     = ~wr_n; // 0xec-0xed and mirror 0xee-0xef
		endcase
	end
	
	always @(posedge clk)
	begin
		if (sync) sysctl <= odata;
	end
	
	i8080 cpu(.clk(clk),.ce(ce),.reset(reset),.intr(intr),.idata(idata),.addr(addr),.sync(sync),.rd(rd),.wr_n(wr_n),.inta_n(inta_n),.odata(odata),.inte_o(inte_o));
		
	rom_memory #(.ADDR_WIDTH(10),.FILENAME("roms/isbc8010/sbc80p.a23.mem")) rom1(.clk(clk),.addr(addr[9:0]),.rd(rd_rom1),.data_out(rom1_out));
	
	rom_memory #(.ADDR_WIDTH(10),.FILENAME("roms/isbc8010/sbc80p.a24.mem")) rom2(.clk(clk),.addr(addr[9:0]),.rd(rd_rom2),.data_out(rom2_out));
	
	ram_memory #(.ADDR_WIDTH(10)) ram(.clk(clk),.addr(addr[9:0]),.data_in(odata),.rd(rd_ram),.we(wr_ram),.data_out(ram_out));
	
	i8251 serial(.clk(clk),.reset(reset),.addr(addr[0]),.data_in(odata),.rd(rd_sio),.we(wr_sio),.data_out(sio_out),.ce(ce),.rx(rx),.tx(tx));

endmodule
