//////////////////////////////////////////////////////////////////////////////////
// Design Name: Pipeline cordic custom processor
// Module Name: mul_Kn
// Define the multiplication by constant Kn in blocks a14 – a18.
//////////////////////////////////////////////////////////////////////////////////
module mul_Kn(clock, ce, value_in, value_out, t_angle );
parameter integer W = 12; //Width of the fixed-point (12:10) representation
parameter FXP_SHIFT = 10; //Fraction for fixed-point (12:10) representation
input clock, ce;
input signed[W-1:0] value_in, t_angle;
output reg signed[W-1:0] value_out;
reg signed [2*W-1:0] val, val_0, val_2, val_4, val_5, val_7, val_7_9_d, val_9; //Shifted input values
reg signed [2*W-1:0] val_0_2, val_4_5, val_7_9, val_0_2_4_5, val_0_2_4_5_7_9; //Accumulated values
//
always @ (posedge clock)
begin
if( ce == 1'b1 )
begin
//Step S4
val = value_in; val_0 <= val; val_2 <= val << 2; val_4 <= val << 4;
val_5 <= val << 5; val_7 <= val << 7; val_9 <= val << 9;
//Step S5
val_0_2 <= val_0 - val_2; val_4_5 <= val_4 - val_5; val_7_9 <= val_7 + val_9;
//Step S6
val_0_2_4_5 <= val_0_2 + val_4_5;
val_7_9_d <= val_7_9; //delay val_7_9 which is necessary in the 4-th pipe stage
//Step S7
val_0_2_4_5_7_9 = val_0_2_4_5 + val_7_9_d;
//Step S8
//if (t_angle == 0)
//begin
//value_out <= value_in;
//end
//else
//begin
value_out <= val_0_2_4_5_7_9 >>> FXP_SHIFT;
//end
end
end
endmodule