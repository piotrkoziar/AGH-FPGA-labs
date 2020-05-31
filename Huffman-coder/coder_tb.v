//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: coder_tb
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps
module coder_tb ( );

reg clk;
wire rst;
wire [7:0] cd;
wire [3:0] ln;
wire [31:0] ec_o;
wire en_o;

reg [7:0] code;
reg [3:0] codelen;

assign rst  = 1'b1;
assign cd = code;
assign ln = codelen;

initial 
begin
	code = 8'b00000000;
//	code = 8'b11111111;
   codelen = 4'b0000;
end
	
coder DUT ( 
	.clock       (clk),
	.resetn      (rst),
	.code        (cd),
	.length      (ln),
	.encoded_out (ec_o),
	.enable_out  (en_o)
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
	if (codelen > 4)
		codelen <= 1;
	else
		codelen <= codelen + 1;
		
	if (code > 200)
		code <= 0;
	else
		code <= code + 2;
	
	#5;
end


endmodule