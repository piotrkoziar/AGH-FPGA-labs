`timescale 1ns / 1ps
/* Module Name: mul24_ins
 * File Name: mul24_ins.sv
 */
module mul24_ins(
input  logic clk,
input  logic start,
output logic ready,
input  logic[23:0] input0,
input  logic[23:0] input1,
output logic[47:0] output0
);

// Multiplier instantiation.
logic [11:0] mul1_input0, mul1_input1;
logic [23:0] mul1_output0;
mul12 mul12_1 ( 
	.input0(mul1_input0),
	.input1(mul1_input1),
	.output0(mul1_output0)
);

// Auxiliary signals.
logic [11:0] a0, a1, b0, b1; // a0 = low(input0); a1 = high(input0); b0 = low(input2); ...
assign a0 = input0[11:0];
assign a1 = input0[23:12];
assign b0 = input1[11:0];
assign b1 = input1[23:12];

logic [23:0] tmp; // Tmp. result of fractional mul.
logic [47:0] result;
assign output0 = result;

/* FSM */
enum {
	IDLE=0, 
	P0, 
	P1, 
	P2, 
	DONE
} state;

always_ff @(posedge clk) begin: fsm
	case(state)
		IDLE: begin
			if ( start == 1'b0) begin
				state <= IDLE;
			end else begin
				ready <= 1'b0;
				result <= 48'h0;
				tmp <= mul1_output0; // tmp <= a0 * b0;
				state <= P0;
			end
		end
		P0: begin
			result[23:0] <= tmp;
			tmp <= mul1_output0; // tmp <= a1 * b0;
			state <= P1;
		end
		P1: begin
			result[35:12] <= result[35:12] + tmp;
			tmp <= mul1_output0; // tmp <= a0 * b1;
			state <= P2;
		end
		P2: begin
			result[36:12] <= result[35:12] + tmp;
			tmp <= mul1_output0; // tmp <= a1 * b1;
			state <= DONE;
		end
		DONE: begin
			result[47:24] <= result[47:24] + tmp;
			ready <= 1'b1;
			state <= IDLE;
		end
	endcase
end: fsm

/* Functional unit inputs assignments. */
always_comb begin
	case(state)
		IDLE: begin
			mul1_input0 = a0; mul1_input1 = b0; // tmp <= a0 * b0;
		end
		P0: begin
			mul1_input0 = a1; mul1_input1 = b0; // tmp <= a1 * b0;
		end
		P1: begin
			mul1_input0 = a0; mul1_input1 = b1; // tmp <= a0 * b1;
		end
		P2: begin
			mul1_input0 = a1; mul1_input1 = b1; // tmp <= a0 * b1;
		end
	endcase;
end

endmodule