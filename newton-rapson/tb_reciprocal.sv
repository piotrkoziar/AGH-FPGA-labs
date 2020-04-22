`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
//
// Module Name: tb_reciprocal
// File Name: tb_reciprocal.sv
////////////////////////////////////////////////////////////////////////////////
//
module tb_reciprocal( );
logic clk;
logic start;
logic ready;
logic [15:0] input0;   // Integer [15:0]
logic [4:-19] output0; // Fixed point [5:19] representarion.

int tmp_i, input_i;
real input_r, check_r, output_r;
logic ready_prev; // the state of ready in previous clock

full_reciprocal UUT(.clk, .start, .ready, .input0, .output0);

// Clock generator
always begin
	#5 clk = 1; #5 clk = 0;
end

initial begin
	input_i = 3;
	input_r = input_i;
	check_r = 1 / input_r;
	input0 <= input_i;
	start <= 1'b1;
end

always@( posedge clk ) begin
	start <= ready; //self handshaking
end

always@( posedge clk ) begin
	if ( ready == 1'b1 /*&& ready_prev == 1'b0*/ ) begin // new value arrived
		input_r = input0;
		check_r = 1 / input_r;
		output_r = output0;
		output_r = output_r / ( 2 ** 19 );
		$display ( "Input is %f. Output is %f. Correct result is %f", input_r,
		output_r, check_r);
		input_i ++;
		input0 <= input_i;
	end
end
endmodule