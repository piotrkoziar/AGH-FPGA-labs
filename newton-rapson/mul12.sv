`timescale 1ns / 1ps
/* Filename: mul12.sv
 * Module Name: mul12
 */
module mul12(
input logic[11:0] input0,
input logic[11:0] input1,
output logic[23:0] output0
);
always_comb begin
	output0 <= input0 * input1;
end
endmodule