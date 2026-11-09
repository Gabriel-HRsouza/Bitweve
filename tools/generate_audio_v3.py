"""Gera os efeitos sonoros dos sistemas v3 do BitWeve (minigames, app de
namoro, prisão e festas). Todo o áudio é sintetizado matematicamente —
autoria própria do projeto, sem samples de terceiros.

Uso:  python tools/generate_audio_v3.py
Saída: assets/audio/{pickup,alarm,match,cell_door,party,swipe}.wav
"""
import math
import os
import random
import struct
import wave

OUT = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
SR = 44100


def write(name, samples):
    path = os.path.join(OUT, name)
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = 0.89 / peak if peak > 0.89 else 1.0
    with wave.open(path, 'w') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s * scale)) * 32767)) for s in samples))
    print('ok', name, f'{len(samples) / SR:.2f}s')


def fade(out, ms=15):
    f = int(SR * ms / 1000)
    for i in range(min(f, len(out))):
        out[-1 - i] *= i / f
        out[i] *= i / f
    return out


def pickup():
    # blip ascendente curto (coleta de item)
    n = int(SR * 0.16)
    out = []
    for i in range(n):
        t = i / SR
        f = 880 + 1400 * (t / 0.16)
        out.append(0.55 * math.sin(2 * math.pi * f * t) * math.exp(-t * 14))
    return fade(out, 5)


def alarm():
    # sirene alternada (duas notas) por 0.9s
    n = int(SR * 0.9)
    out = []
    phase = 0.0
    for i in range(n):
        t = i / SR
        f = 740 if int(t * 6) % 2 == 0 else 990
        phase += 2 * math.pi * f / SR
        sq = 1.0 if math.sin(phase) > 0 else -1.0
        out.append(0.28 * (0.6 * sq + 0.4 * math.sin(phase)))
    return fade(out)


def match():
    # brilho cintilante (arpejo + cauda)
    out = [0.0] * int(SR * 0.9)
    for k, f in enumerate([1046.5, 1318.5, 1568.0, 2093.0]):
        s0 = int(k * 0.07 * SR)
        for i in range(s0, len(out)):
            t = (i - s0) / SR
            out[i] += 0.35 * (math.sin(2 * math.pi * f * t) + 0.3 * math.sin(2 * math.pi * f * 2.01 * t)) * math.exp(-t * 5)
    return fade(out)


def cell_door():
    # batida metálica grave + ressonância
    rnd = random.Random(3)
    n = int(SR * 0.8)
    out = []
    for i in range(n):
        t = i / SR
        noise = (rnd.random() * 2 - 1) * math.exp(-t * 40) * 0.7
        ring = sum(math.sin(2 * math.pi * f * t) * a for f, a in [(110, 0.5), (233, 0.3), (377, 0.2), (611, 0.12)]) * math.exp(-t * 4)
        out.append(noise + ring * 0.6)
    return fade(out)


def party():
    # estouro de confete + acorde maior festivo
    rnd = random.Random(9)
    n = int(SR * 1.0)
    out = [0.0] * n
    for i in range(int(0.08 * SR)):
        out[i] += (rnd.random() * 2 - 1) * 0.6 * (1 - i / (0.08 * SR))
    for f in [523.25, 659.25, 783.99, 1046.5]:
        for i in range(int(0.05 * SR), n):
            t = i / SR - 0.05
            out[i] += 0.18 * math.sin(2 * math.pi * f * t) * math.exp(-t * 3)
    return fade(out)


def swipe():
    # "whoosh" de ruído filtrado
    rnd = random.Random(5)
    n = int(SR * 0.22)
    out = []
    prev = 0.0
    for i in range(n):
        t = i / SR
        a = math.sin(math.pi * t / 0.22)
        alpha = 0.05 + 0.4 * (t / 0.22)
        prev = prev + alpha * ((rnd.random() * 2 - 1) - prev)
        out.append(prev * a * 0.8)
    return fade(out, 5)


if __name__ == '__main__':
    write('pickup.wav', pickup())
    write('alarm.wav', alarm())
    write('match.wav', match())
    write('cell_door.wav', cell_door())
    write('party.wav', party())
    write('swipe.wav', swipe())
