`timescale 1ns/1ps

module bitcrusher_tb;
    reg clk = 0;
    reg rst_n = 0;
    reg [3:0] bit_depth_sel = 0;
    reg [7:0] hold_count = 1;
    reg [1:0] drive_shift = 0;
    wire signed [15:0] crushed_out;
    wire signed [15:0] raw_sample_dbg, quantized_sample_dbg, held_sample_dbg;
    wire sample_en_dbg;
    integer outfile;

    bitcrusher_top dut (
        .clk(clk), .rst_n(rst_n), .bit_depth_sel(bit_depth_sel),
        .hold_count(hold_count), .drive_shift(drive_shift),
        .crushed_out(crushed_out), .raw_sample_dbg(raw_sample_dbg),
        .quantized_sample_dbg(quantized_sample_dbg),
        .held_sample_dbg(held_sample_dbg), .sample_en_dbg(sample_en_dbg)
    );

    // Simulation runs quickly. WAV playback assigns 32768 samples/second.
    always #10 clk = ~clk;

    // Reuse the same procedure for each setting. Reset for a fair comparison.
    task run_demo;
        input [3:0] bits_removed;
        input [7:0] hold_cycles;
        input [1:0] gain_shift;
        integer i;
        begin
            @(negedge clk);
            rst_n = 0;
            bit_depth_sel = bits_removed;
            hold_count = hold_cycles;
            drive_shift = gain_shift;
            repeat (2) @(negedge clk);
            rst_n = 1;
            for (i = 0; i < 32768; i = i + 1) begin
                @(posedge clk);
                #1; // Let register updates and combinational logic settle.
                // Log EVERY clock, including held samples, to preserve timing.
                $fwrite(outfile, "%0d\n", $signed(crushed_out));
            end
        end
    endtask

    initial begin
        $dumpfile("bitcrusher.vcd");
        $dumpvars(0, bitcrusher_tb);
        outfile = $fopen("crushed_samples.txt", "w");
        if (outfile == 0) $fatal(1, "Cannot open sample output file");

        $display("1. Clean: remove 0 bits, hold 1, gain x1");
        run_demo(0, 1, 0);
        $display("2. Bit reduction: remove 12 bits, hold 1, gain x1");
        run_demo(12, 1, 0);
        $display("3. Sample holding: remove 0 bits, hold 16, gain x1");
        run_demo(0, 16, 0);
        $display("4. Clipping: remove 0 bits, hold 1, gain x4");
        run_demo(0, 1, 2);
        $display("5. Combined: remove 12 bits, hold 16, gain x2");
        run_demo(12, 16, 1);

        $fclose(outfile);
        $display("Demo finished. Run ./run_tests.sh to check correctness.");
        $finish;
    end
endmodule
