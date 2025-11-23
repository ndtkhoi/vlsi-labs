
module mux2 (
    input  logic D0,     // input 0
    input  logic D1,     // input 1
    input  logic S,      // select
    output logic Y       // output
);
    always_comb begin
        case (S)
            1'b0: Y = D0;
            1'b1: Y = D1;
            // default: Y = 1'b0; 
        endcase
    end
endmodule
