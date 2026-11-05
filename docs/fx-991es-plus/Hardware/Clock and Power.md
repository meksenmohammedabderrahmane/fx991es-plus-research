# Clock and Power

## Clocks
| Clock | Evidence | Confidence |
|-------|----------|------------|
| 32.768 kHz subclock | Cylindrical crystal soldered by the COB; standard on all ML610x nX-U8/100 SSR-family parts for RTC + slow timing | High (presence) / Med (exact load caps rating unknown) |
| Main CPU clock | Family spec 0.5–8.192 MHz range generated internally (PLL/sysdiv) from options incl. subclock (ML610901 datasheet figures). Community emulator CasioEmuX models ES-PLUS instruction timing accordingly | Med on actual value used by firmware — never measured |

## Power architecture (observed + family-standard inference)
| Rail | Source | Notes |
|------|--------|-------|
| Main VDD | AAA cell viaasic boost/reg (component silks show small inductor + caps in photos) | Regulates Processor + LCD logic; ML610 parts integrate regulators for internal VDDL/VDDX with external caps (family pattern) — component mapping Med |
| Backup VDD | CR2025 coin cell | Preserves SRAM + RTC when AAA disconnected or off — calculator keeps display/history behind ON |
| LCD bias | generated internally | nX-U8 LCD drivers generate biases from VDD3 (family standard per ML610Q435 datasheet) — Med |

Any voltage claims beyond "battery-LiCR coin + AAA" remain unmeasured → never asserted as fact in this note.
