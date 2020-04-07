//////////////////////////////////////////////////////////////////////////////////
// Design Name: The pipelined custom processor for cordic algorithm
// Module Name: cordic_pipeline_rtl
//////////////////////////////////////////////////////////////////////////////////
module cordic_pipeline_rtl( clock, reset, ce, angle_in, sin_out, cos_out, valid_out );
parameter integer W = 12; //Width of the fixed-point (12:10) representation
parameter FXP_MUL = 1024; //Scaling factor for fixed-point (12:10) representation
parameter PIPE_LATENCY = 15; // Input->output delay in clock cycles
input clock, reset, ce;
input signed [W-1:0] angle_in; //Angle in radians
output signed [W-1:0] sin_out, cos_out;
output valid_out;
//Valid data output flag
//Cordic look-up table
reg signed [11:0] atan[0:10];
initial begin
  atan[0] = 0.785398163 * FXP_MUL;
  atan[1] = 0.463647609 * FXP_MUL;
  atan[2] = 0.244978663 * FXP_MUL;
  atan[3] = 0.124354995 * FXP_MUL;
  atan[4] = 0.06241881 * FXP_MUL; 
  atan[5] = 0.031239833 * FXP_MUL;
  atan[6] = 0.015623729 * FXP_MUL; 
  atan[7] = 0.007812341 * FXP_MUL;
  atan[8] = 0.00390623 * FXP_MUL;
  atan[9] = 0.001953123 * FXP_MUL;
  atan[10] = 0.000976562 * FXP_MUL;
end

//Tabs of wires for connections between the stage processors a2 - a13
wire signed [W-1:0] sin_tab [0:11];
wire signed [W-1:0] cos_tab [0:11];
wire signed [W-1:0] t_angle_tab [0:11]; //Target angle also must be pipelined
wire signed [W-1:0] angle_tab [0:11];
//
reg unsigned [4:0] valid_cnt; //Counts pipeline delay
//Synchroniuos activity: latency counter, angle_in latch
always@(posedge clock)
begin
if ( reset == 1'b0 )
valid_cnt <= PIPE_LATENCY; //Setup latency counter
else
if( ( valid_cnt != 0 ) && ( ce == 1'b1 ) )
valid_cnt <= valid_cnt - 1; //Valid output data moves toward output
end
assign valid_out = ( valid_cnt == 0 )? 1'b1 : 1'b0; //Set valid_out when counter counts up to PIPE_LATENCY
//Stage a1
assign cos_tab[0] = 1.0 * FXP_MUL;
assign sin_tab[0] = 0;
assign angle_tab[0] = 0;
assign t_angle_tab[0] = angle_in;
//Stage a2 - 13 processor netlist
cordic_step #(0) cordic_step_0 ( clock, ce, sin_tab[0], cos_tab[0], angle_tab[0], t_angle_tab[0], atan[0],
sin_tab[1], cos_tab[1], angle_tab[1], t_angle_tab[1] );
cordic_step #(1) cordic_step_1 ( clock, ce, sin_tab[1], cos_tab[1], angle_tab[1], t_angle_tab[1], atan[1],
sin_tab[2], cos_tab[2], angle_tab[2], t_angle_tab[2] );
cordic_step #(2) cordic_step_2 ( clock, ce, sin_tab[2], cos_tab[2], angle_tab[2], t_angle_tab[2], atan[2],
sin_tab[3], cos_tab[3], angle_tab[3], t_angle_tab[3] );
cordic_step #(3) cordic_step_3 ( clock, ce, sin_tab[3], cos_tab[3], angle_tab[3], t_angle_tab[3], atan[3],
sin_tab[4], cos_tab[4], angle_tab[4], t_angle_tab[4] );
cordic_step #(4) cordic_step_4 ( clock, ce, sin_tab[4], cos_tab[4], angle_tab[4], t_angle_tab[4], atan[4],
sin_tab[5], cos_tab[5], angle_tab[5], t_angle_tab[5] );
cordic_step #(5) cordic_step_5 ( clock, ce, sin_tab[5], cos_tab[5], angle_tab[5], t_angle_tab[5], atan[5],
sin_tab[6], cos_tab[6], angle_tab[6], t_angle_tab[6] );
cordic_step #(6) cordic_step_6 ( clock, ce, sin_tab[6], cos_tab[6], angle_tab[6], t_angle_tab[6], atan[6],
sin_tab[7], cos_tab[7], angle_tab[7], t_angle_tab[7] );
cordic_step #(7) cordic_step_7 ( clock, ce, sin_tab[7], cos_tab[7], angle_tab[7], t_angle_tab[7], atan[7],
sin_tab[8], cos_tab[8], angle_tab[8], t_angle_tab[8] );
cordic_step #(8) cordic_step_8 ( clock, ce, sin_tab[8], cos_tab[8], angle_tab[8], t_angle_tab[8], atan[8],
sin_tab[9], cos_tab[9], angle_tab[9], t_angle_tab[9] );
cordic_step #(9) cordic_step_9 ( clock, ce, sin_tab[9], cos_tab[9], angle_tab[9], t_angle_tab[9], atan[9],
sin_tab[10], cos_tab[10], angle_tab[10], t_angle_tab[10] );
cordic_step #(10)cordic_step_10( clock, ce, sin_tab[10], cos_tab[10], angle_tab[10], t_angle_tab[10],
atan[10], sin_tab[11], cos_tab[11], angle_tab[11], t_angle_tab[11] );
//Stage a14 - 18: scaling of the results
mul_Kn mul_Kn_sin ( clock, ce, sin_tab[11], sin_out, t_angle_tab[11] );
mul_Kn mul_Kn_cos ( clock, ce, cos_tab[11], cos_out, t_angle_tab[11] );
endmodule


