# Debug Interfaces

## What exists (documented, family-level)
ML610x nX-U8/100 parts carry an on-chip debug (ICE) function. LAPIS datasheets for the family (e.g. ML610Q435) describe:
- **2-wire serial debug**: dedicated TEST clock + data under control of TEST mode pins, running at up to 2.5 MHz (clock-data bit rate from community/family docs).
- Debug register address space: 7-bit address, 16-bit values.
  - Unlock: write key `0xAAFE` to register `0x00` (per commercial-tool reverse engineering and nX-U8_Debug project docs).
  - Chip-ID/debug-info regs: `0x40–0x43`, `0x50–0x53`.
- TEST0/TEST1 mode-pin meanings (F2=TEST0, E1=TEST1/RESET in some packages; the exact mapping package-by-package on QFP/QLF differs — always read the specific datasheet).
Sources: `vendor/nX-U8_Debug` (FPGA bridge design: rtl/nxu8_debug.v, top.lpf pin constraint file, interface/ scripts incl. key brute-force), datasheets under `vendor/nXU8100-resources/`.

## Implementations in reach
| Tool | Type | Notes | Verified? |
|------|------|-------|-----------|
| nX-U8_Debug (vendor repo) | FPGA bridge on iCESugar-Pro (ECP5) + UART 115200 | Full protocol implementation; author's board usage = 991CNX flash part | Protocol code reviewed; not yet run on our board |
| EASE-1000 / uEASE / Nano-EASE | Official OKI/LAPIS debugging programmers | Support on-chip ICE of nX-U8/100 parts. Compatibility with the calculator's masked custom die unknown | No — lead only |
| SimU8 (official Casio emulator DLL) | Offline emulator-side inspection | RomDumper extracts ROM/RAM from the official emulators via `SimU8.dll+0x16CE20` state struct (`vendor/RomDumper/dump.c`) | Used for community ROM dumps (fx-570ES PLUS) |

## Constraints for THIS board (mask-ROM single-die)
- No flash ⇒ **no flash-programming path**: EASE tool "programming" features cannot apply; the part is mask ROM by construction unless a flash-variant ("Q"-suffix on part number in datasheet nomenclature) is present.
- The 2011-era CNX research determined TEST pins for the **flash 991CNX** (P157/P150/P151/P152). Mask-ROM ES-PLUS boards in the original thread era were never publicly verified for the equivalent pads (contrast hypothesis vs confirmed — see [[Research/Historical Research]] pending merge).
- ⇒ For our single-blob board: treat debug-interface existence as **family-capable but board-unproven**. Nothing here justifies hardware purchase: primary path stays software ([[Software/ROP Research]]).

## What the 2-wire interface *could* theoretically do for us (if pads confirmed)
1. Halt CPU / step / read registers & RAM.
2. Possibly fetch ROM contents through the CPU's debug path (validation target: confirm on a real ML610x part first — none in hand).
3. NOT firmware rewrite (no flash cell present).
