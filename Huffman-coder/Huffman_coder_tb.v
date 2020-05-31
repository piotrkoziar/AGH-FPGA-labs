//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: Huffman_coder_tb
//////////////////////////////////////////////////////////////////////////////////

// With Avalon MM Interface interface.
module Huffman_coder_tb ( );

reg clk, rst, wr, rd, chselect, enb;
reg [31:0] datawr, datard, enc;

initial 
begin
   rst = 1'b1;
	wr = 1'b0;
	rd = 1'b0;
	chselect = 1'b0;
end

Huffman_coder DUT (
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
	#5;
	wr <= 1'b0;
	rd <= 1'b1;
	chselect <= 1'b1;
	#10;
	wr <= 1'b0;
	rd <= 1'b0;
	chselect <= 1'b0;
	#5;
end

endmodule