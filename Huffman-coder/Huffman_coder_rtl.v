//////////////////////////////////////////////////////////////////////////////////
// Design Name: Huffman_coder_rtl
// Module Name: Huffman_coder_rtl
//////////////////////////////////////////////////////////////////////////////////

module delay_one_cycle (
  input clk,
  input original_signal,
  output reg delayed_signal
);

always @(posedge clk) begin
	delayed_signal <= original_signal;
end

endmodule

// With Avalon MM Interface interface.
module Huffman_coder_rtl ( clock, resetn, writedata, readdata, write, read, chipselect, encoded_out, length_out, enable_out );

// signals for connecting to the Avalon fabric
input clock, resetn, read, write, chipselect;
input  [31:0] writedata;
output [31:0] readdata;

// exporting contents outside of the embedded system
output [31:0] encoded_out;
output [5:0] length_out;
output enable_out; 

// locals
wire [7:0] code;
wire [3:0] length;
wire finalize;

reg mode; // high - write, low - read;
reg [11:0] data_to_write_to_ram;
reg [5:0] ram_addr;
reg clock_enable;
wire [11:0] data_from_ram;

always @*
begin 
	if (chipselect & write)
	begin
		mode <= 1'b1;
		ram_addr <= writedata[5:0];
		data_to_write_to_ram <= writedata[17:6];
		clock_enable <= 1'b0;
	end
	else if (chipselect & read)
	begin
		mode <= 1'b0;
		ram_addr <= writedata[5:0];
		clock_enable <= 1'b1;
	end
	else 
	begin 
		clock_enable <= 1'b0;
	end
end


// instantiate memory
memory_unit LUT_inst ( 
	.clock       (clock),
	.modeselect  (mode),
	.data        (data_to_write_to_ram),
	.addr        (ram_addr),
	.data_out    (data_from_ram)
);

// because after clock_enable becomes 1 again, 
// we have instantly data_from_ram that is the result from the last memory read operation. 
// We have to wait 1 cycle for the valid memory read output.
delay_one_cycle delay_coder_ce (clock, clock_enable, delayed_clock_enable);

assign length   = data_from_ram[3:0];
assign code     = data_from_ram[11:4];
assign finalize = writedata[6:6];

// instantiate coder
coder coder_inst ( 
	.clock       (clock),
	.resetn      (resetn),
	.ce          (delayed_clock_enable & clock_enable),
	.code        (code),
	.length      (length),
	.encoded_out (encoded_out),
	.enable_out  (enable_out),
	.finalize    (finalize),
	.length_out  (length_out)
);

assign readdata = encoded_out;

endmodule