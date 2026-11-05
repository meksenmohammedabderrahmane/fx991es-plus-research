# LCD Architecture

## Display facts
| Property | Value | Source | Confidence |
|----------|-------|--------|------------|
| Panel type | Monochrome dot-matrix "Natural-V.P.A.M." display, ~2 line input + answer areas | Casio product page / emulator screen layout | High |
| Controller generation | Driven directly by the MCU's integrated LCD driver: 96 segment × 32 common on ML610901-class (first edition); same class for the xs-revision single-chip | ML610901 datasheet figures + CasioEmuX Screen.cpp structure | Med-High |
| Buffer SFR | `DSR:0xF800..` region — emulator maps a screen buffer here; real firmware writes glyph codes + bitmaps into this region and the LCD block scans it out | CasioEmuX `src/Peripheral/Screen.cpp` regions | High (emulator side); exact real width/com user-mapping unverified |
| Screen mode bits | emulator Screen.cpp handles a screen-mode SFR incl. flip bits (H/V) | Screen.cpp:423-428 | Med |
| Refresh clock | LCD bias/RC oscillator internal; sub-clock 32.768 kHz on board | family datasheet | Med |

## What this means for custom software (goal A/D and G)
- Any ROP/ACE demo that draws does so by writing the screen-buffer SFRs then letting the internal LCD block multiplex it out — no external display bus exists. ⇒ A replacement controller (goal G) must instead **drive the LCD's own FPC lines** (segment/common signals), which is a much harder raw-signal task (96×32 = 128 drive lines + bias levels).
- The FPC wiring of the panel is not yet documented for our board. To assess route G we would need: dot-test reading of FPC traces, or finding the panel part number. (See [[Decisions/Hardware Decisions]].)

## Cross-check available in works
- Community historical research on LCD SFRs (wiki pages: display/storage) — merge quotes into [[Research/Historical Research]] when agent reporting returns.
- Emulator rendering is our *model*: where the emulator deviates from real dots (e.g., pixel-level antialiasing off), note for later validation against real screen captures.
