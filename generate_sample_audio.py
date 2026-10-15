#!/usr/bin/env python3
"""
Generates sample WAV files for testing the bitcrusher demo:
1. audio/synth_lead.wav - An 80s arpeggiated synth melody
2. audio/sine_tone.wav  - A pure 440 Hz sine tone
"""

import math
import struct
import wave
import os
from pathlib import Path

os.chdir(Path(__file__).resolve().parent)

SAMPLE_RATE = 44100

def generate_wav(filename, duration, sample_generator):
    num_samples = int(SAMPLE_RATE * duration)
    with wave.open(filename, 'wb') as wav:
        wav.setnchannels(1)        # mono
        wav.setsampwidth(2)        # 16-bit
        wav.setframerate(SAMPLE_RATE)
        
        frames = bytearray()
        for i in range(num_samples):
            t = i / SAMPLE_RATE
            sample = sample_generator(t, i)
            # Clamp to 16-bit signed range
            sample = max(-32768, min(32767, int(sample)))
            frames.extend(struct.pack('<h', sample))
            
        wav.writeframes(frames)
    print(f"Generated: {filename} ({duration}s, {num_samples} samples)")

# 1. Pure sine tone (440 Hz A4)
def sine_gen(t, i):
    return 20000.0 * math.sin(2.0 * math.pi * 440.0 * t)

# 2. Retro Synth arpeggio (Am: A3, C4, E4, A4 arpeggio with slight vibrato)
def synth_gen(t, i):
    notes = [220.0, 261.63, 329.63, 440.0, 523.25, 440.0, 329.63, 261.63]
    note_idx = int(t * 4) % len(notes)
    freq = notes[note_idx]
    
    # Fundamental + 2nd + 3rd harmonic for rich synth sound
    val = (0.6 * math.sin(2.0 * math.pi * freq * t) +
           0.3 * math.sin(4.0 * math.pi * freq * t) +
           0.15 * math.sin(6.0 * math.pi * freq * t))
    
    # Slight envelope per note (attack-decay)
    note_t = (t * 4) % 1.0
    env = math.exp(-note_t * 2.0)
    return val * env * 24000.0

os.makedirs("audio", exist_ok=True)
generate_wav("audio/sine_tone.wav", 3.0, sine_gen)
generate_wav("audio/synth_lead.wav", 4.0, synth_gen)
