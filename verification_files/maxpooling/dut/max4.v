module max4(
    input  signed[15:0] i_0,
    input  signed[15:0] i_1,
    input  signed[15:0] i_2,
    input  signed[15:0] i_3,
    output signed[15:0] o_0
	);

wire signed[15:0] max1 = (i_0 > i_1) ? i_0 : i_1;
wire signed[15:0] max2 = (i_2 > i_3) ? i_2 : i_3;
assign o_0 = (max1 > max2) ? max1 : max2;
endmodule
