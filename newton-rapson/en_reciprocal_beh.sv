`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Design Name:
// Module Name: reciprocal_beh
// File Name: reciprocal_beh.sv
////////////////////////////////////////////////////////////////////////////////
module en_reciprocal_beh(
	input logic [15:0] input0,
	// argument: integer [15:0]
	output logic [4:-19] output0 // result: fixed point [5:19] representation
);
// Constants
logic [4:-19] A = 24'h0F0F0D; // Fixed point [5:19] representation of 1.88235
logic [4:-19] B = 24'h169696; // Fixed point [5:19] representation of 2,82353
logic [4:-19] HALF = 32'h040000; // Fixed point [4:19] representation of 0.5
logic [4:-19] TWO = 32'h100000; // Fixed point [4:19] representation of 2

// Variables
logic [4:0]   scaling; // Keeps scaling factor
logic [9:-38] mulResult; // Temporary result of multiplication [5:19] * [5;19]
logic [4:-19] scaledVal;
logic [4:-19] approxVal;
logic [4:-19] newVal;

real resultFP; // To display human readable

always_comb begin
	// Here scaledVal = input / 2**19 for different data representations
	scaledVal = input0; // IDLE
	// therefore scaling starts from maximum value and goes backwards
	scaling = 19;
	// Scale tmpValue to range [0.5, 1] i.e. [0x080000, 0x040000] in integer
	// In difference to oryginal algorithm we multiply by two in each iteration
	while( scaledVal < HALF ) begin // COMP_AND_SCALE
		scaledVal = scaledVal << 1; // Multiply by two i.e. LSR
		scaling --;
	end
	
	// Take Linear aproximation x0 = 2.82353 - 1.88235 * d.
	mulResult = scaledVal * A; // Result is fixpoint [10:38]. MUL_A
	approxVal = mulResult >> 19; // keep [4:19] fxp format
	approxVal = B - approxVal; // SUB_B
	
	while(1) begin // iterate: x(i+1) = x(i) * ( 2 - x(i)*d )
		mulResult = approxVal * scaledVal; // MUL_SCALED
		newVal = mulResult >> 19; // keep [4:19] fxp format
		newVal = TWO - newVal; // SUB_2
		mulResult = approxVal * newVal; // MUL_NEW
		newVal = mulResult >> 19; // keep [4:19] fxp format
		if( approxVal == newVal ) begin break; end // CHECK_EQ
		approxVal = newVal; // ASSIGN_NEW
	end
	
	// Denormalize back to oryginal range
	approxVal = approxVal >> scaling;
	output0 = approxVal;
	// Print result
	$display("Binary result is = %b", approxVal);
	resultFP = approxVal;
	resultFP = resultFP / 2**19;
	$display("Real value is = %f", resultFP);
end 
endmodule