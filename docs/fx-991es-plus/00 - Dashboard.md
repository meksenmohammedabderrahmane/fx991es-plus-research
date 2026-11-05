# 00 — Dashboard

> Project knowledge base for the reverse engineering of **my own Casio fx-991ES PLUS**.
> Rules of engagement: no invented pinouts, no unverified claims, every statement carries a source + confidence tag.
> Facts = corroborated. Hypothesis = plausible, unverified. Unknown = open question.

## Status board (achievements)

| ID | Goal | Status | Confidence | Note |
|----|------|--------|-----------|------|
| A | Emulation of the platform | ✅ Built + smoke-tested (`casioemu_x.exe`, real ROM loaded, Lua console verified) | High | See [[Software/Emulator]] |
| B | Legitimate ROM/RAM acquisition | ✅ For fx-570ES PLUS (community dump, hash-matched). ⬜ Own 991 unit | High / Low | See [[Firmware/ROM Inventory]] |
| C | ISA / memory-architecture understanding | ✅ Core established, ISA table in progress | High | See [[Architecture/CPU Architecture]] |
| D | Arbitrary code execution on real HW | ⬜ Untested on my unit (community-proven on same family) | Community: High; My unit: Low | See [[Software/ROP Research]] |
| E | Hardware debug interfaces | ⬜ Documented protocol exists; board pads unverified | Low | See [[Hardware/Debug Interfaces]] |
| F | Permanent firmware replacement | ❌ Almost certainly impossible (mask ROM) | High (from silicon class) | See [[Firmware/Firmware Feasibility]] |
| G | Replacement controller route | ⬜ Not assessed with measurements yet | N/A | See [[Decisions/Hardware Decisions]] |

## Device identification (current best)

- Board silks: `XS991-HW` (×2), `JY7216`; single COB blob; 32.768 kHz crystal; CR2025 backup cell; FPC LCD.
- Edition: **not** the 2009 two-chip edition (no separate memory chip visible) → post-2011 single-chip xs-revision most likely; exact revision (X-rev vs 2nd edition 2019+) still open — device-side tests required ([[Hardware/Processor Identification]], [[Research/Open Questions]]).

## Today's session log

- 2026-11-01 — Vault created (full skeleton). CasioEmuX UCRT64 build: **succeeded** after vendoring real imgui from the submodule (repo shipped placeholder files) and building via g++ response file. Smoke test passed: `model=models/fx570esplus` boots verified 128 KB ROM, Lua bridge (`emu.*`) live, clean shutdown. Vector page + strings sweep artifacts generated. **Historical research completed in-session** (subagents hit usage limits): thread 7583 page 1 + index mined, wiki `hackstring`/`rop-chain-explanation`/`hardware:pcb-es` fetched, Hackaday 28446 page captured — verdict: P156–P159 = hypothesis, never confirmed; see [[Research/Historical Research]]. Ecosystem scan added 5 new repos (r2 plugin, gyx-decomp), dumped-folder audit exposed mixed ROM revisions (`LY710XA` marker). **Achievement status: A ✅ built+smoke-tested; B ✅ (family dump, hash-backed); C ✅ core established; D = emulator ladder next; E/F/G = documented, blocked on device tests/equipment.**

## Quick links

- [[01 - Project Overview]] — scope, rules, workspace layout
- [[Hardware/PCB Analysis]] · [[Hardware/Processor Identification]] · [[Hardware/Test Pads]] · [[Hardware/Debug Interfaces]]
- [[Architecture/CPU Architecture]] · [[Architecture/Instruction Set]] · [[Architecture/Memory Map]]
- [[Firmware/ROM Inventory]] · [[Firmware/Disassembly]] · [[Firmware/Firmware Feasibility]]
- [[Software/Emulator]] · [[Software/Toolchain]] · [[Software/ROP Research]] · [[Software/Custom Software]]
- [[Repositories/Repository Inventory]]
- [[Experiments/Experiment Log]] · [[Experiments/Results]]
- [[Research/Historical Research]] · [[Research/Datasheets and Manuals]] · [[Research/Open Questions]]
- [[Decisions/Hardware Decisions]] · [[Decisions/Firmware Strategy]]
- FINAL-REPORT (workspace root): `fx991esplus-research/FINAL-REPORT.md`

## Open questions (top)

1. Which edition exactly is my unit (self-test + trig signature tests pending on device).
2. Do the 2×2 unsilked pads near the COB carry TEST0/TEST1/RESET (needs measurement before any wiring).
3. What is the exact part number inside the COB for post-2011 single-chip 991ES PLUS (unknown to community).
4. Clocking: main-speed of my unit (community says 8.192 MHz max family; not measured).
