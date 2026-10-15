#!/bin/bash
# ============================================================
# run_sim.sh — Compile and simulate the Bit Crusher (macOS)
# ============================================================
# Usage: ./run_sim.sh
# ============================================================

set -eu
cd "$(dirname "$0")"

echo "=== Step 1: Compiling RTL & Testbench with Icarus Verilog ==="
iverilog -g2012 -Wall -s bitcrusher_tb -o sim.out \
  rtl/audio_source.v \
  rtl/bit_depth_reducer.v \
  rtl/sample_rate_reducer.v \
  rtl/gain_clipper.v \
  rtl/bitcrusher_top.v \
  tb/bitcrusher_tb.v

echo "=== Step 2: Running Simulation with vvp ==="
vvp sim.out

echo ""
echo "=== Success! Generated Outputs ==="
echo "  1. bitcrusher.vcd       -> Open in VS Code using WaveTrace extension"
echo "  2. crushed_samples.txt  -> Raw PCM decimal values"
echo ""
echo "To convert simulation output into a playable audio file:"
echo "  python3 convert_to_wav.py"
