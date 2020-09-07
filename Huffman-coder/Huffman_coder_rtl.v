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
	
	input 			  read_data_length, // read data length (how many encoded bits would be in output if finalized). 
	input 			  finalize, // read with finalize to end encoding process and get last encoded data.
	input 			  codetree,
	output    		  empty_out
);

// locals
// LUT
reg mode; // high - write, low - read;
reg [11:0] data_to_write_to_ram;
reg [5:0] ram_addr;
wire [11:0] data_from_ram;

// coder
reg clock_enable, delayed_clock_enable;
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
		mode <= 1'b0;
		ram_addr <= writedata[5:0];
		clock_enable <= 1'b1;
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

// because after clock_enable becomes 1 again,
// we have instantly data_from_ram that is the result from the last memory read operation.
// We have to wait 1 cycle for the valid memory read output.
always @(posedge clock) begin
	delayed_clock_enable <= clock_enable;
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
	.read 		 (read & ( ~empty_out | finalize ) & ~read_data_length),
	.encoded_out (data_from_coder),
	.length_out  (length_out),
	.empty_out   (empty), // check before read
	.full        (full), // check before write
	.threshold	 (threshold)
);

assign readdata = (read_data_length==0) ? data_from_coder:
						(read_data_length==1) ? length_out:
						data_from_coder;
						
assign empty_out = empty;

endmodule