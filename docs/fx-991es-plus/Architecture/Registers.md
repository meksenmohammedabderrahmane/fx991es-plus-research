# Registers

## Confirmed in emulator (`CasioEmuX/src/Chipset/CPU.hpp`, C constants exact)
- `PSW` bit layout: `C=0x80, Z=0x40, S=0x20, OV=0x10, MIE=0x8, HC=0x4, ELEVEL=0x3 mask`.
- `csr_mask` (per-model, ES-PLUS = 0x0001) constrains code-segment fetch — enforces single-segment Casio code (model config).
- DSR prefix behavior: current-instruction only; previous DSR restored for non-changing prefix (emulator comment lines 391–393, ties to manual §3.3).
- Extra cycle behaviors: `[EA+]` addressing +wait; DSR-prefixed memory access +1 cycle (U16-specific +2 for L ERn forms) — emulator comments cite manual table (CPU.cpp:190-197, CPU.hpp:87-91).

## Register file semantics (established across sources)
- `r0–r15` 8-bit each; pairs `ERn` (even n) = `r(n):r(n+1)` little-endian 16-bit ops (`ADD ER2, ER4` etc. — opcode patterns in `instruction-set.txt`).
- `SP` dedicated stack pointer (manual; explicit INC/DEC SP in generated code, seen in disassembly).
- `PC` = 20-bit `CSR:pc`; `AR` = 24-bit `DSR:ar`.

## To extract next (verification pass, each item traceable)
- Full supervisory register enumeration (LR, ELR, EIPC, EINT, ECSR) from Core Manual + names actually implemented in `CPU.cpp SetupInternals`.
- Halt/stop modes + clock-gate registers (`BLKCON`-class SFRs) — needed before writing [[Software/Custom Software]] power-management assumptions.
