# Test Pads (pad map)

> Evidence-based only. Every row requires measurement before any use. Photos only, no multimeter/logic analyzer yet.

## Silk-labeled edge pads (observed: `P07`, `P12`–`P32` grade labels)

| Pad(s) | Observation | Hypothesis | Supporting evidence | Confidence | Measure? |
|--------|-------------|------------|---------------------|------------|----------|
| `P07` | silks label by edge | MCU port pin P0-7 (port-style naming) | ML610Q435-Style port naming `Pxy` on same-family datasheets | Low-Med | Yes |
| `P12…P18`, `P2x`, `P32` | one/two-digit+digit labels in rows | MCU PORT pins P1x/P2x/P3x | Same datasheet port-naming style; density matches a perimeter I/O fanout | Low-Med | Yes |
| power pads near battery clip | likely `+3V`/`BAT`/`GND` | Battery nets | Standard layout | Med | Yes (voltage) |

Interpretation rule applied (never transplant): pad **labels on this board** are used only; fx-83GT_Plus repo pads (P102…R167) come from a different generation and are NOT mapped onto this board.

## Un-silked 2×2 cluster near COB (candidate debug pads)

| Position | Hypothesis | Supporting evidence | Confidence | Measure? |
|----------|------------|---------------------|------------|----------|
| cluster pad 1 | TEST1 / RESET_N | Documented nX-U8 debug usage needs TEST0/TEST1 (+RESET on flash parts); 991CNX flash-variant documentation maps P157=RESET_N, P150=VPP, P151=TEST1_N, P152=TEST0 — **for a flash-variant, different pin count; not this board** | Low | Yes (continuity to blob-on probes only in a safe, non-destructive way) |
| cluster pad 2 | TEST0 | as above | Low | Yes |
| cluster pad 3 | VDD/VPP | nX-U8 flash parts want VPP on test-programming; mask-ROM parts don't need VPP | Low | Yes (voltage only, never drive) |
| cluster pad 4 | GND | adjacent to others | Low | Yes |

**Rule:** these pads will NOT be probed with voltage/current until a wiring hypothesis is backed by continuity data. Zero-cost path now: software route ([[Software/ROP Research]]), which needs no pads at all.

## Crystal pads (near 32.768 kHz cylinder)
- Two crystal pads = sub-clock XT0/XT1 per ML610x convention. Confidence: Med. Do not measure with low-impedance meters (load capacitance/drift risk; document only).

## Historical test-pad claims (from the original forum era) — VERIFIED against primary source 2026-11-01
- SopaXorzTaker post #5 (2016-08-21, thread 7583): "P156-P159 which seem to be some kind of a debug port… vertical row of three contact points near P101… might be reserved for testing." → **hypothesis wording**, on the first-generation board (photo `i.imgur.com/bS4C9RD.jpg` — P1xx silks, 2016-era board).
- casiocalc wiki `hardware:PCB (ES)` (photo catalog; board codes RCA501157/PWB-GY380-1 etc.): **contains no confirmed signal mapping for P156–P159.**
- Only later-documented mapping of test-type pins exists for the **flash** hardware class (RESET_N/VPP/TEST conventions in `nX-U8_Debug` context) — different part, not our mask-ROM board. Full record: [[Research/Historical Research]] §5.
- ⇒ **Our board's 2×2 pads remain UNVERIFIED; no community mapping may be transplanted onto them.** The historical hypothesis was never tested to a conclusion in public sources found so far.

## Next actions requiring no equipment
1. Macro photography of the 2×2 cluster for trace-finger routing (visual, no contact).
2. Board-code lookup `XS991-HW` (web).
3. No continuity probing without equipment — resolved later.
