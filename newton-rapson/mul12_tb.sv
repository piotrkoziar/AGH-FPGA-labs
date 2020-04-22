`timescale 1ns / 1ps
/* Filename: multiply12_tb.sv
 * Module Name: mul12_tb
 */
module mul12_tb();
logic clk; // Give simulation a tick. The module does not need this
logic [11:0] input0, input1;
logic [23:0] output0;
// Instantiate the module
mul12 UUT ( .input0, .input1, .output0 );
initial begin
	input0 = 12'hff0;
	input1 = 12'hff0;
end
always
begin
	clk = 1'b0;
	#5; // low for 5 * timescale = 5 ns
	clk = 1'b1;
	#5; // high for 5 * timescale = 5 ns
end
always@(posedge clk) begin
	if ( input0 * input1 != output0) begin
		$display("Multiplication error. Stop");
		$stop;
	end
	input0 = input0 + 1;
	input1 = input1 + 1;
end
endmodule