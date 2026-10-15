`timescale 1ns/1ps

// Member 2: clear the lowest bit_depth_sel bits using an AND mask.
module bit_depth_reducer (
    input wire signed [15:0] sample_in,
    input wire [3:0] bit_depth_sel, // Bits REMOVED, not bits retained.
    output wire signed [15:0] sample_out
);
    wire [15:0] mask;

    // Example: remove 8 bits -> mask = 16'hFF00.
    assign mask = 16'hFFFF << bit_depth_sel;
    assign sample_out = sample_in & mask;
endmodule
