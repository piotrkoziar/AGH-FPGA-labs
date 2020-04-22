`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: full_reciprocal
// File Name: full_reciprocal.sv
////////////////////////////////////////////////////////////////////////////////
module full_reciprocal(
input logic clk,
input logic start,
output logic ready,
input logic [15:0] input0,
// Integer [15:0]
output logic [4:-19] output0 // Fixed point [5:19] representarion
);

// Constants
logic [4:-19] A    = 24'h0F0F0D; //<- Fixed point [5:19] representation of 1.88235
logic [4:-19] B    = 24'h169696; //<- Fixed point [5:19] representation of 2,82353
logic [4:-19] HALF = 32'h040000; //<- Fixed point [4:19] representation of 0.5
logic [4:-19] TWO  = 32'h100000; //<- Fixed point [9:38] representation of 2

// Variables
logic [4:0]   scaling;   // Keeps scaling factor
logic [9:-38] mulResult; // Temporary result of multiplication [5:19] * [5;19]
logic [4:-19] scaledVal;
logic [4:-19] approxVal;
logic [4:-19] newVal;

//Instantiate multiplier
logic mul_start;
logic mul_ready;
logic[23:0] mul_input0;
logic[23:0] mul_input1;
logic[47:0] mul_output0;
mul24_ins mul24_0( 
	.clk(clk),
	.start(mul_start),
	.ready(mul_ready),
	.input0(mul_input0),
	.input1(mul_input1),
	.output0(mul_output0) 
);

//FSM
enum {
	IDLE=0, 
	COMP_AND_SCALE, 
	MUL_A,
	SUB_B, 
	MUL_SCALED, 
	SUB_2, 
	MUL_NEW,
	CHECK_EQ, 
	ASSIGN_NEW, 
	MUL_SCALING, 
	DONE
} state;

always_ff @(posedge clk) begin: fsm
	case(state)
		IDLE: begin
			ready <= 1'b0;
			if (start == 1'b0) begin
				state <= IDLE;
			end else begin
				//Load input value
				scaledVal <= input0;
				scaling = 5'd19;
				state <= COMP_AND_SCALE;
			end
		end
		COMP_AND_SCALE: begin
			if( scaledVal < HALF ) begin
				scaledVal <= scaledVal << 1;
				scaling --;
				state <= COMP_AND_SCALE;
			end else begin
				state <= MUL_A;
			end
		end
		MUL_A: begin
			if ( mul_ready == 1'b1 ) begin
				mulResult <= mul_output0;
				state <= SUB_B;
			end else begin
				state <= MUL_A; // cont. waiting
			end
		end
		SUB_B: begin
			approxVal <= B - mulResult[4:-19];
			state <= MUL_SCALED;
		end
		MUL_SCALED: begin
			if ( mul_ready == 1'b1 ) begin
				mulResult <= mul_output0;
				state <= SUB_2;
			end else begin
				state <= MUL_SCALED; // cont. waiting
			end
		end
		SUB_2: begin
			newVal <= TWO - mulResult[4:-19];
			state <= MUL_NEW;
		end
		MUL_NEW: begin
			if ( mul_ready == 1'b1 ) begin
				mulResult <= mul_output0;
				state <= CHECK_EQ;
			end else begin
				state <= MUL_NEW; // cont. waiting
			end
		end
		CHECK_EQ: begin
			if ( approxVal == mulResult[4:-19] ) begin
				state <= DONE;
			end else begin
				state <= ASSIGN_NEW;
				newVal <= mulResult[4:-19];
			end
		end
		ASSIGN_NEW: begin
			approxVal <= newVal;
			state <= MUL_SCALED;
		end
		DONE: begin
			output0 <= (approxVal >> scaling);
			ready <= 1'b1;
			state <= IDLE;
		end
	endcase
end: fsm

always_comb begin
	case(state)
		MUL_A: begin
			mul_start <= ~mul_ready;
			mul_input0 <= A;
			mul_input1 <= scaledVal;
		end
		MUL_SCALING: begin
			mul_start <= ~mul_ready;
			mul_input0 <= scaling;
			mul_input1 <= approxVal;
		end
		MUL_SCALED: begin
			mul_start <= ~mul_ready;
			mul_input0 <= approxVal;
			mul_input1 <= scaledVal;
		end
		MUL_NEW: begin
			mul_start <= ~mul_ready;
			mul_input0 <= newVal;
			mul_input1 <= approxVal;
		end
		default: begin
			mul_start <= 1'b0;
		end
	endcase
end
endmodule