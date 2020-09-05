//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: coder_tb
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ps / 1 ps
module coder_tb ( );

reg clk, clken;
wire rst;
wire [7:0] cd;
wire [3:0] ln;
wire [31:0] ec_o;
wire en_o;
wire [5:0] len_out;

reg [7:0] code;
reg [3:0] codelen;
reg [0:0] finalize;

assign rst  = 1'b1;
assign cd = code;
assign ln = codelen;

initial 
begin
	code = 8'b00000000;
//	code = 8'b11111111;
   codelen = 4'b0000;
	clken = 1'b1;
	finalize = 1'b0;
end
	
coder DUT ( 
	.clock       (clk),
	.resetn      (rst),
	.ce 			 (clken),
	.code        (cd),
	.length      (ln),
	.encoded_out (ec_o),
	.enable_out  (en_o),
	.finalize    (finalize),
	.length_out  (len_out)
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
	
	if ( finalize == 1'b1 )
	begin
		code <= 0;
		finalize <= 1'b0;
	end
	else if (code > 20)
		finalize <= 1;
	else
		code <= code + 2;
	
	#5;
end


endmodule