//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: Huffman_coder
//////////////////////////////////////////////////////////////////////////////////

// With Avalon MM Interface interface.
module Huffman_coder ( clock, resetn, writedata, readdata, write, read, chipselect, encoded_out, enable_out );

// signals for connecting to the Avalon fabric
input clock, resetn, read, write, chipselect;
input  [31:0] writedata;
output [31:0] readdata;

// exporting contents outside of the embedded system
output [31:0] encoded_out;
output enable_out; 

wire [11:0] codeword;
wire [7:0] code;
wire [3:0] length;

reg mode; // high - write, low - read;
reg [11:0] data_to_write_to_ram;
reg [5:0] ram_addr;

always @*
begin 
	if (chipselect & write)
	begin
		mode = 1'b1;
		ram_addr = writedata[5:0];
		data_to_write_to_ram = writedata[17:6];
	end
	
	if (chipselect & read)
	begin
		mode = 1'b0;
		ram_addr = writedata[5:0];
	end
end


// instantiate memory
memory_unit LUT ( 
	.clock       (clock),
	.modeselect  (mode),
	.data        (data_to_write_to_ram),
	.addr        (ram_addr),
	.data_out    (codeword)
);

assign length = codeword[3:0];
assign code   = codeword[11:4];

// instantiate coder
coder coder_dut ( 
	.clock       (clock),
	.resetn      (resetn),
	.ce          (1'b1),
	.code        (code),
	.length      (length),
	.encoded_out (encoded_out),
	.enable_out  (enable_out)
);

endmodule