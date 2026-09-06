// ============================================================
// Module: audio_source
// Team Member: Person 1
// Digital Concepts: BINARY COUNTER + SYNCHRONOUS ROM
// ============================================================
// Simulates an audio input by continuously generating a digital
// sine wave from a pre-computed lookup table (ROM).
//
// Sub-components:
//   1. 8-bit Synchronous Binary Up-Counter: Increments address 0->255
//   2. 256x16-bit ROM Array: Stores 16-bit signed PCM samples
// ============================================================

module audio_source #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 8
)(
    input  wire                          clk,
    input  wire                          rst_n,      // Active-low synchronous reset
    output reg  [ADDR_WIDTH-1:0]         addr_out,   // Current ROM address
    output reg  signed [DATA_WIDTH-1:0]  sample_out  // Output audio sample
);

    // Memory array for the sine lookup table
    reg [DATA_WIDTH-1:0] rom [0:(1 << ADDR_WIDTH)-1];

    // Initialize ROM contents from hex file at startup
    initial begin
        $readmemh("sine_rom.mem", rom);
    end

    // Address Counter: counts from 0 to 255 and wraps around
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            addr_out <= {ADDR_WIDTH{1'b0}};
        else
            addr_out <= addr_out + 1'b1;
    end

    // Synchronous ROM Read: fetch sample at current address
    always @(posedge clk) begin
        sample_out <= rom[addr_out];
    end

endmodule
