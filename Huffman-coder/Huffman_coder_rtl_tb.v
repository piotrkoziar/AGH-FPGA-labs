//////////////////////////////////////////////////////////////////////////////////
// Design Name: Huffman_coder_rtl_tb
// Module Name: Huffman_coder_rtl_tb
//////////////////////////////////////////////////////////////////////////////////

// With Avalon MM Interface interface.
module Huffman_coder_rtl_tb ( );

reg local_clock, local_resetn, local_write, local_read, local_chipselect;
reg [31:0] local_writedata;

wire [31:0] local_readdata, local_encoded_out;
wire [5:0] local_length_out;
wire local_enable_out;

//reg [18:0] addr_write_to_ram;
reg [5:0] addr_to_ram;
reg [3:0] len_of_data;
reg [7:0] data_to_ram;
reg local_finalize;

initial 
begin
   local_resetn = 1'b1;
	addr_to_ram <= 6'b000001;
	len_of_data <= 4'b1000;
	data_to_ram <= 8'b00000001;
	local_finalize <= 1'b0;
end

Huffman_coder_rtl Huffman_upper (
.clock(local_clock), 
.resetn(local_resetn), 
.writedata(local_writedata), 
.readdata(local_readdata), 
.write(local_write), 
.read(local_read), 
.chipselect(local_chipselect), 
.encoded_out(local_encoded_out), 
.length_out(local_length_out),
.enable_out(local_enable_out)
);

always
begin
	local_clock = 1'b0;
	#5; // low for 5 * timescale = 5 ns
	local_clock = 1'b1;
	#5; // high for 5 * timescale = 5 ns
	if (local_enable_out == 1'b1)
	begin
		$display("Output code bin: %b, hex: %h", local_encoded_out, local_encoded_out);
	end
end

always
begin
	#5
	#200
	local_finalize <= 1'b1;
	#10
	local_finalize <= 1'b0;
end

always
begin
	#5
	local_write <= 1'b1;
	local_read <= 1'b0;
	local_chipselect <= 1'b1;
	local_writedata <= {data_to_ram, len_of_data, addr_to_ram};

	$display("Write to RAM: address %d, data_len %d, data bin: %b, hex: %h, decimal: %d", 
			addr_to_ram, len_of_data, data_to_ram, data_to_ram, data_to_ram);
	#10;
	local_write <= 1'b0;
	local_read <= 1'b1;
	local_chipselect <= 1'b1;
	local_writedata <= {local_finalize, addr_to_ram};
	
	$display("Read from RAM: address %d, finalize: %d", addr_to_ram, local_finalize);
	#5;
	addr_to_ram <= addr_to_ram + 1;
	len_of_data <= (len_of_data != 4'b1000) ? 4'b1000 : 4'b0100;
	data_to_ram <= (data_to_ram > 8'b10000000) ? 8'b00000001 : data_to_ram + 1;
end

endmodule