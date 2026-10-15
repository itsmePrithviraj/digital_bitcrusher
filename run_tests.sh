#!/bin/bash
set -eu
cd "$(dirname "$0")"
iverilog -g2012 -Wall -s blocks_tb -o tests/blocks.out \
  rtl/*.v tests/blocks_tb.v
vvp tests/blocks.out
./run_sim.sh
python3 tests/check_demo.py
