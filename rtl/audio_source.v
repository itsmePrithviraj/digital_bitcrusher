`timescale 1ns/1ps

// Member 1: an 8-bit counter reads a 256-sample sine wave repeatedly.
module audio_source (
    input wire clk,
    input wire rst_n,
    output reg [7:0] addr_out,
    output reg signed [15:0] sample_out
);
    reg [15:0] rom [0:255];

    initial $readmemh("sine_rom.mem", rom);

    // Active-low asynchronous reset. All registers start at known values.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_out <= 0;
            sample_out <= 0;
        end else begin
            sample_out <= rom[addr_out];
            addr_out <= addr_out + 1'b1; // 255 wraps to 0 automatically.
        end
    end
endmodule
