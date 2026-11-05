# CPU Architecture (nX-U8/100)

> Sources: *nX-U8/100 Core Instruction Manual* (`vendor/nXU8100-resources/nX-U8100 Core Instruction Manual.pdf`); fxesdev introduction (`vendor/fxesdev.github.io/docs/introduction.md`); CasioEmuX implementation (`vendor/CasioEmuX/emulator/src/Chipset/CPU.*`).

## Classification
- 8-bit RISC core, fixed **16-bit instruction words** (some with immediate extensions), 3-stage pipeline, Harvard architecture.
- Vendor: LAPIS Semiconductor (formerly OKI Semiconductor). Core used across ML610x/ML610Qxx calculator SOCs.

## Address spaces (Harvard)
| Space | Width | Segmenting | Access register |
|-------|-------|-----------|-----------------|
| Instructions | 1 MiB | 16 × 64 KB segments (`CSR:pc`, 20-bit) | `pc` |
| Data | 16 MiB | 256 × 64 KB segments (`DSR:ar`, 24-bit) | `ar` |

(Direct quotes/figure: fxesdev §Architecture, citing manual p.12; emulator mirrors this with `CSR` mask + `DSR` prefix op.)

## Registers
| Register | Width | Notes |
|----------|-------|-------|
| `r0`–`r15` | 8 bit | general register file |
| `ERn` (n even, 0..14) | 16 bit | pair `r(n):r(n+1)`; low byte in lower-numbered register (nX-U8 is little-endian) |
| `SP` | 16 bit | stack pointer of data space |
| `PSW` | 8 bit | flags: `C`(0x80) `Z`(0x40) `S`(0x20) `OV`(0x10) `MIE`(0x8) `HC`(0x4) `ELEVEL`(0x3) — constants verified in `CasioEmuX/src/Chipset/CPU.hpp:106-118` |
| `CSR`, `DSR` | segment regs | `CSR` selects code segment (calculator's `csr_mask=0x0001` for ES-PLUS ⇒ only segment 0 used by Casio code-fetch); `DSR` selects data segment; prefix-op semantics per manual §3.3 (cited in emulator `OP_DSR`, CPU.cpp:195-197) |
| `EA` | 16 bit | auxiliary/extended accumulator for `[EA+]` addressing (in emulator ModelInfo/SFR region work) — verify exact manual section before treating as textbook fact |
| supervisory regs | LR/ELR, EIPC, EINT, ECSR | interrupt/exception context save (manual); emulator models relevant subset — enumerate before writing detailed note |

## Control flow & the stack (why ROP, why not ACE)
- CALL/branch instructions push a return address; **stack is in data space**, code fetch is on a separate bus.
- Segment 1 *via the instruction bus* is remapped to show the whole ROM image (fxesdev §Architecture): code cannot be fetched from RAM ⇒ **arbitrary code execution is impossible; only ROP** works (community-established, matches emulator memory model).
- push/pop compile to multi-instruction sequences touching `SP` explicitly (no cheap push), making long ROP chains and register control painful — encodes into gadget design (see [[Software/ROP Research]]).

## Interrupts (summary; details → [[Architecture/Interrupts and Peripherals]])
- Vectored interrupt controller with priority + maskable (MIE) / supervisor levels (ELEVEL, HC); context saved per manual; CasioEmuX implements timers/interrupt edges with model config.
- Emulator source comments tie behaviors to manual §3.3 (instruction/DSR cycle costs) — good cross-validation point for accuracy tests.

## Validation status vs hardware
- ISA semantics: cross-checkable via (1) disassembly of the real 128 KB ROM producing consistent code (done, reset area + gadget sites), (2) community ROP demonstrations that only work if semantics match, (3) official Casio emulator co-running (RomDumper provenance). Silicon-level timing/behavior (e.g., exact wait states) not yet measured on device.
