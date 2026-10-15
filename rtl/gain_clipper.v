`timescale 1ns/1ps

// Member 4: multiply by 1, 2, 4 or 8, then limit to the signed 16-bit range.
module gain_clipper (
    input wire signed [15:0] sample_in,
    input wire [1:0] drive_shift,
    output reg signed [15:0] sample_out
);
    wire signed [18:0] extended_sample;
    wire signed [18:0] amplified_sample;

    // Copy the sign bit into three extra bits BEFORE shifting.
    assign extended_sample = {{3{sample_in[15]}}, sample_in};
    assign amplified_sample = extended_sample <<< drive_shift;

    always @(*) begin
        if (amplified_sample > 19'sd32767)
            sample_out = 16'sh7FFF;
        else if (amplified_sample < -19'sd32768)
            sample_out = 16'sh8000;
        else
            sample_out = amplified_sample[15:0];
    end
endmodule
