// ============================================================
// Module: sample_rate_reducer
// Team Member: Person 3
// Digital Concepts: MODULO-N COUNTER + CLOCK-ENABLED D REGISTER
// ============================================================
// Implements time-domain downsampling (sample-and-hold).
//
// Sub-components:
//   1. Modulo-N Counter (Rate Divider):
//      Counts clock cycles from 0 up to (hold_count - 1).
//      Emits a 1-clock-cycle 'sample_en' strobe every N cycles.
//
//   2. Clock-Enabled D Flip-Flop Register (Sample & Hold):
//      - When sample_en = 1: Latch incoming sample (LOAD state)
//      - When sample_en = 0: Retain previous value (HOLD state)
//
// Effect:
//   Holding samples across consecutive clock cycles produces a
//   stepped, blocky waveform, lowering the effective sample rate.
// ============================================================

module sample_rate_reducer #(
    parameter DATA_WIDTH  = 16,
    parameter COUNT_WIDTH = 8
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire [COUNT_WIDTH-1:0]        hold_count,  // Hold duration in clock cycles
    input  wire signed [DATA_WIDTH-1:0]  sample_in,
    output reg                           sample_en,   // Strobe output (high for 1 cycle)
    output reg  signed [DATA_WIDTH-1:0]  sample_out   // Latched/held output sample
);

    reg [COUNT_WIDTH-1:0] counter;

    // Modulo-N Counter with comparator
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= {COUNT_WIDTH{1'b0}};
            sample_en <= 1'b0;
        end else if (counter >= hold_count - 1'b1) begin
            counter   <= {COUNT_WIDTH{1'b0}};
            sample_en <= 1'b1;  // Strobe active for this cycle
        end else begin
            counter   <= counter + 1'b1;
            sample_en <= 1'b0;
        end
    end

    // Clock-enabled register: 2-state Moore FSM (LOAD / HOLD)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sample_out <= {DATA_WIDTH{1'b0}};
        else if (sample_en)
            sample_out <= sample_in;    // LOAD state
        // else: implicit HOLD state -- register preserves previous value
    end

endmodule
