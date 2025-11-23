`timescale 1ns/1ps

// Nếu chạy gate-level (sau synthesis) define GATE_LEVEL và ANNOTATION khi sim
`ifdef GATE_LEVEL
 `include "/home/yellow/ee3201_19/Desktop/LAB2/ex3/03_outputs/slow_vdd1v2_lvt/netlist.sv"							//kiem tra khi doi lib
 `include "/home/yellow/ee3201_19/Desktop/LAB2/PDK45nm/gpdk045_verilog/slow_vdd1v2_basicCells_lvt.v"			//kiem tra khi doi lib
`else
 `include "/home/yellow/ee3201_19/Desktop/LAB2/ex3/00_src/dff.sv"
`endif

module tb_dff;

  // tín hiệu testbench
  logic i_clk;
  logic i_d;
  logic o_q;

  // instantiate DUT
  dff DUT (
    .i_d(i_d),
    .i_clk(i_clk),
    .o_q(o_q)
  );

`ifdef ANNOTATION
  initial begin
    // back-annotate SDF
    $sdf_annotate("/home/yellow/ee3201_19/Desktop/LAB2/ex3/03_outputs/slow_vdd1v2_lvt/delay.sdf", DUT, , "annotate.log", "MAXIMUM");	//kiem tra khi doi lib
  end
`endif

  // VCD waveform
  initial begin
	 $dumpfile("dff_wave.vcd");	
    $dumpfile("/home/yellow/ee3201_19/Desktop/LAB2/ex3/03_outputs/slow_vdd1v2_lvt/dff_wave.vcd");					//kiem tra khi doi lib
    $dumpvars(0, tb_dff.DUT);
  end

  // clock generation: period = 10 ns (100 MHz)
  initial i_clk = 1'b0;
  always #5 i_clk = ~i_clk;

  // ---------------------------
  // STIMULUS (KHÔNG CHỨA $...)
  // ---------------------------
  initial begin
    // --- ensure all inputs/outputs are defined before first case
    i_d = 1'b1;          // initialize input -> ensures o_q will be defined after a few clocks

    // wait several positive edges so Q is driven and not X anymore
    repeat (5) @(posedge i_clk);

    // ============= Case 1: reset behavior (D=0 -> Q should be 0 after posedge) ============
    #2
    i_d = 1'b0;
    // wait two clock cycles to observe stable reset behavior
    @(posedge i_clk);
    @(posedge i_clk);

    // ============= Case 2: set behavior (D=1 -> Q should be 1 after posedge) ============
    #2
    i_d = 1'b1;
    // wait two clock cycles to observe set behavior
    @(posedge i_clk);
    @(posedge i_clk);
    #2

    // ============= Case 3: setup tests ============
    // 3a: SETUP (posedge D before posedge CK) -- 0 -> 1 shortly BEFORE clock edge
    i_d = 1'b0;            // prepare for 0->1 transition
    @(negedge i_clk);      // reference: posedge in ~5 ns
    #4.995;                 // ~10 ps before next posedge (timescale 1ns/1ps)
    i_d = 1'b1;            // 0->1 near posedge (tests SETUP (posedge D) ...)
    @(posedge i_clk);      // let the posedge pass
    @(posedge i_clk);      // small settle
    #2

    // 3b: SETUP (negedge D before posedge CK) -- 1 -> 0 shortly BEFORE clock edge
    i_d = 1'b1;            // prepare for 1->0 transition
    @(negedge i_clk);
    #4.995;                 // ~10 ps before posedge
    i_d = 1'b0;            // 1->0 near posedge (tests SETUP (negedge D) ...)
    @(posedge i_clk);
    @(posedge i_clk);
    #2

    // ============= Case 4: hold tests ============
    // 4a: HOLD (posedge D after posedge CK) -- 0 -> 1 shortly AFTER clock edge
    i_d = 1'b0;
    @(posedge i_clk);
    #0.001;                // 1 ps after posedge
    i_d = 1'b1;            // change immediately after posedge (tests HOLD (posedge D) ...)
    @(posedge i_clk);
    @(posedge i_clk);
    #2

    // 4b: HOLD (negedge D after posedge CK) -- 1 -> 0 shortly AFTER clock edge
    i_d = 1'b1;
    @(posedge i_clk);
    #0.001;                // 1 ps after posedge
    i_d = 1'b0;            // change immediately after posedge (tests HOLD (negedge D) ...)
    @(posedge i_clk);
    @(posedge i_clk);
    #2

    // extra cycles to observe final behaviour
    i_d = 1'b1;
    @(posedge i_clk);
    @(posedge i_clk);

    $finish;
  end

endmodule
