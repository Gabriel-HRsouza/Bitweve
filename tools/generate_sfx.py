import wave
import math
import struct
import os

SAMPLE_RATE = 44100

def create_wave(filename, duration, sample_generator):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    n_samples = int(SAMPLE_RATE * duration)
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1)        # mono
        wav.setsampwidth(2)       # 16-bit
        wav.setframerate(SAMPLE_RATE)
        
        frames = bytearray()
        for i in range(n_samples):
            t = i / SAMPLE_RATE
            progress = i / n_samples
            val = sample_generator(t, progress, duration)
            # clamp to -1.0 to 1.0
            val = max(-1.0, min(1.0, val))
            sample = int(val * 32767.0)
            frames.extend(struct.pack('<h', sample))
            
        wav.writeframes(frames)
    print(f"Generated {filename} ({duration:.2f}s, {len(frames)} bytes)")

# 1. button_tap.wav: crisp, snappy 40ms tactile pop
def gen_tap(t, p, d):
    # frequency sweeps from 900Hz to 250Hz quickly with fast decay
    freq = 900.0 * math.exp(-t * 70.0) + 200.0
    phase = 2 * math.pi * freq * t
    env = math.exp(-p * 18.0)
    # add small click transient in first 3ms
    click = (1.0 - p * 20.0) if p < 0.05 else 0.0
    return (0.8 * math.sin(phase) + 0.2 * click) * env * 0.7

# 2. age_up.wav: dynamic 350ms ascending triumphant whoosh chime (C5 -> E5 -> G5 -> C6)
def gen_age_up(t, p, d):
    # Ascending notes: C5 (523Hz), E5 (659Hz), G5 (784Hz), C6 (1046Hz)
    sub = math.sin(2 * math.pi * 180 * t) * math.exp(-p * 6) * 0.3
    n1 = math.sin(2 * math.pi * 523.25 * t) * (1.0 if t > 0.0 else 0) * math.exp(-max(0, t - 0.0) * 12)
    n2 = math.sin(2 * math.pi * 659.25 * t) * (1.0 if t > 0.06 else 0) * math.exp(-max(0, t - 0.06) * 10)
    n3 = math.sin(2 * math.pi * 783.99 * t) * (1.0 if t > 0.12 else 0) * math.exp(-max(0, t - 0.12) * 8)
    n4 = (math.sin(2 * math.pi * 1046.50 * t) + 0.3 * math.sin(2 * math.pi * 2093.0 * t)) * (1.0 if t > 0.18 else 0) * math.exp(-max(0, t - 0.18) * 6)
    
    val = sub + 0.4 * n1 + 0.5 * n2 + 0.6 * n3 + 0.8 * n4
    env = (1.0 - p) ** 0.5 if p < 0.9 else (1.0 - p) * 10
    return val * env * 0.75

# 3. positive_event.wav: bright 220ms melodic sparkle
def gen_positive(t, p, d):
    f1 = 784.0 # G5
    f2 = 1046.5 # C6
    f3 = 1318.5 # E6
    w1 = math.sin(2 * math.pi * f1 * t) * math.exp(-t * 14)
    w2 = math.sin(2 * math.pi * f2 * t) * (1.0 if t > 0.05 else 0) * math.exp(-max(0, t - 0.05) * 12)
    w3 = math.sin(2 * math.pi * f3 * t) * (1.0 if t > 0.10 else 0) * math.exp(-max(0, t - 0.10) * 10)
    return (w1 * 0.4 + w2 * 0.5 + w3 * 0.6) * 0.7

# 4. negative_event.wav: low dissonant 280ms tone
def gen_negative(t, p, d):
    f1 = 220.0 # A3
    f2 = 233.08 # Bb3 (minor second dissonance)
    w = 0.5 * math.sin(2 * math.pi * f1 * t) + 0.5 * math.sin(2 * math.pi * f2 * t)
    env = math.exp(-p * 7)
    return w * env * 0.65

# 5. achievement.wav: sparkling 600ms fanfare
def gen_achievement(t, p, d):
    notes = [
        (0.00, 523.25),  # C5
        (0.08, 659.25),  # E5
        (0.16, 783.99),  # G5
        (0.24, 1046.50), # C6
        (0.32, 1318.51), # E6
        (0.40, 1567.98), # G6
    ]
    tot = 0.0
    for start_t, freq in notes:
        if t >= start_t:
            dt = t - start_t
            harm = math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(2 * math.pi * freq * 2 * t)
            tot += harm * math.exp(-dt * 7.0) * 0.35
    return tot * 0.8

# 6. screen_transition.wav: soft air glide 80ms
def gen_screen_trans(t, p, d):
    freq = 300.0 + 400.0 * math.sin(p * math.pi)
    val = math.sin(2 * math.pi * freq * t)
    env = math.sin(p * math.pi)
    return val * env * 0.35

# 7. money_gain.wav: cheerful coin clink (1975Hz + 2637Hz) 200ms
def gen_money_gain(t, p, d):
    # Two distinct metallic bell ring hits
    h1 = (math.sin(2 * math.pi * 1975.5 * t) + 0.4 * math.sin(2 * math.pi * 3951.0 * t)) * math.exp(-t * 22)
    h2 = 0.0
    if t > 0.06:
        dt = t - 0.06
        h2 = (math.sin(2 * math.pi * 2637.0 * t) + 0.4 * math.sin(2 * math.pi * 5274.0 * t)) * math.exp(-dt * 18)
    return (h1 * 0.5 + h2 * 0.7) * 0.65

# 8. money_loss.wav: 160ms subtle sliding drop
def gen_money_loss(t, p, d):
    freq = 450.0 - 250.0 * p
    val = math.sin(2 * math.pi * freq * t)
    env = math.exp(-p * 12)
    return val * env * 0.5

# 9. lottery_win.wav: 800ms casino jackpot cascade!
def gen_lottery_win(t, p, d):
    # Multi-chime cascade
    pitches = [659, 784, 987, 1318, 1568, 1975, 2637]
    tot = 0.0
    for idx, f in enumerate(pitches):
        start = idx * 0.08
        if t >= start:
            dt = t - start
            sound = math.sin(2 * math.pi * f * t) + 0.25 * math.sin(2 * math.pi * f * 2 * t)
            tot += sound * math.exp(-dt * 6.0) * 0.35
    return tot * 0.8

# 10. death.wav: 800ms solemn bell
def gen_death(t, p, d):
    f1 = 110.0 # A2
    f2 = 146.83 # D3
    f3 = 174.61 # F3 (minor)
    w = 0.5 * math.sin(2 * math.pi * f1 * t) + 0.3 * math.sin(2 * math.pi * f2 * t) + 0.2 * math.sin(2 * math.pi * f3 * t)
    env = math.exp(-p * 4.5)
    return w * env * 0.7

output_dir = "assets/audio"
create_wave(os.path.join(output_dir, "button_tap.wav"), 0.045, gen_tap)
create_wave(os.path.join(output_dir, "age_up.wav"), 0.35, gen_age_up)
create_wave(os.path.join(output_dir, "positive_event.wav"), 0.24, gen_positive)
create_wave(os.path.join(output_dir, "negative_event.wav"), 0.28, gen_negative)
create_wave(os.path.join(output_dir, "achievement.wav"), 0.65, gen_achievement)
create_wave(os.path.join(output_dir, "screen_transition.wav"), 0.08, gen_screen_trans)
create_wave(os.path.join(output_dir, "money_gain.wav"), 0.22, gen_money_gain)
create_wave(os.path.join(output_dir, "money_loss.wav"), 0.16, gen_money_loss)
create_wave(os.path.join(output_dir, "lottery_win.wav"), 0.85, gen_lottery_win)
create_wave(os.path.join(output_dir, "death.wav"), 0.85, gen_death)
print("All audio assets generated successfully!")
