module dff (
	input logic i_d,
	input logic i_clk,
	output logic o_q
);
	always_ff @(posedge i_clk)
		o_q <= i_d;
endmodule
