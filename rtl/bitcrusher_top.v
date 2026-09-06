// ============================================================
// Module: bitcrusher_top
// Team Member: Person 5
// Digital Concept: STRUCTURAL HIERARCHICAL DATAPATH
// ============================================================
// Top-level module interconnecting the complete bitcrusher pipeline:
//
// [audio_source] ──► [bit_depth_reducer] ──► [sample_rate_reducer] ──► [gain_clipper] ──► crushed_out
//   (Stage 0/1)           (Stage 2)                 (Stage 3)              (Stage 4/5)
//
// Control Inputs:
//   - bit_depth_sel[3:0] : Number of LSBs to zero out (0 to 15)
//   - hold_count[7:0]    : Sample-and-hold duration (1 to 255 clock cycles)
//   - drive_shift[1:0]   : Pre-clip gain factor (0=x1, 1=x2, 2=x4, 3=x8)
//
// Debug Outputs (for WaveTrace waveform viewer):
//   - raw_sample_dbg       : Clean un-crushed sine wave from ROM
//   - quantized_sample_dbg : Staircase wave after bit-depth reduction
//   - held_sample_dbg      : Stepped wave after sample-rate reduction
//   - sample_en_dbg        : Rate-divider clock enable strobe
// ============================================================

module bitcrusher_top #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 8
)(
    input  wire                          clk,
    input  wire                          rst_n,

    // Runtime controls
    input  wire [3:0]                    bit_depth_sel,
    input  wire [ADDR_WIDTH-1:0]         hold_count,
    input  wire [1:0]                    drive_shift,

    // Final crushed audio output
    output wire signed [DATA_WIDTH-1:0]  crushed_out,

    // WaveTrace debug observability taps
    output wire signed [DATA_WIDTH-1:0]  raw_sample_dbg,
    output wire signed [DATA_WIDTH-1:0]  quantized_sample_dbg,
    output wire signed [DATA_WIDTH-1:0]  held_sample_dbg,
    output wire                          sample_en_dbg
);

    // Internal inter-stage interconnect wires
    wire [ADDR_WIDTH-1:0]        rom_addr;
    wire signed [DATA_WIDTH-1:0] raw_sample;
    wire signed [DATA_WIDTH-1:0] quantized_sample;
    wire                         sample_en;
    wire signed [DATA_WIDTH-1:0] held_sample;
    wire signed [DATA_WIDTH-1:0] final_sample;

    // Connect internal probe taps to module debug outputs
    assign raw_sample_dbg       = raw_sample;
    assign quantized_sample_dbg = quantized_sample;
    assign held_sample_dbg      = held_sample;
    assign sample_en_dbg        = sample_en;
    assign crushed_out          = final_sample;

    // 1. Waveform Generator (Counter + ROM)
    audio_source #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_source (
        .clk        (clk),
        .rst_n      (rst_n),
        .addr_out   (rom_addr),
        .sample_out (raw_sample)
    );

    // 2. Bit-Depth Quantizer (Decoder + AND Mask)
    bit_depth_reducer #(
        .DATA_WIDTH (DATA_WIDTH)
    ) u_quantizer (
        .sample_in     (raw_sample),
        .bit_depth_sel (bit_depth_sel),
        .sample_out    (quantized_sample)
    );

    // 3. Sample-Rate Reducer (Modulo-N Counter + D Register)
    sample_rate_reducer #(
        .DATA_WIDTH  (DATA_WIDTH),
        .COUNT_WIDTH (ADDR_WIDTH)
    ) u_rate_reducer (
        .clk        (clk),
        .rst_n      (rst_n),
        .hold_count (hold_count),
        .sample_in  (quantized_sample),
        .sample_en  (sample_en),
        .sample_out (held_sample)
    );

    // 4. Gain Stage & Output Clipper (Shifter + Comparators)
    gain_clipper #(
        .DATA_WIDTH (DATA_WIDTH)
    ) u_gain_clipper (
        .sample_in   (held_sample),
        .drive_shift (drive_shift),
        .sample_out  (final_sample)
    );

endmodule
