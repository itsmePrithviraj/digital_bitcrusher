// ============================================================
// Module: bit_depth_reducer
// Team Member: Person 2
// Digital Concepts: COMBINATIONAL DECODER + 16-BIT AND MASKING
// ============================================================
// Reduces the amplitude resolution of a 16-bit audio sample.
//
// Operation:
//   1. Decoder: Translates 4-bit 'bit_depth_sel' (0 to 15) into
//      a 16-bit mask where the lowest N bits are forced to 0.
//   2. AND Gates: Performs bitwise AND (sample_in & mask).
//
// Effect:
//   Zeroing out the LSBs rounds fine variations into coarse
//   quantization steps, turning smooth waves into a "staircase".
//   - bit_depth_sel = 0  -> Mask = 0xFFFF (no crushing)
//   - bit_depth_sel = 8  -> Mask = 0xFF00 (8 bits crushed)
//   - bit_depth_sel = 15 -> Mask = 0x8000 (only sign bit survives)
// ============================================================

module bit_depth_reducer #(
    parameter DATA_WIDTH = 16
)(
    input  wire signed [DATA_WIDTH-1:0] sample_in,
    input  wire [3:0]                   bit_depth_sel,  // Number of LSBs to zero out
    output wire signed [DATA_WIDTH-1:0] sample_out
);

    reg [DATA_WIDTH-1:0] mask;
    integer i;

    // Combinational Decoder: maps select code to a per-bit mask
    always @(*) begin
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            mask[i] = (i < bit_depth_sel) ? 1'b0 : 1'b1;
        end
    end

    // 16 parallel AND gates perform the quantization
    assign sample_out = sample_in & mask;

endmodule
