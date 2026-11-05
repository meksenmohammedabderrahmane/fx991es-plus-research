# Instruction Set (reference skeleton + generation plan)

> Primary sources (local, no network needed):
> - `vendor/fxesplus/docs/instruction-set.txt` — machine-readable opcode **pattern table** same-format used by the disassembler (regex-ish fields: `mmmm0001 1000nnnn ADD {n},{m}` etc.); includes DSR-prefix special forms.
> - `vendor/CasioEmuX/disas/nX-U8_is.txt` (same table family, from the emulator repo, used to build `u8-disas.exe`).
> - `vendor/nXU8100-resources/nX-U8100 Core Instruction Manual.pdf` — official definition (operation semantics, cycle counts).

## Format of the reference (established convention)
- Opcode pattern of 16 bits written as two nibble-annotated rows (`iiiiiiii`, `mmmm`, `nnnn`, `dddd`, `www` are hex/binary digit fields).
- Addressing modes: immediate `#i`, register, `[ERm]`, `[ERm+]`, `[Disp6[FP]]`-style (load/store class lines in the table file).

## Confirmed instruction classes (from the pattern table, verified by building + running u8-disas)
| Class | Examples (pattern → mnemonic) |
|-------|-------------------------------|
| DSR prefix | `iiiiiiii 11100011 DSR<-` ; `dddd1111 10010000 DSR<- Rd` |
| Arithmetic | `mmmm0001 1000nnnn ADD` ; `ADD/ADDC/SUB/SUBC/CMP/CMPC/AND/OR/XOR/MOV` reg+imm forms |
| 16-bit pair ops | `mmm00110 1111nnn0 ADD ER{n*2}, ER{m*2}` ; `MOV ER,ER` ; `CMP ER,ER` (ER = even-indexed pair) |
| Shifts | `SLL/SLLC/SRA/SRL/SRLC` both reg and `#w` forms |
| Load/Store | (table § after line 79: `[ER]`, `[ER+]`, FP/BP-displacement forms) |
| Control flow | conditional branches + long jump/call (`SOAP`/CALL family) — exact list to be extracted in the table build below |

## Generation plan (actual work product)
1. Parse `instruction-set.txt`/`nX-U8_is.txt` with a small script → emit `Architecture/Instruction Set.md#table` + `artifacts/isa-table.csv`.
2. Cross-check each mnemonic against Core Manual chapter headings (manual index list).
3. Collect exemplars from real ROM disassembly (`artifacts/disas_reset_area.txt` shows `SRL R13,R14`, `XOR R8,#0x34`, `RT` patterns — note: disas output uses decimal for `#i`).
4. Validate emulator semantics spot-wise (see [[Experiments/Experiment Log]] for the list) via CasioEmuX + custom micro-programs (toolchain constraints permitting, see [[Software/Toolchain]]).

## Gotchas recorded so far
- `RT` is a real opcode (seen at ROM 0x0006, `1F FE`), not an artifact.
- Unrecognized-opcode fallback in the disas table = "skip 2 bytes" (table header comment) — partial listings must not be treated as complete code.
- The reset entry of the dumped ROM is dense code; the first `0x20` bytes disassemble coherently — early sanity check passed.
