# Keyboard Matrix

## What is established
- CasioEmuX `models/fx991esplus_emu/model.lua` defines a full keycode table mapping physical button positions to firmware scan codes. Sample (subset):
  - numbers row: `0x02 7`, `0x12 8`, `0x22 9`, `0x42 /`
  - `0x00 1·10·` wait — actual: `0x00 '1'`, `0x10 '2'`, `0x20 '3'`, `0x30 '='`, `0x40 '-'`
  - `0x64 '0'`, `0x63 '.'`, `0x61 Ans`, `0x60 =`
  - `0x05..0x55` shift-block codes for function columns, `0x07 F1` (=SHIFT), `0x17 F2` (=ALPHA), arrows `0x26/0x37`, `0xB6/0x13/-class` special keys.
- The keycode = byte the firmware reads from the key-scan SFR/port block: consistent with a (rows×cols) static scan the firmware performs with KI pull/KO drive pins (family-standard KI/KO LCD-era design; used by all ML610x Casio calculators).

## Implications
1. For emulation input: the emulator maps SDL keys to those codes; our ROP demos can trigger key events this way without touching keyboard scanning details.
2. For goal-G replacement controller: reuse of the original keypad needs a matrix matrix (rows/cols) at these levels — matrix diagram must be derived from the keycode byte semantics + board traces (zero-cost: trace-follow via macro photos + continuity once equipment exists).
3. Autonomous key injection via ROP: community ROP demos sometimes feed the keycode directly — keycode list above is the usable map.

## Open questions
- Exact row/col pin assignment of THIS board (photo trace work only — no equipment yet).
- Whether the CNX-generation KI/KO port addresses apply (different IC model) — treat unknown.
- Power-on key (ON) uses a separate interrupt line, not the scan matrix (family-standard) — verify before relying.
