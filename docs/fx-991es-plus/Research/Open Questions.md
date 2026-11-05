# Open Questions

| # | Question | Evidence state | Test to resolve |
|---|----------|----------------|-----------------|
| 1 | Exact edition of my fx-991ES PLUS (X-rev vs 2-nd-ed 2019+) | Photo-inference only (single-blob = post-2011) | Device self-test `SHIFT 7 + ON`, `9`, `SHIFT` reading serial string; trig signature test; SUM codes |
| 2 | Die part number (silicon identity) | Unknown to community for post-2011 parts | Self-test screens sometimes reveal codes; Otherwise: die-shot research (destructive, out of scope) |
| 3 | Purpose/values of 2×2 unsilked pads near COB | Hypothesis only (TEST/RESET/VDD-class) | Requires continuity/voltage measurement — no equipment yet; macro photo trace analysis possible zero-cost |
| 4 | Actual CPU clock frequency on my unit | Family max 8.192 MHz; actual firmware setting unknown | Timing experiment: screen update rates, or ROP-assisted timing loop measured against RTC |
| 5 | Full SFR map of calculator die | Emulator maps (screen `0xF800`, RTC `0xF0C0`…) partially known | SFR-write logging in emulator + compare vs real behavior |
| 6 | LCD FPC pinout (for replacement route) | Nothing yet — route G blocked pending evidence | Trace photo work; panel part number read from LCD module (macro photo of flex标签) |
| 7 | CasioEmuX accuracy vs real firmware | Basic build done; deep checks pending | Experiment checklist in [[Experiments/Experiment Log]] |
| 8 | Which hackstring demos work on 1st-vs-2nd editions | Community claims; not re-tested here | On-device worksheet reproduction |
| 9 | Whether official 991ES PLUS emulator image (=9x dump) differs from the 570-family dump we have | Likely (region/feature differences) | Acquire official 991 emulator + RomDumper (zero cost beyond download) |
| 10 | nX-U8 debug protocol on OUR board accessible at which pads | Protocol known; pads not | After #3 resolution; otherwise remains theoretical |
| 11 | Which model/revision are `segment0.bin` and `segment1.bin` from? (`LY710XA` tail marker in seg1; seg0 = alternate lower-half revision w/o marker) | Dump-folder audit logged (E11) | Compare against known ROM collections (cnCalc archives, official emulator dumps); layer diff with `rom.bin`; hash lookup |
| 12 | Does `rom.bin` (fx-570) ROP/gadget offsets match the 991ES PLUS and *my* unit's revision? | Community decomp `gyx-decomp` targets this class; not yet tested on device | Emulator drill first, then edition worksheet on device |

## Methodological gaps (kept deliberately)
- No logic analyzer/multimeter/soldering gear in scope per user constraint; all hardware claims stay photo-level until then.
- Leaked OKI toolchain provenance → codes from it never redistributed; we build our own assembler instead.
