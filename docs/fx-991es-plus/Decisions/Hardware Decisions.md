# Hardware Decisions

## Decision log (chronological)

| Date | Decision | Justification | Alternatives rejected |
|------|----------|---------------|----------------------|
| 2026-11-01 | **Software-first path** (emulator + static research) before any hardware probing | User has no electronics equipment; zero-cost software route is fully viable for achievements A–D understanding | Buying FPGA/programmer now — rejected: target interface + voltages unproven |
| 2026-11-01 | **No purchase recommendation issued yet** | Per rules: only after target processor/interface/protocol/voltage/programmer-evidence chain completes (see [[Hardware/Debug Interfaces]] matrix — everything is "lead" status) | n/a |
| 2026-11-01 | EASE-1000/uEASE/Nano-EASE recorded as **leads only** | They implement the OKI/LAPIS 2-wire ICE; our die's debug exposure + mask-ROM (no flash) status make programming features inapplicable | Treating them as guaranteed-compatible — rejected (no evidence for this Casio die) |
| 2026-11-01 | FPGA (iCESugar-Pro/ECP5) debug bridge = candidate instrument *if* pads confirmed | Open-source protocol implementation exists (`vendor/nX-U8_Debug`); UART bridge spec 115200; but requires soldering + equipment user does not have | PCB-dependent hardware probing (destroying epoxy) — rejected permanently |
| 2026-11-01 | Route G (replacement controller) is on hold, not canceled | LCD/keypad reuse is possible in principle but needs FPC pinout evidence; no measurements yet | Committing to "soC replacement" designs now — rejected |

## Standing safety rules for future hardware work
1. Multimeter continuity first, never sourcing into unknown pads; everything below 3 V rails.
2. Never wire anything to the 2×2 cluster without a written continuity map.
3. Battery cells stay isolated; no supply injection into COB nets.
4. Backup ROM/RAM state first using software before any hardware intervention on the board.
