// With Avalon MM Interface interface.
module cordic_pipeline_avalon_interface (clock, resetn, writedata, readdata, write, read, chipselect, sincos_export, valid_export);
// signals for connecting to the Avalon fabric
input clock, resetn, read, write, chipselect;
input signed [31:0] writedata;
output [31:0] readdata;
// exporting contents outside of the embedded system
output signed [31:0] sincos_export;
output valid_export; 
wire [0:0] local_clockenable;
wire signed [31:0] from_cordic;
reg signed [11:0] to_cordic;
wire valid_out_cordic;

assign local_clockenable = 1'd1; 
assign from_cordic[15:12] = 1'b0;
assign from_cordic[31:28] = 1'b0;

initial
begin
to_cordic = 12'b000000000000;
end


// Register with angle_in value
always @*
begin 
if (chipselect & write)
begin
to_cordic = writedata[11:0];
end
end


cordic_pipeline_rtl cordic ( .clock(clock), 
									  .reset(resetn), 
									  .ce(local_clockenable), 
									  .angle_in(to_cordic), 
									  .sin_out(from_cordic[11:0]), 
									  .cos_out(from_cordic[27:16]), 
									  .valid_out(valid_out_cordic) );
assign readdata = from_cordic;
assign sincos_export = from_cordic;
assign valid_export = valid_out_cordic;
endmodule