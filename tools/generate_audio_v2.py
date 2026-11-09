"""Gera os efeitos sonoros adicionais e a música de fundo do BitWeve.

Todo o áudio é sintetizado matematicamente (sem samples de terceiros),
portanto é de autoria própria do projeto.

Uso:  python tools/generate_audio_v2.py
Saída: assets/audio/{purchase,promotion,notification,menu_open,error,mission,music_loop}.wav
"""
import math
import os
import random
import struct
import wave

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
SR = 44100


def write(name, samples, sr=SR):
    path = os.path.join(OUT, name)
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = 0.89 / peak if peak > 0.89 else 1.0
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s * scale)) * 32767)) for s in samples))
    print('ok', name, f'{len(samples) / sr:.2f}s')


def tone(f, t):
    return math.sin(2 * math.pi * f * t)


def bell(f, t, decay):
    # sino suave: fundamental + parciais inarmônicos leves
    return (tone(f, t) + 0.35 * tone(f * 2.01, t) + 0.12 * tone(f * 3.98, t)) * math.exp(-t * decay)


def notes_seq(seq, dur, decay=9.0, gain=0.6):
    n = int(SR * dur)
    out = [0.0] * n
    for start, freq, amp in seq:
        s0 = int(start * SR)
        for i in range(s0, n):
            t = (i - s0) / SR
            out[i] += amp * bell(freq, t, decay)
    # fade out final para evitar clique
    fade = int(0.02 * SR)
    for i in range(fade):
        out[n - 1 - i] *= i / fade
    return [s * gain for s in out]


def purchase():
    # "caixa registradora" amigável: dois sinos + brilho
    seq = [(0.0, 1318.5, 0.6), (0.07, 1760.0, 0.7), (0.14, 2637.0, 0.35)]
    base = notes_seq(seq, 0.5, decay=10)
    rnd = random.Random(7)
    for i in range(int(0.05 * SR)):
        base[i] += (rnd.random() * 2 - 1) * 0.15 * (1 - i / (0.05 * SR))
    return base


def promotion():
    # fanfarra curta ascendente (C5 E5 G5 C6 + acorde)
    seq = [(0.0, 523.25, 0.5), (0.09, 659.25, 0.55), (0.18, 783.99, 0.6),
           (0.30, 1046.5, 0.75), (0.30, 783.99, 0.35), (0.30, 659.25, 0.3)]
    return notes_seq(seq, 1.1, decay=4.5, gain=0.55)


def notification():
    seq = [(0.0, 987.77, 0.6), (0.08, 1318.5, 0.55)]
    return notes_seq(seq, 0.38, decay=11, gain=0.5)


def menu_open():
    n = int(SR * 0.16)
    out = []
    for i in range(n):
        t = i / SR
        p = i / n
        f = 380 + 520 * p
        out.append(tone(f, t) * math.sin(math.pi * p) * 0.35)
    return out


def error():
    seq = [(0.0, 311.13, 0.6), (0.11, 233.08, 0.6)]
    return notes_seq(seq, 0.42, decay=8, gain=0.55)


def mission():
    seq = [(0.0, 783.99, 0.5), (0.08, 987.77, 0.55), (0.16, 1174.66, 0.6), (0.24, 1567.98, 0.7)]
    return notes_seq(seq, 0.8, decay=6, gain=0.55)


def music_loop():
    """Loop ambiente calmo (Cmaj7 - Am7 - Fmaj7 - G6), 8 compassos a 84 BPM.

    Envelopes são calculados com tempo modular, então o fim emenda no começo
    sem cortes audíveis.
    """
    sr = 22050
    bpm = 84
    beat = 60 / bpm
    bar = beat * 4
    bars = 8
    length = bar * bars
    n = int(length * sr)
    chords = [
        [261.63, 329.63, 392.00, 493.88],  # Cmaj7
        [220.00, 261.63, 329.63, 392.00],  # Am7
        [174.61, 220.00, 261.63, 329.63],  # Fmaj7
        [196.00, 246.94, 293.66, 329.63],  # G6
    ]
    bass = [65.41, 55.00, 87.31, 98.00]
    out = [0.0] * n

    def env_pad(x, d):
        # ataque/release longos, x em segundos desde o início do acorde
        a, r = 0.9, 1.4
        if x < 0 or x > d + r:
            return 0.0
        if x < a:
            return x / a
        if x < d:
            return 1.0
        return max(0.0, 1 - (x - d) / r)

    events = []  # (start, dur, kind, freq, amp)
    for b in range(bars):
        ci = b % 4
        start = b * bar
        for f in chords[ci]:
            events.append((start, bar, 'pad', f, 0.07))
        events.append((start, bar, 'bass', bass[ci], 0.12))
        # arpejo suave em colcheias
        arp = chords[ci] + [chords[ci][0] * 2]
        for k in range(8):
            f = arp[[0, 2, 1, 3, 4, 3, 2, 1][k]] * 2
            events.append((start + k * beat / 2, beat * 0.5, 'pluck', f, 0.05))

    for (start, dur, kind, f, amp) in events:
        if kind == 'pluck':
            span = int((dur + 0.9) * sr)
        else:
            span = int((dur + 1.4) * sr)
        s0 = int(start * sr)
        for j in range(span):
            i = (s0 + j) % n
            x = j / sr
            if kind == 'pad':
                e = env_pad(x, dur)
                v = (math.sin(2 * math.pi * f * x) + 0.5 * math.sin(2 * math.pi * f * 1.003 * x)
                     + 0.2 * math.sin(2 * math.pi * f * 2 * x))
            elif kind == 'bass':
                e = env_pad(x, dur) * 0.9
                v = math.sin(2 * math.pi * f * x) + 0.25 * math.sin(2 * math.pi * f * 2 * x)
            else:
                e = math.exp(-x * 5.5) * min(1.0, x / 0.005)
                v = math.sin(2 * math.pi * f * x) + 0.3 * math.sin(2 * math.pi * f * 2 * x)
            out[i] += amp * e * v
    # leve "respiração" estéreo simulada com tremolo lento
    for i in range(n):
        t = i / sr
        out[i] *= 0.92 + 0.08 * math.sin(2 * math.pi * t / length * 4)
    return out, sr


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    write('purchase.wav', purchase())
    write('promotion.wav', promotion())
    write('notification.wav', notification())
    write('menu_open.wav', menu_open())
    write('error.wav', error())
    write('mission.wav', mission())
    samples, sr = music_loop()
    write('music_loop.wav', samples, sr)
