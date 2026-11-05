# Processor Identification

## Level 1 — Architecture (CONFIRMED, High)
The calculator executes **nX-U8/100** (LAPIS/OKI 8-bit RISC, Harvard):
- Real 128 KB ROM dump disassembles cleanly with nX-U8 disassemblers (`vendor/CasioEmuX/disas`, `vendor/fxesplus/tools/disassembler/oki-u8-disas.cpp`); emulator runs the dumped firmware with correct behaviour.
- Official source: *nX-U8/100 Core Instruction Manual* (in `vendor/nXU8100-resources/`).
- fxesdev docs state the ES-PLUS family primary MCU is nX-U8/100: `vendor/fxesdev.github.io/docs/introduction.md` (§ Hardware guide → CPU).
- Multiple independent community projects (fxesplus, fx-83GT_Plus, pyu8rop, trowelib) target the same ISA.

## Level 2 — Silicon family (High for family, Low for exact die)
| Candidate | Evidence | Against / caveat |
|-----------|----------|------------------|
| OKI/LAPIS ML610901 / ML610901B (2009 first-edition chip) | Wiki-documented ES-PLUS first-edition MCU: 96 KB mask ROM, 3584 B RAM, 0.5–8.192 MHz, 96seg×32com LCD driver, on-chip debug (community + wiki) | Two-chip 2009 edition does not match our single-blob board; 96 KB < 128 KB dump |
| Unknown single-chip part with 128 KB ROM (2011+ xs-revision) | Community consensus: 2011+ "X" revision integrated both chips; fx-570ES PLUS dump is 128 KB and runs in emulators as real-hardware; our board matches this generation | Part number never published — community searches failed so far |
| 2nd-edition (2019+) single-chip part | Some late ES PLUS units changed again | Board codes `XS991-HW`/`JY7216` do not match wiki's older board codes; edition tests not yet run on my unit |

**Honest position:** the exact die inside the COB of *my* unit is **Unknown**. What is established: the architecture (nX-U8/100) and the software-visible memory map (validated by emulator against the real ROM).

## Level 3 — Distinguishing tests to run on device (zero cost)
| Test | Procedure | Discriminates |
|------|-----------|---------------|
| Self-test serial screen | `[SHIFT][7]+[ON]` → `9` → `[SHIFT]` | Shows internal version/board info on diag screens |
| Trig identity signature | DEG mode: `sin 9` → `cos Ans` → `tan Ans` → `arctan Ans` → `arccos Ans` → `arcsin Ans` | Known signatures per edition/ROM revision; community-documented values (e.g. `9.00000000733338` quoted for one revision) |
| SUM/diag codes | via self-test menus | Variant codes map to board/ROM revisions in community tables (casiocalc wiki) |
| First-edition board code check | wiki photos: GY-450 (82ES), GY-452/GY-453, GY-455 (991ES)… | Ours says `XS991-HW` — matches none of the first-edition codes recorded |

Source note: procedures from casiocalc wiki + user202729/fxesplus issue #4 discussion; MY UNIT OBSERVATIONS PENDING — do not conclude edition from this note alone.

## Clock capability (from manuals, family-level)
nX-U8/100 family ML610x parts run main clock derived from subclock (32.768 kHz crystal, present on our board) up to ~8.192 MHz in these calculators (ML610901 spec sheet; CasioEmuX timing model). Actual per-model CPU speed used by Casio firmware is measured/analyzed, not yet confirmed for my unit.

## On-chip debug capability (family-level)
Comparable ML610x datasheets (e.g. ML610Q435) document an on-chip ICE/debug function accessed over 2 wires. Whether *this* die exposes it on the 2×2 pads = unverified (see [[Hardware/Debug Interfaces]]).
