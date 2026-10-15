`timescale 1ns/1ps

// Member 3: capture one sample every N clocks; hold it between captures.
module sample_rate_reducer (
    input wire clk,
    input wire rst_n,
    input wire [7:0] hold_count,
    input wire signed [15:0] sample_in,
    output reg sample_en, // Reports a capture on the most recent edge.
    output reg signed [15:0] sample_out
);
    reg [7:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            sample_en <= 0;
            sample_out <= 0;
        end else if (hold_count <= 1 || counter >= hold_count - 1'b1) begin
            // Treat N=0 as N=1. Capture and flag update on the SAME edge.
            counter <= 0;
            sample_en <= 1;
            sample_out <= sample_in;
        end else begin
            counter <= counter + 1'b1;
            sample_en <= 0;
            // No assignment to sample_out: the register holds its value.
        end
    end
endmodule
