//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: coder
//////////////////////////////////////////////////////////////////////////////////

module coder ( clock, resetn, ce, code, length, encoded_out, enable_out );

// input signals
input clock, resetn, ce;
input [7:0] code;
input [3:0] length;

// output signals
output [31:0] encoded_out;
output enable_out; 

reg [5:0]  acc_length; // accumulated code length (can have values 0-39)
reg [39:0] tmp_reg; // temporary register
reg [31:0] output_reg;
wire flag32;
reg [0:0] ready;

initial 
begin
acc_length = 6'b0;
tmp_reg = 39'b0;
end

assign flag32 = acc_length[5]; 
parameter mask = 39'h7fffffffff;

always @( posedge clock )
begin
	if (ce == 1'b1 && length > 1'b0)
	begin
		if (resetn == 1'b0) 
		begin
			acc_length = 6'b0;
			tmp_reg = 39'b0;
		end

		if (flag32 == 1'b1) // check if in tmp_reg there is >= 32 bits.
		begin
			/*
			* Adding with a mask. Final mask is created from two masks:
			* 1) h7fffffffff << (acc_length - 32)
			* 2) h7fffffffff >> (39 - (acc_length - 32) - lengh)
			* For example, if length = 2 and (acc_length - 32) = 1:
			* 1) 111111111111111111111111111111111111110
			* 2) 000000000000000000000000000000000000111
			* and the final mask will look like:
			* 	  000000000000000000000000000000000000110
			*/
			tmp_reg <= (tmp_reg >> 32) + ( ((mask << (acc_length - 32)) & (mask >> (39 - acc_length + 32 - length))) & (code << (acc_length - 32)) );
			acc_length <= length + acc_length - 32;
			output_reg <= tmp_reg[31:0]; 
			ready <= 1'b1;
		end
		else
		begin
			/*
			* Adding with a mask. Final mask is created from two masks:
			* 1) h7fffffffff << acc_length
			* 2) h7fffffffff >> (39 - acc_length - lengh)
			* For example, if length = 2 and acc_length = 3:
			* 1) 111111111111111111111111111111111111000
			* 2) 000000000000000000000000000000000011111
			* and the final mask will look like:
			* 	  000000000000000000000000000000000011000
			*/
			tmp_reg <= tmp_reg + ( ((mask << acc_length) & (mask >> (39 - acc_length - length))) & (code << acc_length) );
			acc_length <= length + acc_length;
			ready <= 1'b0;
		end
	end // ce == 1
end


assign encoded_out = output_reg;
assign enable_out = ready;

endmodule