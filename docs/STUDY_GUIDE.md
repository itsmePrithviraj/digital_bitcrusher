# Understand the project and prepare for the viva

## The project in two sentences

Digital audio is a sequence of numbers representing signal amplitude. Our
Verilog circuit intentionally makes those numbers less precise, updates them
less often, and optionally amplifies/clips them to create a distorted effect.

## Follow one sample

Consider the incoming sample **12345**, with **8 bits removed**, **hold N=4**,
and **gain ×4**:

1. ROM supplies the stored signed sample.
2. Mask: `12345 = 0x3039`; `0x3039 & 0xFF00 = 0x3000 = 12288`.
3. The holding register captures 12288 when its counter reaches 3. Until the
   next capture four clocks later, it keeps that value even if the input changes.
4. Gain: `12288 × 4 = 49152`.
5. Clip: 49152 exceeds 32767, so the output becomes **32767**.

These operations affect two different things: masking changes amplitude
precision, while holding changes how often a fresh value is used.

## 1. ROM source: memory and counting

`audio_source.v` stores 256 samples describing one sine-wave cycle. An 8-bit
address counter visits 0 through 255 and wraps to 0. Each positive clock edge
reads the old address and increments the counter using nonblocking assignments.

`$readmemh` loads hexadecimal bit patterns from `sine_rom.mem`. Python only
prepares this data; Python does not run inside the Verilog circuit. You do not
need to memorise the 256 values. Know why 8 address bits select 256 locations.

Reset is active-low and asynchronous: asserting `rst_n=0` clears the source
registers without waiting for a clock edge. The supplied simulation releases
reset on a falling edge, away from the active rising edge.

## 2. Bit reduction: precision and masking

A signed 16-bit sample ranges from −32768 to +32767. Bit 15 is the sign bit in
two's complement; the LSB represents the smallest step in amplitude.

`bit_depth_sel` is the number of low bits removed. Removing k bits gives step
size `2^k` and `16-k` effective bits, while the bus still has 16 wires.

| Bits removed | Mask | Step size | Effective bits |
| ---: | --- | ---: | ---: |
| 0 | FFFF | 1 | 16 |
| 4 | FFF0 | 16 | 12 |
| 8 | FF00 | 256 | 8 |
| 12 | F000 | 4096 | 4 |

Masking rounds **down**, not to the nearest number or toward zero. Example:
`-12345 = 0xCFC7`; AND with `0xFF00` gives `0xCF00 = -12544`.
This negative example is useful in the viva.

The bit mask is combinational logic. Its output changes when its input or
control changes; it does not wait for a clock. The variable shift describes a
mask-selection circuit; a literal, separately instantiated decoder is not required.

## 3. Sample holding: counter and register

For N=4, the counter follows 0, 1, 2, 3, 0, … . On the edge where its old value
is 3, the circuit captures the input and clears the counter.

| Active edge after reset | Input just before edge | Output after edge | Capture flag |
| ---: | ---: | ---: | ---: |
| 1 | 100 | 0 | 0 |
| 2 | 200 | 0 | 0 |
| 3 | 300 | 0 | 0 |
| 4 | 400 | 400 | 1 |
| 5 | 500 | 400 | 0 |
| 6 | 600 | 400 | 0 |
| 7 | 700 | 400 | 0 |
| 8 | 800 | 800 | 1 |

For N=1, it captures every edge and the flag stays high on consecutive cycles.
N=0 is deliberately treated as 1. Changing N does not reset the counter: a
smaller threshold already reached causes capture on the next edge; increasing
N extends the current interval. The demo resets between configurations to
make comparisons easy.

There is one clock throughout. We change the **register enable**, not the clock
frequency. Output numbers still exist every clock; held values repeat. If the
base sample rate is Fs, the effective fresh-sample rate is Fs/N. This simple
sample selection can cause aliasing because there is no anti-alias filter;
intentional distortion is acceptable for this effect.

No separate LOAD/HOLD FSM is needed: a counter and an enabled register fully
explain the implementation.

## 4. Gain and clipping: signed arithmetic

Shifting left by 0, 1, 2, or 3 multiplies an integer by 1, 2, 4, or 8. We extend
the input from 16 to 19 bits before shifting; three extra bits hold the largest
allowed gain without losing the result. Sign extension repeats the sign bit,
so negative values stay negative.

Then compare the wide result against the signed limits:

- `1000 × 4 = 4000`: pass through.
- `10000 × 4 = 40000`: clip to 32767.
- `-10000 × 4 = -40000`: clip to −32768.

A 16-bit shift alone could overflow before the comparison. Signed comparisons
matter: unsigned logic would interpret a negative bit pattern as positive.
This block is combinational. Clipping limits the numeric output, and creates
flat waveform peaks; it is not a speaker protection system.

## 5. Integration and simulation timing

The top module only connects blocks. ROM and hold registers are sequential;
masking and clipping are combinational. Debug outputs expose intermediate
values so you can explain where each change occurs.

In a clocked block, `<=` schedules a register update. On the same edge, the ROM
and holding register both read their inputs as they existed **before** that
edge. Therefore, with N=1, the holder takes the previous ROM output; the clean
output has one clock of latency relative to `raw_sample_dbg`. Clean means the
sample values are preserved, not that both signals are identical at every instant.

In combinational `always @(*)` blocks, `=` calculates the result immediately.
Every branch assigns the clipping output, so no storage latch is requested.
Omitting an assignment in a clocked block intentionally retains a register.

The testbench uses `#1` after each rising edge before logging. This lets the
register updates and downstream logic settle. It writes every sample,
including repeats; logging only captures would incorrectly shorten held
sections when converted to audio.

The simulation clock has a 20 ns period. Exporting those numbers at 32768 Hz
is a separate choice of playback time scale. With 256 samples per waveform
cycle, playback frequency is `32768 / 256 = 128 Hz`. The combined WAV contains
five one-second cases; it is optional, and transitions may click.

## A short demonstration

Open `viz/index.html` for the live audio and input/output waveform display.
Use its controls for the five cases below; keep the Verilog VCD ready to show
internal signals and capture timing. The browser illustrates the effect, while
the generated `bitcrusher_demo.wav` contains the actual RTL simulation output.

1. **20 seconds:** state the problem and draw the four-block signal path.
2. **40 seconds:** show clean versus bit reduction; work the 12345 mask example.
3. **40 seconds:** show N=16 holding and the capture flag; explain the counter.
4. **30 seconds:** show flat clipped peaks; explain the wider shift and limits.
5. **30 seconds:** show the combined case and passing tests; state simulation limits.

Use signed waveform display. Zoom into a few cycles rather than the full
five-case run. Each member should explain their block and one example; everyone
should be able to describe the whole path. Adjust timing to your teacher's limit.

## Likely viva questions

| Question | Concise answer |
| --- | --- |
| Why is it called a bitcrusher? | It deliberately reduces amplitude resolution; this version also holds samples and clips them. |
| Why use a ROM? | It supplies a repeatable digital input without needing an ADC. |
| Why an 8-bit counter? | 2^8 = 256 ROM locations. |
| Does removing 12 bits create a 4-bit output bus? | No; 4 bits of effective precision remain on a 16-bit bus. |
| Does masking change pitch? | It changes waveform shape and adds distortion; the source's repetition period stays the same. |
| Does holding slow the clock? | No; it captures a fresh value less often on the same clock. |
| Is holding just reducing volume? | No; it changes temporal sampling, not simply amplitude. |
| What is clipping? | Limiting values outside the signed range to the nearest endpoint. |
| Why 19 bits internally? | A 16-bit signed number multiplied by up to 8 needs three extra bits. |
| Why nonblocking assignments? | They model simultaneous register updates from old values on a clock edge. |
| How do you know it works? | Directed holding checks, exhaustive arithmetic checks, and comparison of every demo output with a reference calculation. |
| Is the browser demo running Verilog? | No. It is a JavaScript model used for the interactive presentation. |
| What is not implemented? | ADC/DAC, physical audio interfaces, filters and FPGA board integration. |

## Small report outline

Use the provided Word template if required. A compact report should contain:
objective; block diagram; module/concept table; control settings; selected code;
waveform screenshots of the isolated effects; actual test results; team
contributions; conclusion and limitations. Record real screenshots and member
names. You do not need a long DSP theory section or browser implementation details.
