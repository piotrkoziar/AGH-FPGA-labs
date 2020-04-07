module nios_cordic_pipeline_tb();

reg clk_n, clk_p;
wire [11:0] angle;
wire [11:0] sin;
wire [11:0] cos;
wire [31:0] sincos;
wire [0:0] valid_out;
reg reset, reset_n;
real r_angle = 1024*3.14*0.2;
real r_sin, r_cos;
// Dip switches stimulus
assign angle = r_angle;
// Reset stimulus
initial
begin
reset = 1'b1;
reset_n = 1'b0;
#10 reset = 1'b0;
reset_n = 1'b1;
end
// Clocks stimulus
initial
begin
clk_n = 1'b0; //set clk to 0
clk_p = 1'b1;
end
always
begin
#5 clk_n = ~clk_n; //toggle clk every 5 time units
clk_p = ~clk_p; //toggle clk every 5 time units
end
// Put sin and cos as real values
always @*
begin
r_sin = sin;
r_cos = cos;
r_sin = r_sin / 1024;
r_cos = r_cos / 1024;
end
// Instantiate tested module

 nios_cordic_system u0 (
	  .angle_in_external_connection_export   (angle),   // angle_in_external_connection.export
	  .clk_clk                               (clk_p),                               //                          clk.clk
	  .cordic_external_connection_sincos_out (sincos), //   cordic_external_connection.sincos_out
	  .cordic_external_connection_valid_out  (valid_out),  //                             .valid_out
	  .reset_reset_n                         (reset_n)                          //                        reset.reset_n
 );

 assign sin = sincos[11:0];
 assign cos = sincos[27:16];
 
 endmodule
 
 