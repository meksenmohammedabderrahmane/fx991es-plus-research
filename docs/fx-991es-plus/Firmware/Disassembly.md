# Disassembly

## Toolchain in use
| Tool | Source | Build | Use |
|------|--------|-------|-----|
| `u8-disas.exe` | `vendor/CasioEmuX/disas` (built locally) | G++ UCRT64 with `-include cstdint` fix (GCC 15) | nX-U8 disassembler; usage `u8-disas file start length out.txt` |
| `oki-u8-disas.cpp` | `vendor/fxesplus/tools/disassembler` | not built yet (same ISA tables, older) | cross-validation second source |
| Rizin/radare2/Ghidra | system-side | TODO install rizin (winget/scoop) with nX-U8 module if it exists | bigger-file navigation + scripting |

Check plan: search for a ready-made nX-U8 module/plugin (Ghidra SLEIGH, radare2 shlr, r2dec…) — record findings; if none, write a loader script for rizin/SLEIGH later. Do NOT assume undocumented modules exist.

## First-pass artifacts
- `artifacts/disas_reset_area.txt` — bytes 0x0–0x40 of `rom.bin`. Shows: dispatch table-ish code, `SRL R13,R14`, immediate XORs on R8, `RT` at 0x6.
- `artifacts/disas_rop_entry.txt` — 0x2760–0x2780 (community-known helper code area used by ROP demos; cross-check vs trowelib gadget notes).

## Coverage plan
| Block | Purpose |
|-------|---------|
| 0x0000–0x00FF | vectors |
| 0x2740–0x27A0 | helper routines (ROP-relevant) |
| 0x7EE0–0x7F10 | [ER8]=[ER0]-type helpers |
| strings sweep | locate tables: mode names, error text, GY454XE-class markers at ROM end |
| full sweep | generate complete listing w/ labels map after SFR-writes analysis from emulator |
