# ROM Analysis (first pass)

> Binary: `vendor/fxesplus/dumps/rom.bin` (fx-570ES PLUS, 128 KB). All offsets file-relative = ROM byte address in segment-0 view.

## Verified observations
| Observation | Evidence | Meaning |
|-------------|----------|---------|
| Footer string `GY454XE` at 0x1FFFD | hex compare | board-family ROM code (cf. cnCalc GY-4xx series) — edition fingerprint of the dump |
| Reset/entry area is real nX-U8 code | `u8-disas artifacts/disas_reset_area.txt`: `EC 8D → SRL R13,R14`, `XOR R8,#0x34/0x36`, `1F FE → RT` at 0x6 | disassembly coherent from byte 0 — dump alignment correct |
| No 0xFF/0x00 padding desert in first page | listing | genuine code region, not a header/table |
| Segment split mismatch | segment0.bin + segment1.bin ≠ rom.bin (different byte ordering) | community dumps come in two segment orders; treat xor-in dumps carefully, use casioemu ordering for execution |

## Structure hypothesis to verify (Next)
| Region | Hypothesis | Method planned |
|--------|------------| ----------------|
| `0x0000–0x00FF` | reset + interrupt vectors | disassembly listing full page + emulator vector fetch path |
| `0x2760/0x2768` | memcpy/strcpy-ish helper routines (community ROP cornerstones; CasioEmuX breaks there) | disassemble 0x2740–0x27A0 block |
| `0x7EF8` | `ER8=[ER0]` load/store helper (trowelib gadget) | same |
| text strings | error messages, mode names, menu text | `strings -n 4` sweep → firmware/strings.txt into artifacts |
| font blocks | font0/1/2 extracts | already extracted by community (see [[Firmware/ROM Inventory]]) |

## Sampling rules learned
- Disassembler on invalid words can crash (per its help text) — always bound ranges and never treat a crash as "no code here".
- Report partial coverage honestly: full N-query coverage of 128 KB is a later milestone; first milestone is tool-validation samples (done: reset area, ROP sites).
