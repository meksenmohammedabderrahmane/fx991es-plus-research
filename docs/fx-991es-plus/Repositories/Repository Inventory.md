# Repository Inventory

All clones live in `C:\Users\mohamed\Desktop\Casio\fx991esplus-research\vendor\` — originals unmodified.

| Repo (vendor dir) | Origin | Purpose | Used for | License state |
|-------------------|--------|---------|----------|---------------|
| `fxesplus` | github.com/user202729/fxesplus | Main ES-PLUS research repo: docs (hackstring tutorial, basic-overflow, instruction set), dumps, disassembler sources | ROM dumps + docs + disassembler fix | check LICENSE file (todo) |
| `CasioEmuX` | (fork by qiufuyu of Itay2805/CasioEmu) | Active emulator: SDL2 + Lua models + debugger; per-model lua configs | Main emulator target (A) | GPL-3.0 (per repo file) — confirm exact at build |
| `CasioEmu` | github.com/user202729/CasioEmu | Older meson-built emulator; unmaintained | Reference for design differences; skipped build (no meson) | check (todo) |
| `nXU8100-resources` | github.com/fxesdev/nXU8100-resources | PDFs: Core Instruction Manual, original + translated datasheets | ISA + architecture research (C) | check (todo) |
| `nX-U8_Debug` | community FPGA debug protocol implementation | ECP5/iCESugar-Pro 2-wire debug bridge + scripts | E (leads; not connected) | check (todo) |
| `570-991esp-rop-tools` (subdir trowelib) | community | Curated ROP gadget database for fx-570/991ES PLUS | D research | check (todo) |
| `pyu8rop` | community | Python ROP tooling for nX-U8 | D tooling | check (todo) |
| `anyrop-translator` | community | Translates ROP chains into hackstring bytes | D tooling | check (todo) |
| `RomDumper` | community | Extracts ROM/RAM images from official Casio emulators (SimU8.dll offsets) | B (legitimate acquisition route) | check (todo) |
| `fx-83GT_Plus` | community (Cambleton-era) | fx-83/85GT PLUS companion: hackstring recipes, extractors, PCB annotation photos | cross-reference (different generation) | check (todo) |
| `build-tools` (subdir) | leaked/current OKI toolchain drops (mach/oki-u8) | u8 SDK: ccu8.exe, Rasu8.exe (linker), ohu8.exe, ML6104xx DCL descriptors (no ML610901 DCL) | C toolchain study | **use cautiously: provenance = leaked tools** |
| `fxesdev.github.io` | github.com/fxesdev | Documentation site source (introduction, calculators, character encodings) | C documentation | check (todo) |

## Second batch of clones (2026-11-01, ecosystem scan)
| Repo (vendor dir) | Origin | Purpose | Notes |
|-------------------|--------|---------|-------|
| `u8_r2_plugin` | github.com/cetus9/u8_r2_plugin | **radare2 disassembly plugin for nX-U8/100** (C, LGPL-2.1, 2020, v0.9) | first external addresses-tool candidate; needs matching r2 version |
| `gy454xe-decomp` | github.com/fxesdev/gy454xe-decomp (archived) | Community **decompilation of the ES-PLUS GYX firmware** (fx-570/991 class, = our `GY454XE` ROM) | moved to Codeberg; kept for reference |
| `gyx-decomp` | codeberg.org/gwetm/gyx-decomp | The **live** successor of the above — decomp naming `unk[n]`, CCU8-compatible recompilation target | primary reference for ROM structure/labels |
| `pyu8disasx` | codeberg.org/gwetm/pyu8disasx | Upgraded nX-U8/U16 disassembler (PyU8disas rewrite) with CLI options | second disassembler for cross-validation |
| `emxu8` | codeberg.org/gwetm/emxu8 | "Yet another ROHM nX-U8/100 emulator" (wxWidgets + SDL3, officially supports MSYS2 UCRT64) | independent emulator → accuracy cross-check vs CasioEmuX |

## Ghidra situation (searched, none found)
- **No Ghidra/SLEIGH processor module for nX-U8/100 exists publicly** (searched 2026-11-01). Closest analog: `VIRUXE/ghidra-oki66207` targets OKI nX-8/200 (Honda ECUs) — different ISA, useful only as a template for writing our own SLEIGH spec. Recorded as future tooling idea.

## Pending: license column completion + SHA of each clone (`git log -1` pinned in Experiment Log).
