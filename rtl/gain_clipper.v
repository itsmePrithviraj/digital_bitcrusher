// ============================================================
// Module: gain_clipper
// Team Member: Person 4
// Digital Concepts: ARITHMETIC BARREL SHIFTER + SIGNED COMPARATORS
// ============================================================
// Stage 1: Gain / Drive (Multiplier-less amplification)
//   - Sign-extends 16-bit input to 19 bits to prevent immediate overflow.
//   - Uses arithmetic left shift (<<< drive_shift) to multiply by
//     power-of-2: 0->x1, 1->x2, 2->x4, 3->x8.
//
// Stage 2: Output Clipper (Saturation Logic)
//   - Two signed magnitude comparators check if the amplified sample
//     exceeds 16-bit signed range [-32768, +32767].
//   - If sample > +32767: Clamp to +32767 (Flat ceiling)
//   - If sample < -32768: Clamp to -32768 (Flat floor)
//   - Otherwise: Pass through lower 16 bits.
//
// Why this matters:
//   Prevents catastrophic two's complement wrap-around (where a large
//   positive number wraps around into a loud negative glitch).
// ============================================================

module gain_clipper #(
    parameter DATA_WIDTH = 16,
    parameter EXT_WIDTH  = DATA_WIDTH + 3   // 19 bits headroom for up to x8 gain
)(
    input  wire signed [DATA_WIDTH-1:0] sample_in,
    input  wire [1:0]                   drive_shift,  // 0-3: 1x, 2x, 4x, 8x gain
    output reg  signed [DATA_WIDTH-1:0] sample_out
);

    // Maximum and minimum representable values in 16-bit signed format
    localparam signed [EXT_WIDTH-1:0] MAX_POS =  (1 <<< (DATA_WIDTH - 1)) - 1; // +32767
    localparam signed [EXT_WIDTH-1:0] MIN_NEG = -(1 <<< (DATA_WIDTH - 1));     // -32768

    // Sign extension + arithmetic left shift
    wire signed [EXT_WIDTH-1:0] extended_sample;
    wire signed [EXT_WIDTH-1:0] driven_sample;

    assign extended_sample = {{(EXT_WIDTH - DATA_WIDTH){sample_in[DATA_WIDTH-1]}}, sample_in};
    assign driven_sample   = extended_sample <<< drive_shift;

    // Signed Magnitude Comparators + Multiplexer
    always @(*) begin
        if (driven_sample > MAX_POS)
            sample_out = MAX_POS[DATA_WIDTH-1:0];      // Hard clip positive ceiling
        else if (driven_sample < MIN_NEG)
            sample_out = MIN_NEG[DATA_WIDTH-1:0];      // Hard clip negative floor
        else
            sample_out = driven_sample[DATA_WIDTH-1:0];// Normal range pass-through
    end

endmodule
