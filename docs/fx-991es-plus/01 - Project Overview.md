# 01 — Project Overview

## Target device
Casio fx-991ES PLUS scientific calculator, personal hardware unit, board silks `XS991-HW`, `JY7216`.

## Goal
Understand the calculator from PCB → silicon → ISA → firmware, and determine the most realistic route to running **our own software** on the **original hardware**, with a fallback replacement-controller route if the original chip cannot control itself.

## Seven independent achievements (kept strictly separate)
| ID | Achievement |
|----|-------------|
| A | Emulation of the platform |
| B | Legitimate ROM/RAM acquisition |
| C | ISA + memory architecture understanding |
| D | ACE on real hardware (≠ RAM execution, ≠ ROP, ≠ ROM dump, ≠ firmware patch) |
| E | Hardware debug interfaces |
| F | Permanent firmware replacement |
| G | Repurposing LCD/keypad with a replacement controller |

**ACHIEVEMENT D ≠ F**: ROP demonstrations are transient RAM-state tricks; mask ROM cannot be reflashed. Nothing done here will imply otherwise.

## Workspace layout
```
C:\Users\mohamed\Desktop\Casio\
├── Casio\                          ← Obsidian vault (this knowledge base)
│   └── Casio fx-991ES PLUS\       ← project folder inside vault
└── fx991esplus-research\
    ├── vendor\     (12 cloned repos — originals preserved untouched)
    ├── artifacts\  (analysis outputs: hashes, disassembly listings)
    ├── tools\      (build scripts we wrote)
    └── FINAL-REPORT.md
```

## Engineering rules (mandatory, from project brief)
1. Never invent chip IDs, pinouts or memory maps.
2. Never present assumption as verified fact; tag facts/hypotheses/unknowns.
3. Never claim firmware extracted unless binary exists + provenance established.
4. Never claim flashable because a debug interface exists.
5. Never confuse ACE with permanent firmware replacement.
6. Preserve originals; hash binaries before modifying anything.
7. Review unknown scripts before executing; no destructive writes to the calculator.
8. No hardware purchases until target processor/interface/protocol/voltages/programmer-proof are established (see [[Research/Open Questions]] and [[Hardware/Debug Interfaces]]).
9. Cite original documentation and source code; document disagreements between sources.
10. Report failed experiments honestly.

## Sources hierarchy (for resolving conflicts)
1. Physical device + measurements (highest)
2. Official Casio emulators + their ROMs
3. LAPIS/OKI official manuals (general nX-U8/100, chip-specific applicability caveated)
4. Source code of community emulators/tools
5. Forum posts (casiocalc, Baidu) — treat as leads, verify against the above
