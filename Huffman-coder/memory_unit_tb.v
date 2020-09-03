//////////////////////////////////////////////////////////////////////////////////
// Design Name: 
// Module Name: memory_unit_tb
//////////////////////////////////////////////////////////////////////////////////

/* 
How do I test memory_unit:
1. Uncomment (or add if necessary) 
	
	initial
	begin
		$display("Loading rom.");
		$readmemh("test_mem.mem", ram);
	end

	to memory_unit.v.
	
2. Create test_mem.mem file that contains 64 12-long words e.g.

dea
bee
fef
000
 .
 .
 . 
	
	
3. Put test_mem.mem file to directory of vsim - for me it is [...]/modelsim_ase/bin
4. Compile and simulate in ModelSim.
*/
 
module memory_unit_tb ( );

reg clk;
wire mode;
wire [11:0] write;
wire [5:0] address;
wire [11:0] read;

reg [5:0] a;

initial 
begin
	a = 6'b0;
end

assign address = a;
assign mode = 1'b0;

memory_unit UUT ( 
	.clock       (clk),
	.modeselect  (mode),
	.data        (write),
	.addr        (address),
	.data_out    (read)
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
	if (a > 62)
		a <= 0;
	else
		a <= a + 1;
	#5;
end
endmodule