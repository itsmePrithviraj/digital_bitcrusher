"""
gen_sine_table.py
------------------
Generates sine_rom.mem: a 256-entry, 16-bit signed lookup table of one
full sine-wave cycle, in hex, one value per line -- the format $readmemh
expects.

This ROM stands in for "real" digital audio input. In a real product the
crusher would sit after an ADC or a digital audio stream; here, a
synthetic waveform lets the whole design be simulated with no external
hardware, while still being a legitimate multi-bit digital signal.

Run this once before simulating:
    python3 gen_sine_table.py
"""

import math
from pathlib import Path

DEPTH = 256                        # samples per cycle (ROM address width = 8 bits)
WIDTH = 16                         # bits per sample (signed two's complement)
AMPLITUDE = (1 << (WIDTH - 1)) - 1  # 32767 -> use full positive range, headroom for negative min

OUT_FILE = Path(__file__).resolve().parent / "sine_rom.mem"

def main():
    with open(OUT_FILE, "w") as f:
        for n in range(DEPTH):
            val = int(round(AMPLITUDE * math.sin(2 * math.pi * n / DEPTH)))
            if val < 0:
                val += (1 << WIDTH)          # convert to two's complement bit pattern
            f.write(f"{val:04x}\n")
    print(f"Wrote {DEPTH} x {WIDTH}-bit samples to {OUT_FILE}")

if __name__ == "__main__":
    main()
