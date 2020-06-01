//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: Huffman_coder_tb
//////////////////////////////////////////////////////////////////////////////////

// With Avalon MM Interface interface.
module Huffman_coder_tb ( );

reg clk, rst, wr, rd, chselect;
reg [31:0] datawr;

wire [31:0] datard, enc;
wire enb;

reg [18:0] addr_write_to_ram;

initial 
begin
   rst = 1'b1;
//	wr = 1'b0;
//	rd = 1'b0;
//	chselect = 1'b0;
addr_write_to_ram <= 18'b110110111000000001;
end

Huffman_coder Huffman_upper (
.clock(clk), 
.resetn(rst), 
.writedata(datawr), 
.readdata(datard), 
.write(wr), 
.read(rd), 
.chipselect(chselect), 
.encoded_out(enc), 
.enable_out(enb)
);

always
begin
	clk = 1'b0;
	#5; // low for 5 * timescale = 5 ns
	clk = 1'b1;
	#5; // high for 5 * timescale = 5 ns
end

always
begin
	#5
	wr <= 1'b1;
	rd <= 1'b0;
	chselect <= 1'b1;
	datawr <= addr_write_to_ram;// [5-0]-address, [17:6]-data to write to ram;
	#10;
	wr <= 1'b0;
	rd <= 1'b1;
	chselect <= 1'b1;
	datawr <= addr_write_to_ram[5:0];
	#10
	wr <= 1'b0;
	rd <= 1'b0;
	chselect <= 1'b0;
	datawr <= 18'b0;
	addr_write_to_ram <= addr_write_to_ram + 1;
	#5;
end

endmodule