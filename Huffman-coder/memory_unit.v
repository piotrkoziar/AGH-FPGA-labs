//////////////////////////////////////////////////////////////////////////////////
// Design Name: memory_unit
// Module Name: memory_unit
//////////////////////////////////////////////////////////////////////////////////

module memory_unit ( clock, modeselect, data, addr, data_out );

// input signals
input clock, modeselect;
input [11:0] data;
input [5:0] addr; // 2 ^ 6 = 64

// output signals
output [11:0] data_out;

reg [11:0] ram [63:0]; // ram 12 * 64
reg [5:0] addr_reg;

initial
begin
	$display("Loading rom.");
   $readmemh("test_mem.mem", ram);
end

always @( posedge clock )
begin
	if (modeselect)
		ram[addr] <= data;
	else
		addr_reg <= addr;
end

assign data_out = ram[addr_reg];

endmodule