# Interrupts and Peripherals

> Base: CasioEmuX peripheral implementations (per-model), cross-referenced with ML610x datasheets in `vendor/nXU8100-resources/`. Peripherals matter for goal G (custom software driving LCD/keys on-hardware) and for understanding interrupt-based ROP utilities.

## Implemented by emulator for ES-PLUS-class models (source paths all under `vendor/CasioEmuX/emulator/src/Peripheral/`)
| Peripheral | SFR region (segment 0xF data space) | Notes |
|------------|--------------------------------------|-------|
| Screen / LCD buffer | `0xF800` | straight buffer mapped by Screen.cpp; real LCD driver is 96 seg × 32 com on the MCU family |
| RTC | `0xF0C0` | keeps second/time via backup battery |
| Flash regs | `0xF0E0` | present on flash-variant chips; on mask-ROM parts reserved/ignored |
| BLKCON (block clock gate) | `0xF028` | gates peripheral blocks (power-saving) |
| IO ports (IO) | `0xF048` | port drive/direction registers |
| Interrupt regs | `0xF010/0xF014` | enable/edge registers with MIE/ELEVEL |

## Keyboard input matrix
- CasioEmuX models inject key codes (e.g. fx-570ES PLUS model.lua keycodes `0x02` for '7'…, `0x64/0x63/0x62` for '0' '. 'Ans' as matrix codes) — the emulator records the scan codes the firmware expects, which also defines the matrix row/col conventions for any future replacement controller (goal G).

## Timers
- Sub-clock (32.768 kHz) counter block + main-clock timers; used by firmware for key scan, blinking, tones. (Exact timer SFR list for the calculator die: to be enumerated when we do the SFR sweep from the emulator's region table + ROM writes.)

## Validation plan
1. Run emulator; log every SFR write the real firmware makes → compare against datasheet register maps (peripheral identification by *behavior*, not by guess).
2. Cross-check interrupt vector offsets in ROM dump (vectors at segment-0 start; see [[Firmware/Disassembly]]).
