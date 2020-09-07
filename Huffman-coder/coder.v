//////////////////////////////////////////////////////////////////////////////////
// Design Name: coder
// Module Name: coder
//////////////////////////////////////////////////////////////////////////////////

module coder (

	// input signals
	input 		 clock, resetn, ce,
	input [7:0]  code,
	input [3:0]  length,
	input 	    finalize, // finalize encoding operation. Output will be prepared from data collected so far.
	input 		 read,	  // read encoded data from FIFO.

	// output signals
	output reg [31:0] encoded_out, // encoded data read from FIFO or partially encoded data when finalized.
	output 	  [5:0]  length_out, // length of encoded data in output, if finalized.
	output       		empty_out, // states if there is any encoded data in FIFO to be read.
	output 		  		full, // 1 if there is no more space to store the data!
	output 		  		threshold // threshold in data storage.
);

// coder
reg [5:0]  acc_length; // accumulated code length (can have values 0-39).
reg [39:0] tmp_reg; // temporary register.
reg [31:0] output_reg; // prepared encoded data (to be stored in FIFO).
reg [0:0] ready;
wire flag32;

// FIFO
wire overflow;
wire underflow;
wire [31:0] data_from_fifo;

initial
begin
acc_length <= 6'b0;
tmp_reg <= 39'b0;
end

assign flag32 = acc_length[5];
assign length_out = acc_length;

parameter mask = 39'h7fffffffff;

always @( posedge clock )
begin
	if (ce == 1'b1)
	begin
		if (resetn == 1'b0)
		begin
			acc_length <= 6'b0;
			tmp_reg <= 39'b0;
		end
		else if (flag32 == 1'b1) // check if in tmp_reg there is >= 32 bits.
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
	else if ( finalize & read )
	begin
		encoded_out <= tmp_reg[31:0];
		acc_length <= 6'b0;
		tmp_reg <= 39'b0;
		ready <= 1'b0; // always set ready to 0 if not clock enable
	end
	else if ( read )
	begin
		encoded_out <= data_from_fifo;
		ready <= 1'b0; // always set ready to 0 if not clock enable
	end
	else
		ready <= 1'b0; // always set ready to 0 if not clock enable
end

FIFO_coder fifo (
	.data_out ( data_from_fifo ),
	.fifo_full ( full ),
	.fifo_empty ( empty_out ),
	.fifo_threshold ( threshold ),
	.fifo_overflow ( overflow ),
	.fifo_underflow ( underflow ),
	.clk (clock),
	.rst_n (resetn),
	.wr (ready),
	.rd (read & ~finalize),
	.data_in (output_reg)
);

endmodule