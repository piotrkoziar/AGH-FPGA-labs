//////////////////////////////////////////////////////////////////////////////////
// Design Name: Pipeline cordic custom processor
// Module Name: cordic_step
// Define the cordic step in blocks a2 - a13
//////////////////////////////////////////////////////////////////////////////////
module cordic_step ( clock, ce, sin_in, cos_in, angle_in, t_angle, atan,
sin_out, cos_out, angle_out, t_angle_out );
parameter integer step = 0; //Step number
parameter integer W = 12; //Width for fixed-point representation. Fixpoint(12:10)
input clock, ce;
input signed [W-1:0] sin_in, cos_in, angle_in, t_angle, atan;
output reg signed [W-1:0] sin_out, cos_out, angle_out, t_angle_out;
//
always @ (posedge clock)
begin
if( ce == 1'b1 )
begin
if(t_angle >= angle_in)
begin
cos_out <= cos_in - (sin_in >>> step);
sin_out <= ((cos_in >>> step) + sin_in);
angle_out <= angle_in + atan;
end
else if (t_angle < angle_in)
begin
cos_out <= cos_in + (sin_in >>> step);
sin_out <= -(cos_in >>> step) + sin_in;
angle_out <= angle_in - atan;
end
//else
//begin
//cos_out <= cos_in;
//sin_out <= sin_in;
//angle_out <= angle_in;
//end
t_angle_out <= t_angle;
end //if ( ce == 1'b1 )
end
endmodule