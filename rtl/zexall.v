module zexall(
	input clk,
	input reset,
	input rx,
	output tx,
	output sync
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
	
	
	// Memory is sync so need one more clock to write/read
	// This slows down CPU
	always @(posedge clk) begin
		ce <= !ce;
	end
	
	wire [7:0] rom_out;
	wire [7:0] ram_out;
	wire [7:0] sio_out;
	
	reg wr_ram;	
	reg rd_ram;
	
	reg [7:0] r_ack;
	reg [7:0] r_req;
	reg [7:0] r_req_last;
	reg [7:0] r_data;
	
	initial
	begin
		r_ack = 0;
		r_req = 0;
		r_req_last = 0;
		r_data = 0;
	end
	
	always @(*)
	begin
		rd_ram = 0;
		casex ({mreq_n,addr[15:8]})
			// MEM MAP
			{1'b0,8'b00xxxxxx}: begin idata = ram_out; rd_ram = ~rd_n; end         // 0x0000-0x0fff
		endcase
	end
	
	always @(*)
	begin
		casex ({~rd_n,mreq_n, addr[15:0]})
			{2'b10,16'hfffd}: begin 
								if (r_req_last!= r_req) 
								begin
									r_ack = r_ack + 1; 
									r_req_last = r_req;
								end
								idata = r_ack; 
							  end         // 0xfffd
			{2'b10,16'hfffe}: begin idata = r_req; end         // 0xfffe
			{2'b10,16'hffff}: begin idata = r_data;  end         // 0xffff
		endcase
	end

	always @(*)
	begin
		wr_ram = 0;
		casex ({mreq_n,addr[15:8]})
			// MEM MAP
			{1'b0,8'b00xxxxxx}: wr_ram     = ~wr_n; // 0x1000-0x13ff
		endcase
	end
	
	always @(*)
	begin
		casex ({~wr_n,mreq_n, addr[15:0]})
			{2'b10,16'hfffd}: begin r_ack = 8'h00;  end         // 0xfffd
			{2'b10,16'hfffe}: begin r_req_last = r_req; r_req = odata;  end         // 0xfffe
			{2'b10,16'hffff}: begin r_data = odata;$write("%c",odata);  end         // 0xffff
		endcase
	end
	
	tv80n cpu (
		.m1_n(m1_n), .mreq_n(mreq_n), .iorq_n(iorq_n), 
		.rd_n(rd_n), .wr_n(wr_n), .rfsh_n(rfsh_n), .halt_n(halt_n), .busak_n(busak_n),
		.A(addr), .do(odata), 
		.reset_n(~reset), .clk(clk), .wait_n(wait_n), .int_n(int_n), .nmi_n(nmi_n), .busrq_n(busrq_n), .di(idata)
	);
	
	ram_memory #(.ADDR_WIDTH(14),.FILENAME("roms/zexall/zexall.bin.mem")) ram(.clk(clk),.addr(addr[13:0]),.data_in(odata),.rd(rd_ram),.we(wr_ram),.data_out(ram_out));
endmodule
