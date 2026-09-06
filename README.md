# 🎛️ Digital Audio Bit Crusher — RTL Implementation & Interactive Demo

A digital audio **Bit Crusher** processing unit implemented in synthesizable Verilog HDL, designed for a 5-member team for **Digital Systems & Computer Organization (Semester 3)**.

Includes:
1. **Synthesizable Verilog RTL** demonstrating core digital system concepts.
2. **Simulation Testbench** verified with Icarus Verilog (`iverilog`) and viewable in VS Code **WaveTrace**.
3. **Live Animated Web Audio Demo** (`viz/index.html`): Real-time interactive oscilloscope with audio playback, presets (synth, drums, sine), and custom `.wav` upload.

---

## 🧠 What is a Bit Crusher?

A Bit Crusher intentionally degrades digital audio to create an iconic retro, 8-bit, chiptune sound effect:
1. **Bit-Depth Reduction (Staircase Effect)**: Zeroes out least significant bits (LSBs) using a **Decoder + AND Gates**, collapsing continuous volume into coarse steps.
2. **Sample-Rate Reduction (Stepped Effect)**: Downsamples by holding audio samples over multiple clock periods using a **Modulo-N Counter + D Register**, lowering the Nyquist frequency.
3. **Gain & Saturation (Hard Clipping)**: Amplifies samples using an **Arithmetic Barrel Shifter** ($1\times, 2\times, 4\times, 8\times$), clamped by **Signed Comparators** to prevent two's complement wrap-around overflow.

---

## 🏛️ Architecture & 5-Member Team Allocation

```
[audio_source] ──► [bit_depth_reducer] ──► [sample_rate_reducer] ──► [gain_clipper] ──► crushed_out
   (Stage 0/1)           (Stage 2)                 (Stage 3)              (Stage 4/5)
```

| Member | File Owned | Core Digital Concepts | Role & Responsibility |
| :--- | :--- | :--- | :--- |
| **Person 1** | [`rtl/audio_source.v`](file:///Users/prithvirajgokule/MIT-Btech/SEM-3/Digital%20Systems/digital_bitcrusher/rtl/audio_source.v) | **Binary Up-Counter + Synchronous ROM** | Replaces external ADC; generates test sine wave from pre-computed memory lookup table. |
| **Person 2** | [`rtl/bit_depth_reducer.v`](file:///Users/prithvirajgokule/MIT-Btech/SEM-3/Digital%20Systems/digital_bitcrusher/rtl/bit_depth_reducer.v) | **Combinational Decoder + 16-bit AND Masking** | Translates 4-bit `bit_depth_sel` into a bitmask to zero out LSBs (amplitude quantization). |
| **Person 3** | [`rtl/sample_rate_reducer.v`](file:///Users/prithvirajgokule/MIT-Btech/SEM-3/Digital%20Systems/digital_bitcrusher/rtl/sample_rate_reducer.v) | **Modulo-N Counter + Clock-Enabled D-FF** | Emits enable pulse every $N$ cycles; holds sample across clocks (implicit 2-state Moore FSM). |
| **Person 4** | [`rtl/gain_clipper.v`](file:///Users/prithvirajgokule/MIT-Btech/SEM-3/Digital%20Systems/digital_bitcrusher/rtl/gain_clipper.v) | **Barrel Shifter + Signed Comparators** | Multiplier-less power-of-2 gain (`<<< drive_shift`) with saturation limits $[-32768, +32767]$. |
| **Person 5** | [`rtl/bitcrusher_top.v`](file:///Users/prithvirajgokule/MIT-Btech/SEM-3/Digital%20Systems/digital_bitcrusher/rtl/bitcrusher_top.v), [`tb/bitcrusher_tb.v`](file:///Users/prithvirajgokule/MIT-Btech/SEM-3/Digital%20Systems/digital_bitcrusher/tb/bitcrusher_tb.v) | **Structural Datapath + Verification** | Wires all modules; runs 5-stage simulation sweep; generates `bitcrusher.vcd` for WaveTrace. |

---

## 📁 Repository Structure

```
digital_bitcrusher/
├── rtl/                          ← Synthesizable Verilog Source Files
│   ├── audio_source.v            ← Person 1: ROM + Counter
│   ├── bit_depth_reducer.v       ← Person 2: Decoder + AND mask
│   ├── sample_rate_reducer.v     ← Person 3: Modulo-N + D-FF register
│   ├── gain_clipper.v            ← Person 4: Shifter + Comparators
│   └── bitcrusher_top.v          ← Person 5: Top datapath
├── tb/
│   ├── bitcrusher_tb.v           ← Testbench (5 config sweeps)
│   └── sine_rom.mem              ← 256-word 16-bit sine table
├── audio/                        ← Test Audio Samples
│   ├── synth_lead.wav            ← 80s arpeggiated synth lead
│   └── sine_tone.wav             ← Pure 440 Hz reference sine wave
├── viz/
│   └── index.html                ← Live animated oscilloscope web demo
├── run_sim.sh                    ← Automated compile & run script
├── convert_to_wav.py             ← Converts simulation output to .wav
└── README.md
```

---

## ⚡ Quick Start

### 1. Run Verilog Simulation (Terminal)
Requires `iverilog` installed on macOS (`brew install icarus-verilog`):
```bash
./run_sim.sh
```
Outputs generated:
* `bitcrusher.vcd` — Waveform dump for VS Code **WaveTrace**.
* `crushed_samples.txt` — Raw PCM sample values.

### 2. Inspect Waveforms in VS Code (WaveTrace)
1. In VS Code Explorer, click on `bitcrusher.vcd`.
2. Add the following probes to the timeline view:
   * `dut.raw_sample_dbg` (Original smooth sine wave)
   * `dut.quantized_sample_dbg` (Staircase bit-crushed wave)
   * `dut.held_sample_dbg` (Stepped time-domain downsampled wave)
   * `dut.crushed_out` (Final output with flat-top saturation clipping)

### 3. Open the Interactive Live Audio Web Demo
Simply double-click or open [`viz/index.html`](file:///Users/prithvirajgokule/MIT-Btech/SEM-3/Digital%20Systems/digital_bitcrusher/viz/index.html) in Chrome or Safari:
* Click **"Start Audio & Oscilloscope"** to hear live sound and watch the oscilloscope wave move!
* Switch between **Sine 440Hz**, **80s Synth Lead**, and **Drum Beat**, or **drag-and-drop any .wav file** from your Mac.
* Adjust the **Crush Depth** and **Downsample Factor** sliders to hear the audio degrade in real time and see the moving waves transform into staircase and blocky steps!

---

## 🎵 Why are there numbers in `crushed_samples.txt`?
Digital audio in computers and CDs is stored as a sequence of **PCM numbers**. In standard 16-bit audio, each number is an integer between **$-32768$** and **$+32767$**.
Our Verilog testbench logs each processed sample to `crushed_samples.txt`. 

To turn those numbers into a playable `.wav` file:
```bash
python3 convert_to_wav.py
```
This produces `bitcrusher_demo.wav`.
