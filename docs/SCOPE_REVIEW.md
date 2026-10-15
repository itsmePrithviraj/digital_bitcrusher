# Scope review: is this appropriate for five marks?

Yes, assuming simulation is accepted, as confirmed. Keep the bitcrusher idea:
it connects familiar Digital Systems topics to an observable result. It is a
reasonable small group project, not a guarantee of marks; the teacher's rubric
and your explanation still decide that.

## Decisions and reasons

| Original choice | Decision | Reason |
| --- | --- | --- |
| Counter and ROM source | Keep | Demonstrates addressing, memory and sequential logic without ADC hardware |
| Bit-depth reduction | Keep, shorten | A mask and AND operation explain the effect directly |
| Sample-rate reducer | Keep, correct timing | Counter plus holding register is a useful sequential circuit |
| Gain and clipping | Keep | Small circuit with a distinct signed-arithmetic role for member 4 |
| Configurable data/address widths | Remove | One fixed 16-bit/256-word design is easier to explain and verify |
| Five demo cases | Keep, separate effects | Each effect can be demonstrated alone before combining them |
| Browser UI, synth/drum presets, uploads | Keep in `viz/` for presentation | Makes the effect easy to show and hear; keep viva focus on the RTL |
| Two copies of the sine ROM | Keep only root copy | Avoid inconsistent data depending on the working directory |
| WAV export | Optional, fix logging | A small convenience, not the evidence of circuit correctness |
| “Implicit 2-state Moore FSM” wording | Remove | The circuit is more accurately explained as a counter and enabled register |

Why not remove gain? Bit reduction and holding already make a bitcrusher, but
clipping adds a useful, compact fifth-team-member workload when integration is
counted. It also provides a clear overflow example. It is the first feature to
drop if your teacher later demands a still smaller design.

Why not use 8-bit samples? That is also valid, but 16 bits keeps the existing
ROM and direct PCM export. The logic is the same; reducing the word width would
not remove a concept. Fixed widths remove more explanation overhead than
changing every sample to 8 bits.

Why not make it a real audio device? ADC/DAC interfaces, board clocks, codecs
and buffering would shift most effort away from the concepts being assessed.
They are outside this simulation mini-project.

## Correctness issues found and fixed

1. The original holder generated `sample_en` in one clocked block and read it
   in another. Nonblocking assignments meant the holder used the previous
   cycle's enable. Capture and its indicator now update together.
2. `hold_count=0` underflowed the old threshold. It now means the same as 1.
3. The source comment claimed synchronous reset while the counter used an
   asynchronous reset; its sample register had no reset. Both registers now
   have an explicitly documented asynchronous active-low reset.
4. The old logger watched rising edges of `sample_en`. For N=1 it stayed high,
   so almost all samples were missed; the original run produced only 57 lines.
   For other N values, logging only captures also loses hold duration in PCM.
   The new logger records after every active clock, including repeated values.
5. The old simulation announced success without checking expected results.
   Separate tests now check arithmetic, holding, reset and all demo outputs.
6. The old demo ran only 256 clocks per case and used an arbitrary WAV rate.
   Each case now contributes exactly one second at the stated playback rate.

## Boundaries for the presentation

Use the browser demo to show and hear each effect, then show the Verilog and
its VCD to explain the circuit. The browser has its own JavaScript signal
source, timing and audio engine; the automated tests verify the RTL separately.
Keep viva preparation focused on the digital blocks rather than browser APIs,
CSS, music synthesis or uploads.

Do not claim a CPU, instruction set, a separate FSM controller, or a hardware
build. “A digital audio effect implemented as a Verilog datapath and verified
in simulation” is accurate and sufficient.
