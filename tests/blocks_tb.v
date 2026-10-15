`timescale 1ns/1ps

// Verification support: separate from the short presentation testbench.
module blocks_tb;
    reg signed [15:0] sample_in = 0;
    reg [3:0] bits_removed = 0;
    reg [1:0] gain_shift = 0;
    wire signed [15:0] quantized, clipped, held;
    reg clk = 0;
    reg rst_n = 0;
    reg [7:0] hold_count = 1;
    wire captured;
    integer value, setting, step_size, expected;

    bit_depth_reducer quantizer(sample_in, bits_removed, quantized);
    gain_clipper clipper(sample_in, gain_shift, clipped);
    sample_rate_reducer holder(clk, rst_n, hold_count, sample_in, captured, held);
    always #5 clk = ~clk;

    // Check capture timing and held values across three complete periods.
    task check_hold;
        input integer requested;
        integer period, cycle, last_sample;
        begin
            @(negedge clk);
            rst_n = 0;
            hold_count = requested;
            #1;
            if (held !== 0 || captured !== 0) $fatal(1, "Reset failed");
            @(negedge clk);
            rst_n = 1;
            period = requested < 1 ? 1 : requested;
            last_sample = 0;
            for (cycle = 1; cycle <= 3 * period; cycle = cycle + 1) begin
                sample_in = cycle - 400;
                @(posedge clk);
                #1;
                if (cycle % period == 0) last_sample = cycle - 400;
                if (held !== last_sample || captured !== (cycle % period == 0))
                    $fatal(1, "Hold failed: N=%0d cycle=%0d", requested, cycle);
                @(negedge clk);
            end
        end
    endtask

    initial begin
        // All signed 16-bit inputs, at all 16 bit-removal settings.
        // Independent arithmetic reference: round DOWN to a multiple of 2^k.
        for (setting = 0; setting < 16; setting = setting + 1) begin
            bits_removed = setting;
            step_size = 1 << setting;
            for (value = -32768; value <= 32767; value = value + 1) begin
                sample_in = value;
                expected = value >= 0 ? (value / step_size) * step_size
                    : -((-value + step_size - 1) / step_size) * step_size;
                #1;
                if (quantized !== expected)
                    $fatal(1, "Quantization failed: input=%0d bits=%0d", value, setting);
            end
        end
        $display("PASS: all 1,048,576 quantizer cases");

        // All signed inputs and gains: catches overflow and boundary mistakes.
        for (setting = 0; setting < 4; setting = setting + 1) begin
            gain_shift = setting;
            for (value = -32768; value <= 32767; value = value + 1) begin
                sample_in = value;
                expected = value * (1 << setting);
                if (expected > 32767) expected = 32767;
                if (expected < -32768) expected = -32768;
                #1;
                if (clipped !== expected)
                    $fatal(1, "Clipping failed: input=%0d gain=%0d", value, setting);
            end
        end
        $display("PASS: all 262,144 gain/clipping cases");

        check_hold(0);
        check_hold(1);
        check_hold(4);
        check_hold(255);

        // Decrease N without reset: capture on the next edge if already due.
        hold_count = 16;
        repeat (8) @(negedge clk);
        hold_count = 2;
        sample_in = 1234;
        @(posedge clk);
        #1;
        if (held !== 16'sd1234 || captured !== 1'b1)
            $fatal(1, "Changing hold_count failed");
        $display("PASS: reset, capture alignment, holding, N=0/1/4/255, live N change");
        $finish;
    end
endmodule
