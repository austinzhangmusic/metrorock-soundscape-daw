import random
import time

THRESHOLD = 100
COOLDOWN = 0.5
NUM_SENSORS = 20
ACTIVE_SENSORS = [0, 1, 2, 3]

SENSOR_STEMS = {
    0: 'stem_vocals',
    1: 'stem_bass',
    2: 'stem_drums',
    3: 'stem_other',
}

PALETTES = [
    ((0.05, 0.05, 0.15), (0.2, 0.6, 0.9)),
    ((0.6, 0.1, 0.2),    (1.0, 0.6, 0.3)),
    ((0.0, 0.3, 0.3),    (0.4, 0.9, 0.7)),
    ((0.3, 0.1, 0.5),    (0.8, 0.4, 0.9)),
    ((0.1, 0.1, 0.1),    (0.95, 0.95, 0.9)),
]

last_hit = [0.0] * NUM_SENSORS

def onReceive(dat, rowIndex, message, bytes):
    line = message.strip()
    if not line.startswith('S:'):
        return
    parts = line[2:].split(',')
    if len(parts) != NUM_SENSORS:
        return
    now = time.time()
    pad_notes = op('/project1/pad_notes')
    for i in ACTIVE_SENSORS:
        try:
            val = int(parts[i])
        except (ValueError, IndexError):
            continue
        if val > THRESHOLD and (now - last_hit[i]) > COOLDOWN:
            last_hit[i] = now

            pad_notes.par[f'value{i}'].pulse(1.0, frames=3)

            print('Sensor', i, '|', SENSOR_STEMS[i], '-> note', 60 + i)
            op('/project1/websocket1').sendText('TAP:' + str(i))

            start, end = random.choice(PALETTES)
            keys = op('/project1/gradient_colors')
            keys[1, 1].val = str(start[0])
            keys[1, 2].val = str(start[1])
            keys[1, 3].val = str(start[2])
            keys[2, 1].val = str(end[0])
            keys[2, 2].val = str(end[1])
            keys[2, 3].val = str(end[2])
