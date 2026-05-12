# Custom Fingering Charts for WARBL2

## Overview

WARBL2 supports two custom fingering chart formats:

- **Standard (256 entries):** Two thumb states — open (entries 1–128) and closed (entries 129–256).
- **Ternary (384 entries):** Three thumb states — closed (entries 1–128), pinched (entries 129–256), and open (entries 257–384).

Each chart maps every combination of the 7 front tone holes (plus thumb state) to a MIDI note number (0–127). Charts are uploaded as comma-separated or newline-separated values through the Configuration Tool.

## Tone Hole Mapping

The 7 front tone holes are numbered from top to bottom:

| Hole | Name | Bit | Weight |
|------|------|-----|--------|
| 1    | L1 (left index)  | bit 6 | 64 |
| 2    | L2 (left middle) | bit 5 | 32 |
| 3    | L3 (left ring)   | bit 4 | 16 |
| 4    | R1 (right index) | bit 3 | 8  |
| 5    | R2 (right middle)| bit 2 | 4  |
| 6    | R3 (right ring)  | bit 1 | 2  |
| 7    | R4 (right pinky) | bit 0 | 1  |

Each entry's position within its 128-entry section is determined by adding the weights of the **covered** holes. Entry 1 (index 0) = all holes open, entry 128 (index 127) = all holes closed.

### Examples

| Fingering        | Holes Covered          | Calculation      | Index |
|------------------|------------------------|------------------|-------|
| All open         | (none)                 | 0                | 0     |
| Only R4          | R4                     | 1                | 1     |
| L1+L2+L3        | L1, L2, L3             | 64+32+16         | 112   |
| L1+L2+L3+R1+R2  | L1, L2, L3, R1, R2    | 64+32+16+8+4     | 124   |
| All closed       | L1, L2, L3, R1, R2, R3, R4 | 64+32+16+8+4+2+1 | 127 |

## Ternary Chart Layout

A 384-entry ternary chart is organized in three consecutive sections:

```
Position 1–128:   Thumb CLOSED  (first octave)
Position 129–256: Thumb PINCHED (second octave, half-hole)
Position 257–384: Thumb OPEN    (third octave / top notes)
```

Each section contains 128 values, one per front-finger combination (see table above). Within each section, the ordering is the same: index 0 = all front holes open, index 127 = all front holes closed.

### How it works at runtime

The firmware reads the thumb sensor separately from the 7 front holes. Based on the thumb position (closed, pinched/half-hole, or open), it looks up the MIDI note in the corresponding section of the chart using the front finger combination as the index.

## Building a Ternary Chart

### Step 1: Start with a standard chart

If you already have a working 256-entry standard chart, the first 128 entries (thumb open) become the **thumb open** section (positions 257–384), and the last 128 entries (thumb closed) become the **thumb closed** section (positions 1–128).

### Step 2: Create the pinched section

The pinched section (positions 129–256) typically contains second octave notes. A good starting approach:

1. Copy the thumb-closed section (you can use the "Copy closed → pinched" button in the Configuration Tool).
2. Transpose each value up 12 semitones (one octave).
3. Replace specific entries with the correct fingerings for your instrument's second octave.

For finger combinations that don't have a meaningful pinched-thumb note, use a placeholder value. Common choices:
- **48** (C3): A clearly wrong note that signals an undefined fingering.
- **0**: Silence (if your setup treats note 0 as silent).
- **127**: The previous note continues playing (no note change).

### Step 3: Verify standard fingerings

For each section, check that the standard fingerings produce the expected notes:

| Recorder Fingering (C soprano) | Holes Covered | Index | Expected Note |
|-------------------------------|---------------|-------|---------------|
| C (all closed, thumb closed)  | L1+L2+L3+R1+R2+R3+R4 | 127 in closed section | 60 (C4) |
| D (lift R4)                   | L1+L2+L3+R1+R2+R3    | 126 in closed section | 62 (D4) |
| E (lift R3+R4)                | L1+L2+L3+R1+R2       | 124 in closed section | 64 (E4) |
| G (lift R1+R2+R3+R4)         | L1+L2+L3             | 112 in closed section | 67 (G4) |
| C5 (all closed, thumb pinched)| L1+L2+L3+R1+R2+R3+R4 | 127 in pinched section | 72 (C5) |

### Step 4: Paste and upload

Combine all three sections into a single list of 384 comma-separated values in the order: closed, pinched, open. Enable **Ternary thumb mode** in the Configuration Tool, paste the values, select a Custom chart slot, and upload.

## Example: Baroque Soprano Recorder in C

The file `baroque_recorder_ternary.txt` contains a complete 384-entry ternary chart based on the Moeck GT03 fingering chart. It uses 0 (silence) for undefined finger combinations.

The key innovation of this chart is that the three thumb states resolve fingering conflicts that exist in the 256-entry chart:

| Thumb | Front fingers | Index | Note |
|-------|---------------|-------|------|
| Closed | L1 L2 (xxo oooo) | 96 | A4 (69) |
| Open | L1 L2 (xxo oooo) | 352 | C#5 (73) |
| Pinched | L1 L2 (xxo oooo) | 224 | A5 (81) |

### Thumb Closed (entries 1–128) — First Octave

| Note | MIDI | Fingering | Index |
|------|------|-----------|-------|
| C4   | 60   | L1 L2 L3 R1 R2 R3 R4 | 127 |
| C#4  | 61   | L1 L2 -- R1 R2 R3 R4 | 111 |
| D4   | 62   | L1 L2 L3 R1 R2 R3    | 126 |
| Eb4  | 63   | L1 L2 L3 R1 R2 -- R4 | 125 |
| E4   | 64   | L1 L2 L3 R1 R2       | 124 |
| F4   | 65   | L1 L2 L3 R1 -- R3 R4 | 123 |
| F#4  | 66   | L1 L2 L3 -- R2 R3    | 118 |
| G4   | 67   | L1 L2 L3             | 112 |
| G#4  | 68   | L1 L2 -- R1 R2 R3    | 110 |
| A4   | 69   | L1 L2                | 96  |
| A4   | 69   | L1 L2 -- R1 R2 -- R4 (alt) | 109 |
| Bb4  | 70   | L1 -- L3 R1          | 88  |
| Bb4  | 70   | L1 -- L3 -- R2 R3 (alt) | 86 |
| B4   | 71   | L1                   | 64  |
| B4   | 71   | -- L2 L3 (alt)       | 48  |
| C5   | 72   | -- L2                | 32  |
| C#5  | 73   | (all open)           | 0   |

### Thumb Open (entries 257–384) — C#5, D5, Eb5

| Note | MIDI | Fingering | Index |
|------|------|-----------|-------|
| C#5  | 73   | L1 L2                | 96  |
| C#5  | 73   | L1 -- L3 R1 (alt)    | 88  |
| D5   | 74   | -- L2                | 32  |
| Eb5  | 75   | -- L2 L3 R1 R2 R3   | 62  |
| Eb5  | 75   | L1 L2 L3 R1 R2 R3 (alt) | 126 |

### Thumb Pinched (entries 129–256) — Second Octave + C6

| Note | MIDI | Fingering | Index |
|------|------|-----------|-------|
| E5   | 76   | L1 L2 L3 R1 R2       | 124 |
| F5   | 77   | L1 L2 L3 R1 -- R3    | 122 |
| F#5  | 78   | L1 L2 L3 -- R2       | 116 |
| G5   | 79   | L1 L2 L3             | 112 |
| G#5  | 80   | L1 L2 -- R1          | 104 |
| G#5  | 80   | L1 L2 -- R1 -- R3 R4 (alt) | 107 |
| A5   | 81   | L1 L2                | 96  |
| Bb5  | 82   | L1 L2 -- -- R2 -- R4 | 101 |
| Bb5  | 82   | L1 L2 -- R1 R2 R3 (alt) | 110 |
| B5   | 83   | L1                   | 64  |
| B5   | 83   | L1 L2 -- R1 R2 (alt) | 108 |
| C6   | 84   | L1 -- -- R1 R2       | 76  |

## Tips

- Use the **thumb state indicator** in the Configuration Tool to see which section you're editing based on your cursor position in the text area.
- The **Copy closed → pinched** button is a quick way to start the pinched section — it duplicates the first 128 values into positions 129–256.
- You can edit the chart as comma-separated values in any text editor before pasting.
- MIDI note 0 produces silence. MIDI note 127 means "no change" (the previous note keeps playing).
- The bell sensor is not used in custom charts.
