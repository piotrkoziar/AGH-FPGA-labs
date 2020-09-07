//////////////////////////////////////////////////////////////////////////////////
// Design Name: Huffman_coder_rtl
// Module Name: Huffman_coder_rtl
//////////////////////////////////////////////////////////////////////////////////

module Huffman_coder_rtl (
	// Avalon MM Interface.
	input 		 	  clock,
	input 		 	  resetn,
	input 		 	  write,
	input 			  read,
	input 			  chipselect,
	input 	 [31:0] writedata,
	output    [31:0] readdata,
	
	input 			  access_mode, // write to LUT or read data length (how many encoded bits would be in output if finalized). 
	input 			  finalize, // read with finalize to end encoding process and get last encoded data.
	output    		  empty_out
);

// locals
// LUT
reg mode; // high - write, low - read;
reg [11:0] data_to_write_to_ram;
reg [5:0] ram_addr;
wire [11:0] data_from_ram;

// coder
reg clock_enable, delayed_clock_enable, delayed_read;
wire [7:0] code;
wire [3:0] length;
wire [5:0] length_out;
wire [31:0] data_from_coder;
wire empty;
wire full;
wire threshold;

always @*
begin
	if (chipselect & write)
	begin
		if ( access_mode == 0 )
		begin
			mode <= 1'b0;
			ram_addr <= writedata[5:0];
			clock_enable <= 1'b1;
		end
		else
		begin
			// modify LUT codes.
			mode <= 1'b1;
			ram_addr <= writedata[5:0];
			data_to_write_to_ram <= writedata[17:6];
			clock_enable <= 1'b0;
		end
	end
	else if (chipselect & read)
	begin
		// read from FIFO.
		clock_enable <= 1'b0;
	end
	else
	begin
		clock_enable <= 1'b0;
	end
end

always @(posedge clock) begin
	// because after clock_enable becomes 1 again,
	// we have instantly data_from_ram that is the result from the last memory read operation.
	// We have to wait 1 cycle for the valid memory read output.
	delayed_clock_enable <= clock_enable;
	
	delayed_read <= read;
end

// instantiate memory
memory_unit LUT_inst (
	.clock       (clock),
	.modeselect  (mode),
	.data        (data_to_write_to_ram),
	.addr        (ram_addr),
	.data_out    (data_from_ram)
);

assign length   = data_from_ram[3:0];
assign code     = data_from_ram[11:4];

// instantiate coder
coder coder_inst (
	.clock       (clock),
	.resetn      (resetn),
	.ce          (delayed_clock_enable & clock_enable),
	.code        (code),
	.length      (length),
	.finalize    (finalize),
	.read 		 (read & ( ~empty_out | finalize ) & ~access_mode & ~delayed_read),
	.encoded_out (data_from_coder),
	.length_out  (length_out),
	.empty_out   (empty), // check before read
	.full        (full), // check before write
	.threshold	 (threshold)
);

assign readdata = (access_mode==0) ? data_from_coder:
						(access_mode==1) ? length_out:
						data_from_coder;
						
assign empty_out = empty;

endmodule