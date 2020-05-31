//////////////////////////////////////////////////////////////////////////////////
// Design Name: Huffman-coder_tb
// Module Name: Huffman_coder_tb
//////////////////////////////////////////////////////////////////////////////////

// With Avalon MM Interface interface.
module Huffman_coder_tb( );

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

wire mode;
reg [11:0] data_to_write_to_ram;
reg [5:0] ram_addr;

assign mode = 1'b0; // high - write, low - read;

initial 
begin
	data_to_write_to_ram = 12'b000000000000;
	ram_addr = 6'b000000;
end

always @*
begin 
	if (chipselect & write)
	begin
		ram_addr = writedata[5:0];
		data_to_write_to_ram = writedata[17:6];
	end
	
	if (chipselect & read)
	begin
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

assign code   = codeword[7:0];
assign length = codeword[11:8];

// instantiate coder
coder DUT ( 
	.clock       (clock),
	.resetn      (resetn),
	.code        (code),
	.length      (length),
	.encoded_out (encoded_out),
	.enable_out  (enable_out)
);

endmodule