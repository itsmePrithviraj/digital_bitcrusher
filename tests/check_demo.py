"""Compare every logged RTL output with an independent arithmetic model."""
from pathlib import Path

root = Path(__file__).resolve().parents[1]
rom = [int(line, 16) for line in (root / "sine_rom.mem").read_text().splitlines()]
rom = [value if value < 32768 else value - 65536 for value in rom]
assert len(rom) == 256
actual = [int(line) for line in (root / "crushed_samples.txt").read_text().splitlines()]
settings = [(0, 1, 0), (12, 1, 0), (0, 16, 0), (0, 1, 2), (12, 16, 1)]
assert len(actual) == len(settings) * 32768, "Missing or extra output samples"

for case, (bits, hold, gain) in enumerate(settings):
    held = 0
    for cycle in range(32768):
        # Clocked source and holder use values from BEFORE the same edge.
        raw = 0 if cycle == 0 else rom[(cycle - 1) % 256]
        quantized = (raw // (2 ** bits)) * (2 ** bits)
        if (cycle + 1) % hold == 0:
            held = quantized
        expected = max(-32768, min(32767, held * (2 ** gain)))
        observed = actual[case * 32768 + cycle]
        assert observed == expected, (case + 1, cycle, observed, expected)
print("PASS: all 163,840 demo samples, including source wraparound and stage timing")
