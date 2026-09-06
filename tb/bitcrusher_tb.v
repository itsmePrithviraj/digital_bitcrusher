`timescale 1ns/1ps

// ============================================================
// Testbench: bitcrusher_tb
// Team Member: Person 5
// ============================================================
// System verification testbench:
// Sweeps through 5 configurations to prove correct operation:
//   Config 1: Clean baseline passthrough (no crush)
//   Config 2: Bit depth crush (8 bits crushed -> staircase)
//   Config 3: Sample rate crush (hold for 8 cycles -> stepped)
//   Config 4: Combined crush with x4 drive gain
//   Config 5: Heavy crush with x8 drive gain (hard clipping active)
//
// Outputs:
//   - bitcrusher.vcd       : Waveform dump for VS Code WaveTrace
//   - crushed_samples.txt  : Output PCM values
// ============================================================

module bitcrusher_tb;

    reg                   clk;
    reg                   rst_n;
    reg  [3:0]            bit_depth_sel;
    reg  [7:0]            hold_count;
    reg  [1:0]            drive_shift;

    wire signed [15:0]    crushed_out;
    wire signed [15:0]    raw_sample_dbg;
    wire signed [15:0]    quantized_sample_dbg;
    wire signed [15:0]    held_sample_dbg;
    wire                  sample_en_dbg;

    integer outfile;

    // Instantiate Device Under Test (DUT)
    bitcrusher_top dut (
        .clk                  (clk),
        .rst_n                (rst_n),
        .bit_depth_sel        (bit_depth_sel),
        .hold_count           (hold_count),
        .drive_shift          (drive_shift),
        .crushed_out          (crushed_out),
        .raw_sample_dbg       (raw_sample_dbg),
        .quantized_sample_dbg (quantized_sample_dbg),
        .held_sample_dbg      (held_sample_dbg),
        .sample_en_dbg        (sample_en_dbg)
    );

    // 50 MHz simulation clock (20ns period)
    always #10 clk = ~clk;

    initial begin
        // Setup VCD waveform dump
        $dumpfile("bitcrusher.vcd");
        $dumpvars(0, bitcrusher_tb);

        clk           = 0;
        rst_n         = 0;
        bit_depth_sel = 0;
        hold_count    = 1;
        drive_shift   = 0;

        // Release reset after 25ns
        #25 rst_n = 1;

        // --- Config 1: Clean Baseline Passthrough ---
        $display("[Testbench] Config 1: Clean Baseline (bit_depth=0, hold=1, gain=x1)");
        bit_depth_sel = 0;  hold_count = 1;  drive_shift = 0;
        #5120;

        // --- Config 2: Bit Depth Crush Only ---
        $display("[Testbench] Config 2: Bit Depth Crush (bit_depth=8, hold=1, gain=x1)");
        bit_depth_sel = 8;  hold_count = 1;  drive_shift = 0;
        #5120;

        // --- Config 3: Sample Rate Crush Only ---
        $display("[Testbench] Config 3: Sample Rate Crush (bit_depth=0, hold=8, gain=x1)");
        bit_depth_sel = 0;  hold_count = 8;  drive_shift = 0;
        #5120;

        // --- Config 4: Combined Crush + x4 Gain ---
        $display("[Testbench] Config 4: Combined Crush (bit_depth=12, hold=16, gain=x4)");
        bit_depth_sel = 12; hold_count = 16; drive_shift = 2;
        #5120;

        // --- Config 5: Extreme Crush + x8 Gain (Clipping Active) ---
        $display("[Testbench] Config 5: Extreme Crush & Clipping (bit_depth=15, hold=32, gain=x8)");
        bit_depth_sel = 15; hold_count = 32; drive_shift = 3;
        #5120;

        $display("-------------------------------------------------------");
        $display("Simulation successfully completed!");
        $display("VCD output written to: bitcrusher.vcd (Open in WaveTrace)");
        $display("-------------------------------------------------------");
        $finish;
    end

    // Log valid newly-latched samples to text file
    initial outfile = $fopen("crushed_samples.txt", "w");

    always @(posedge sample_en_dbg) begin
        if (rst_n)
            $fwrite(outfile, "%0d\n", $signed(crushed_out));
    end

    initial begin
        #26000 $fclose(outfile);
    end

endmodule
