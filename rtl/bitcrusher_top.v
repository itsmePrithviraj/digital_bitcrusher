`timescale 1ns/1ps

// Member 5: connect the four blocks and expose signals for the waveform.
module bitcrusher_top (
    input wire clk,
    input wire rst_n,
    input wire [3:0] bit_depth_sel,
    input wire [7:0] hold_count,
    input wire [1:0] drive_shift,
    output wire signed [15:0] crushed_out,
    output wire signed [15:0] raw_sample_dbg,
    output wire signed [15:0] quantized_sample_dbg,
    output wire signed [15:0] held_sample_dbg,
    output wire sample_en_dbg
);
    audio_source u_source (
        .clk(clk), .rst_n(rst_n), .addr_out(),
        .sample_out(raw_sample_dbg)
    );

    bit_depth_reducer u_quantizer (
        .sample_in(raw_sample_dbg), .bit_depth_sel(bit_depth_sel),
        .sample_out(quantized_sample_dbg)
    );

    sample_rate_reducer u_rate_reducer (
        .clk(clk), .rst_n(rst_n), .hold_count(hold_count),
        .sample_in(quantized_sample_dbg), .sample_en(sample_en_dbg),
        .sample_out(held_sample_dbg)
    );

    gain_clipper u_gain_clipper (
        .sample_in(held_sample_dbg), .drive_shift(drive_shift),
        .sample_out(crushed_out)
    );
endmodule
