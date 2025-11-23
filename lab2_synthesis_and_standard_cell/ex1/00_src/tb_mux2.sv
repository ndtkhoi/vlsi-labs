`timescale 1ns/1ps
`ifdef GATE_LEVEL
  `include "./03_outputs/mux2/mux2_netlist_sl1v0h.sv"
  `include "./gpdk045_verilog/slow_vdd1v0_basicCells_hvt.v"
`else
  `include "./00_src/mux2.sv"
`endif

module tb_mux2;
    logic D0, D1, S;
    logic Y;

    mux2 DUT (.D0(D0), .D1(D1), .S(S), .Y(Y));

`ifdef ANNOTATION
    initial begin
        $sdf_annotate("./03_outputs/mux2/mux2_delay_sl1v0h.sdf", DUT, , "mux2_annotate.log", "MAXIMUM");
    end
`endif
    initial begin
        $dumpfile("mux2_wave_sl1v0h.vcd");
        $dumpvars(0, tb_alu.DUT);
    end

    // Kích thích đầu vào
    initial begin
        // Dạng test đơn giản: thử đủ 8 tổ hợp
        D0 = 0; D1 = 0; S = 0; #10;
        D0 = 0; D1 = 0; S = 1; #10;

        D0 = 0; D1 = 1; S = 0; #10;
        D0 = 0; D1 = 1; S = 1; #10;

        D0 = 1; D1 = 0; S = 0; #10;
        D0 = 1; D1 = 0; S = 1; #10;

        D0 = 1; D1 = 1; S = 0; #10;
        D0 = 1; D1 = 1; S = 1; #10;

        $finish;
    end
endmodule
