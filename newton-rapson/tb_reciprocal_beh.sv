`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_reciprocal_beh
// File Name: tb_reciprocal.sv
////////////////////////////////////////////////////////////////////////////////
//
module tb_reciprocal_beh();
real inputFP, outputFP;
logic [15:0] input0;
logic [4:-19] output0;
en_reciprocal_beh UUT ( .input0, .output0 );

initial begin
	input0 = 16'd3;
end

endmodule