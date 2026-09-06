"""
convert_to_wav.py
------------------
Optional stretch goal: turns the testbench's crushed_samples.txt (one
signed decimal 16-bit sample per line) into a real, playable .wav file,
so the crushed audio can be *heard* during evaluation, not just read off
a waveform plot.

Run after simulating:
    python3 convert_to_wav.py
"""

import wave
import struct

IN_FILE  = "crushed_samples.txt"
OUT_FILE = "bitcrusher_demo.wav"
SAMPLE_RATE = 8000   # arbitrary demo playback rate (samples/sec)

def main():
    with open(IN_FILE) as f:
        samples = [int(line.strip()) for line in f if line.strip()]

    with wave.open(OUT_FILE, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)          # 16-bit PCM
        wf.setframerate(SAMPLE_RATE)
        frames = b"".join(struct.pack("<h", s) for s in samples)
        wf.writeframes(frames)

    print(f"Wrote {len(samples)} samples ({len(samples)/SAMPLE_RATE:.2f}s) to {OUT_FILE}")

if __name__ == "__main__":
    main()
