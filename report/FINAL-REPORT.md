# FINAL-REPORT.md — Casio fx-991ES PLUS reverse engineering project

> Status: **report v1.2 (2026-11-04)** — historical research merged in-session (thread 7583 + wiki + Hackaday 28446) **and Phase 3 emulator payload-reproduction series E14–E19 completed** (see §Phase 3 below). Evidence ledger lives in the Obsidian vault: `Casio fx-991ES PLUS/` (vault notes referenced in brackets).

## What exactly is inside my calculator?

| Layer | Finding | Confidence |
|-------|---------|------------|
| Main control | One single-chip MCU under a COB blob executing nX-U8/100 code | High (photo: single blob; architecture confirmed by ROM+emulator) |
| Edition | Post-2011 single-chip generation; exact revision (X-rev vs 2019 2nd edition) open | Med |
| Board marks | `XS991-HW` (×2), `JY7216` silks; no match to wiki's older GY-/RCA- board codes | Fact (photos) + Low for dating |
| Clock | 32.768 kHz crystal (subclock); main clock unmeasured | High/Med |
| Power | AAA main + CR2025 backup for RAM/RTC | High |
| Display | Monochrome V.P.A.M. LCD via FPC, driven by the MCU's integrated LCD block | Med-High |
| Keypad | Key scan matrix (codes enumerated by emulator model table) | Med |
| Silks pads | `P07`, `P12…P32` labels (port-style naming); unsilked 2×2 cluster near blob, function unknown | Fact for labels; Low for function |

## What CPU architecture does it use?

**nX-U8/100** (LAPIS Semiconductor, ex-OKI): 8-bit RISC, fixed 16-bit instructions, Harvard
- 1 MiB instruction space (16 × 64 KB segments, `CSR:pc`), 16 MiB data space (256 × 64 KB, `DSR:ar`).
- Registers `r0–r15` (8-bit) + `ER` 16-bit pairs, `SP`, `EA`, `PSW` (flags C/Z/S/OV/MIE/HC/ELEVEL — constants verified in CasioEmuX CPU.hpp), supervisory regs for interrupts.
- Sources: *nX-U8/100 Core Instruction Manual* (repo PDF), fxesdev intro doc, CasioEmuX CPU implementation, successful disassembly of a real 128 KB ROM.

## Which processor implementation is most likely?

- The **exact die is not publicly identified** for the post-2011 ES-PLUS generation (community has never published the part number).
- Our board rules out the 2009 two-chip edition (ML610901 + companion). The 2011+ single-chip part carries a **128 KB mask ROM** class (`rom.bin` size + `csr_mask` in emulator) — consistent with the XL-class ML610x family of the nX-U8/100 core.
- Note kept honest: knowing the family ≠ knowing the die. Definitive part number would require evidence not yet available (die marking under epoxy, official docs, or the self-test screens).

## What is known about its ROM?

- Provenance-verified 128 KB dump exists **for the fx-570ES PLUS family** (same engine generation): SHA-256 `1a1b575f…71071`, confirmed against CasioEmuX's recorded hashes; footer ROM code `GY454XE` (GY-4xx board family, cf. cnCalc records); real firmware strings confirmed ("Syntax ERROR", "Math ERROR", "Insufficient MEM", …).
- Segments: 2 × 64 KB (segment0/segment1 exist in the dumps; they differ in byte order from rom.bin).
- RAM (emulator-matched to community + ML610901-class datasheet): 3,584 B at data-space `0x8000`; hackstring input buffer `0x8154`, cache `0x81B8`.
- Community ROM-version differences (1st vs X-rev vs 2nd editions) partially established historically (see vault [[Research/Historical Research]]); my unit's edition still requires on-device worksheets.
- Not yet obtained: a dump from **my personal unit**.

## Can we execute our own code?

- **Yes, transiently, via ROP** — established technique on the fx-ES PLUS family (community-proven, tooling cloned: trowelib gadget DB, pyu8rop, anyrop-translator). Fundamental limit (Harvard remap of segment 1 to ROM) makes RAM shellcode impossible ⇒ ROP only, no native code execution. **Emulator-verified (E15b):** the CPU never executes injected RAM-as-code — sample sweep over 4 injection entry states stayed entirely in ROM.
- **Emulator status of the community demo (E14–E19):** the ROP gadget machinery really executes in the verified GY454XE dump (≈10.4k gadget transitions under the forced entry state, `csr=1; pc=0x54EE; sp=0x8DA4`), but community data-loader payload #331 **never reaches its loader stage** and produces **no custom framebuffer output**, via the forced entry (E15/E17/E18) *or* the natural typed-input entry (E14/E19). The scrolling-demo result is **not reproduced in CasioEmuX** — see §Phase 3.
- My unit untested; repayment of this depends on edition tests (offsets are edition-sensitive).
- Custom screens/menus/demos are community-demonstrated on-device and remain plausible, but their reproduction here is **unverified** (see §Phase 3 verdict). Emulator environment for reproduction exists and is built.

## Can we replace the persistent firmware?

**No — High confidence.** The die uses mask ROM (no flash cells); on-chip debug of the family reads/controls but does not program; flash-programming features documented in family manuals apply to flash ("Q") variants. Nobody in the community has ever rewritten an fx-ES PLUS ROM. Anything labeled "custom firmware" on this hardware is in fact a session-scoped exploit chain on top of stock ROM.

## Hardware debugging & programming interface — answer (with confidence)
- **Documented family interface**: 2-wire ICE (clock+data), unlock key `0xAAFE`, chip-ID regs; TEST0/TEST1 (+RESET_N; +VPP only on flash parts). Open-source FPGA bridge exists (`vendor/nX-U8_Debug`).
- **On my board**: interface *presence* unproven (2×2 pads unverified; community's P156–P159 hypothesis was never publicly confirmed for mask-ROM boards; our silks are a different generation entirely).
- **Programmer candidates (unverified leads only)**: LAPIS EASE-1000/uEASE/Nano-EASE (official ICE tools; compatibility with a custom Casio mask part unattested); DIY ECP5 FPGA bridge (protocol implemented, needs soldering+equipment). No purchase supported by current evidence.

- Also documented: ROM/RAM extraction from official Casio emulators (RomDumper via SimU8.dll offsets) — zero-cost, legitimate acquisition route for the 991ES-PLUS model ROM.

## Which programmer, if any, would work?

- No definitive answer yet — **no purchase justified currently** (rules say: only after interface+voltage+programmer-evidence chain solidified).
- Leads recorded: LAPIS EASE-1000 / uEASE / Nano-EASE (official tool family for the ICE, compatibility with this custom calculator die unproven), DIY ECP5 FPGA bridge (open-source, needs soldering + owning an FPGA board). Both blocked until pads are verified.

## Can we do anything useful without buying hardware?

Already achieved (today, zero cost):
1. Workspace with **16** cloned research repos + full inventory (vault: [[Repositories/Repository Inventory]]).
2. Working Windows emulator (CasioEmuX) built + running the real ROM (build documented in [[Software/Emulator]]; UCRT64 build script in `tools/`).
3. nX-U8 disassembler validated against a real ROM; first-pass analysis artifacts (vectors page, helper-region listings, 262-string sweep, hash ledger) in `artifacts/`.
4. Obsidian research vault with per-topic evidence notes + confidence tags.

Next zero-cost steps:
1. ~~Merge historical research~~ — done in-session 2026-11-01 (vault [[Research/Historical Research]]).
2. Edition identification worksheets on my device (key-sequence self-tests; no equipment needed) — *highest-priority pending step*.
3. ~~Emulator experiments (renumbered E13/E14)~~ — **done 2026-11-04 as E14–E19**: hackstring injection validated, gadget machinery runs, but the community loader demo is NOT reproduced in CasioEmuX (see §Phase 3); remaining emulator work is optional and conditional on payload provenance (queued E21).
4. SFR-write logging during boot; build SFR behavior table; plan ROM-page disassembly in blocks.
5. screen FPC macro-photos + LCD module part number (phone camera) for route G.

## What should our next experiment be?

**E20 (device, zero cost)**: run the standard community edition-identification worksheets on my unit (self-test entry `[SHIFT][7]+[ON]` → `9` → `[SHIFT]`; third test `… → 6`; trig signature loop; record every screen string verbatim). This pins the edition, which every later decision (ROM readback offsets, ROP offsets, even route G, and *whether the community payload applies to my unit at all*) depends on. Then optional E13/E21 in the emulator with the verified ROM.

## Historical research (merged 2026-11-01)

- **casiocalc thread 7583** (SopaXorzTaker, Aug 2016, 514 replies/13 pages): early SuperH/HCD62121 misidentification → correct nX-U8/100; on-device **ROM dump demonstrated** by hackstring ("no longer needed now as we already have the ROM" — index post); hardware description posts (KI/KO, timers, LCD, getkey) exist as entry-indexed links; buffer-overflow technique credited to the **Baidu fx-es(ms) group** (tieba 4663446751). Details + citations: vault [[Research/Historical Research]].
- **Hackaday project 28446** (2017): stated nX-U8/100 + ROP-ACE as achievements; proposed custom loader; LBPHacker's CasioEmu (ancestor of our CasioEmuX). No logs/files → dormant; legacy lives in GitHub repos + wiki.
- **Test pads**: the forum's P156–P159 "debug port" idea is documented **as an explicit hypothesis** (post #5 wording "seem/might"), never given a confirmed public signal mapping for mask-ROM ES-PLUS boards; the wiki PCB page is a first-gen photo catalog (RCA501157/PWB-GY380-1 class) — different board family from ours. Full verdict: vault [[Research/Historical Research]] §5 + [[Hardware/Test Pads]].
- Independent cross-checks of community claims against our own artifacts all agreed (see cross-check ledger §9 of the historical note) — with two archaeology disagreements recorded and dated rather than silently resolved (emulator-ROM story).

## Phase 3 — emulator payload-reproduction experiments (E14–E19, completed 2026-11-04)

Environment: CasioEmuX build + provenance-verified fx-570ES PLUS dump `rom.bin` (SHA-256 `1a1b57…71071`, footer `GY454XE`). Each experiment is a reusable Lua script in `tools/experiments/` (e14.lua–e19.lua); raw logs in `artifacts/experiments/eXX-run.log`; per-row findings in the vault **Experiment Log**. Payload = casiocalc thread 7583 post #331 data loader (100 bytes, `y` starts 0xF830, byte = `(getkeycode₁+getkeycode₂)&0xFF`). All labels below refer to **our own artifacts** (CONFIRMED = observed directly here; SPECULATIVE = needs evidence).

Findings:

1. **Documented trigger condition not reproduced (CONFIRMED).** With the typed-100-token line + payload overwrite + `[=]`, execution hits PC=0x2768 with **SP=0x8D4C** and top-of-stack `74 70 00 00` — deterministically, twice in a row at the identical tick (8,989,418, E14 and E19). The community trigger state (SP=0x8DA4 + `EE 54 31 30` at SP) never occurs; `[=]` completes benignly.
2. **ROP machinery is real and runs (CONFIRMED).** With the community's synthetic entry state forced (`csr=1; pc=0x54EE; sp=0x8DA4`) the machine executes ≈10.4k distinct ROM-gadget transitions in ≈24k ticks (E15/E17/E18) — the gadget DB addresses are genuine code in this ROM.
3. **The loader stage never engages (CONFIRMED).** The loader handshake gadget (getkeycode window 0x0B45C–0x0B464) received zero PC hits in E18 and E19, including with key presses '1'/'2'/'5'/'9' landing **inside** the live chain window (E18: PC=0x7EB6 at press time). No `(k₁+k₂)&0xFF` write to `*y`=0xF830 ever appeared.
4. **Chain death is deterministic and reproducible (CONFIRMED).** ~24k ticks after launch, the epilogue walks 0x8C44→0x8C60, then executes bytes at **0xAF830 as code** (CPU walks the framebuffer-adjacent region), then lands in the OS main loop (PC=0x4836, SP=0x8DE2).
5. **Every FB write seen during chain activity is firmware cursor blink (CONFIRMED).** PC=0x00B3xx, ≈152.7k-tick period, `C0` byte toggling (E16 identified the signature). E15's earlier "chain wrote 2 bytes into the FB" were pre-press blink bytes — presses had landed after chain death (E17), which also explains the keycode-calibration failure.
6. **Measurement channel validated (CONFIRMED).** Control experiment E15c: direct Lua writes to 0xF820.. render **immediately** via SFR→screen echo and persist through 300k idle ticks. A payload FB write could not have been missed.
7. **RAM-as-code never executes (CONFIRMED).** E15b sweep: 4 injection entry states × 60 samples, zero in-buffer execution — Harvard separation re-verified behaviorally.
8. **Forcing CSR=1 at the natural 0x2768 point locks up (CONFIRMED).** E19: after the deterministic pass, forced-CSR execution cycles 0x0110–0x0148 forever, SP frozen, cursor blink stops entirely (OS main loop dead). The alternate entry is hard-ruled out in this environment.

**Verdict:** with the real GY454XE dump, payload #331's data loader does not execute via either documented entry path; **no custom framebuffer output was achieved in this environment**. The community post's "tested on emulator" success remains UNVERIFIED here.

Candidate explanations (SPECULATIVE — need evidence, not yet checked):
- S1: the post's emulator or ROM revision differs from ours (edition-sensitive offsets; payload's `y` start was already patched once in the source).
- S2: the loader needs an input/stack configuration our two tested states (full-region pump vs typed-100-token stack) do not reproduce.
- S3: the archived 100 bytes differ from the build the post tested.

**What is demonstrated regardless (CONFIRMED):** the harness end-to-end (scripts + logs are reproducible), the SFR→screen output channel, and behavioral Harvard separation. Phase 3 emulator work is closed unless a provenance-pinned payload re-test is pursued (queued as E21, conditional).

---
*Generated 2026-11-01; companion vault: `C:\Users\mohamed\Desktop\Casio\Casio\Casio fx-991ES PLUS\`*
