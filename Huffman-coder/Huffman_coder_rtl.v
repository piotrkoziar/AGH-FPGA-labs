//////////////////////////////////////////////////////////////////////////////////
// Design Name: Huffman_coder_rtl
// Module Name: Huffman_coder_rtl
//////////////////////////////////////////////////////////////////////////////////

// With Avalon MM Interface interface.
module Huffman_coder_rtl ( 
	input 		 		clock,
	input 		 		resetn, 
	input 		 		write, 
	input 				read,
	input 				chipselect, 
	input 	  [31:0] writedata, 
	output reg [31:0] readdata,
	output 				encoded_out 
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
wire finalize;
wire enable_out;
wire [5:0] length_out;

always @*
begin 
	if (chipselect & write)
	begin
		mode <= 1'b1;
		ram_addr <= writedata[5:0];
		data_to_write_to_ram <= writedata[17:6];
		clock_enable <= 1'b0;
	end
	else if (chipselect & read)
	begin
		mode <= 1'b0;
		ram_addr <= writedata[5:0];
		clock_enable <= 1'b1;
		readdata <= length_out;
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
assign finalize = writedata[6:6];

// instantiate coder
coder coder_inst ( 
	.clock       (clock),
	.resetn      (resetn),
	.ce          (delayed_clock_enable & clock_enable),
	.code        (code),
	.length      (length),
	.encoded_out (encoded_out),
	.enable_out  (enable_out),
	.finalize    (finalize),
	.length_out  (length_out)
);

endmodule