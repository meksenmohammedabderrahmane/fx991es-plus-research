# Memory Map

> Two levels: (1) core architecture (valid for all nX-U8/100), (2) the calculator's chip-specific layout (this is the level that matters to us and is now CORROBORATED by a real ROM).

## Core (from manual + fxesdev)
- Instruction space 1 MiB in 16 segments (CSR:pc); data space 16 MiB in 256 segments (DSR:ar).
- Segment 0 special: code fetch = 32 K-word ROM window; data access = ROM window/other. Segment ≥1: data = physical segment.
- Segment-0 data lookups where `ar` falls in the window fetch code bytes, not data.

## Calculator chip (observed via CasioEmuX model = real-hardware behavior, corroborated by ROM)
| Region | Address | Size | Notes | Source |
|--------|---------|------|-------|--------|
| Code/ROM (segment 0) | `csr=0x0000`, `pc 0x0000–0xFFFF` (+beyond via window) | up to 128 KB dump | real ROM = 128 KB (fx-570ES PLUS dump); `csr_mask 0x0001` ⇒ Casio code runs only in segment 0 | CasioEmuX `models/fx570esplus/model.lua`; `src/Chipset/MMU*` |
| RAM base | data seg 0 → `0x8000` byte address in segment 1 space | 0xE00 (3584 B) | matches ML610901 datasheet SRAM size; hackstring input area at 0x8154 sits inside | CasioEmuX `Emulator.cpp` RAM region setup; `fxesplus/docs/hackstring-tutorial.txt` |
| SFR block | segment 0xF data (`0xF000–0xFFFF`) | 256 B × (regs) 16-bit spacing | `0xF0x` int regs, `0xF028 BLKCON`, `0xF048 IO`, `0xF0C0 RTC`, `0xF0E0 flash regs`, screen buffer `0xF800`, per CasioEmuX regions | CasioEmuX `Peripheral/*` + model.lua |
| ROM window | segment 0 low half | 32 K-words | whole dump readable through data-space window (enables community ROM-read ROP demos) | fxesdev; emulator ROMWindow |

## RAM layout an exploit cares about (from hackstring tutorial)
| Address | Role |
|---------|------|
| `0x8154` | hackstring input buffer (100-byte entry window before overflow basic) |
| `0x81B8` | cache/continuation buffer |
| `0x821C–0x8224` | stats seed words |
| cursor counter | `+2B` region (see tutorial file for exact offset) |

Source: `vendor/fxesplus/docs/hackstring-tutorial.txt` (RAM layout section); CasioEmuX `model.lua inject()` writes to `0x8154`.

## Unknowns explicitly
- Exact SRAM size + banking of MY unit's die (community: 3.5 KB family matches ML610901-class; our single-chip xs-revision likely same; not verified on device).
- Any ROM paging beyond 128 KB: none observed in dump; emulator masks code reads to `0x1FFFE` for ES-PLUS (rom ≤ 128 KB).
