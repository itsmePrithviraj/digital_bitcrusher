# Browser presentation demo

Open `index.html` in a browser and click **Start Audio & Oscilloscope**.
The page preserves live input/output waveforms, bit reduction and sample-hold
controls, gain, bypass, sine/synth/drum sources, and WAV upload.

Start with a sine wave and change one control at a time. The main README lists
the five presentation settings that correspond to the Verilog demo cases.

This page runs JavaScript; it does not execute the Verilog or read its output.
Use the VCD and automated tests for RTL verification. To hear the actual RTL
output, run `python3 convert_to_wav.py` after simulation and play the generated
`bitcrusher_demo.wav`.

The original example audio is in `audio/` at the project root. Regenerate it
with `python3 generate_sample_audio.py`.
