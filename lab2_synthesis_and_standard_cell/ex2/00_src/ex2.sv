module ex2(
	input logic [1:0] A,
	input logic [1:0] B,
	input logic [1:0] S,
	output logic [1:0] Y
);
always_comb begin
	case(S)
		2'b00: Y=A+B;
		2'b01: Y=A-B;
		2'b10: Y=A&B;
		2'b11: Y=A|B;
	endcase
end

endmodule



