# E20 — Edition Identification Worksheet (physical fx-991ES PLUS)

> Status: **worksheet ready (2026-11-04)** — every key sequence below verified against source before recommending. Execution on the physical unit: **PENDING** (user performs the presses). E20a (emulator reference run on the provenance-verified GY454XE ROM) produced ground-truth screens; see [[Experiment Log]] row E20a.
>
> **Base assumption Rubric:** the unit is treated as a generic ES-PLUS-family candidate. It is **NOT assumed to be GY454XE-compatible** — that is what this experiment decides. The unit's physical board code was previously recorded as `XS991-HW`, which matches none of the first-edition GY-3xx/GY-4xx codes catalogued by the community, so the self-test version screen is the decisive evidence.

## Why this matters
The chip/firmware revision decides (a) whether any community payload applies at all, (b) which gadget offsets are valid, and (c) what the honest next step is. Rules from [[Experiment Log]]: label everything CONFIRMED/LIKELY/SPECULATIVE, source every claim.

## Safety / expectations (verified, no speculation)
- The self-test **clears data memory and mode settings** on completion. This is documented independently for the ES family (Mike Sebastian, rskey) and confirmed from the decompiled GY454XE diagnostic code: the final screen runs `reset_all` on the next key press (`vendor/gy454xe-decomp/src/asm/diagnostic.asm`, `_diagnostic`). Nothing valuable should be stored first — or its loss accepted.
- The routine also **modifies the diagnostic check bytes** at data address `0x0860E` while it runs (community firmware analysis; empirically confirmed on the GY454XE emulator: the block `0F 0E 0D 0C … 01 00` becomes `00 00 00 00 0B 0A …` inside diagnostic mode and returns to standard after the exit reset).
- **Exiting anywhere via [ON]** performs a full reset and boots normally; the emulator reference confirms the block is restored and the calculator boots normally afterwards. Physically, expect a possible further memory/mode reset at the next power-on — one more reason to accept the wipe up front.
- No hardware equipment involved. Zero cost. Not destructive to hardware.

## Verified key sequences (source table)

| Step | Keys | Source (verbatim basis) |
|------|------|--------------------------|
| Enter diagnostic | **Hold SHIFT + 7, then press ON** (calculator off or on, either works) | TI-Planet walkthrough (critor): *"de maintenir enfoncées les touches SHIFT 7 … de taper ON"* — https://tiplanet.org/forum/viewtopic.php?f=51&t=25063 ; rskey independently: *"invoked by pressing and holding the 7 (seven) and SHIFT keys then pressing the ON key"* — https://www.rskey.org/~mwsebastian/selftest/casio_test.htm ; mechanism confirmed in decompiled GY454XE boot key scan (`diag_init_check`, `diag_initloop`) |
| At the `DIAGNOSTIC / Press AC` splash | **Press 9 quickly** | decompiled `diag_initloop`: the scancode `KI=4, KO=4` (key 9) sets `allow=1` (enters the test sequence); **AC (`KI=4, KO=0x10`) aborts** — matches Thread 7583's community practice and TI‑Planet's *"inviting to press AC … do not press AC … quickly type 9"* |
| Advance the 5 LCD tests | **SHIFT** pressed at each pattern | decompiled `diag_scr_fill_ws` / `diag_scr_box_ws` / `diag_scr_ckb1_ws` / `diag_scr_ckb2_ws` all end in `render_waitshift`; rskey describes the same SHIFT-cycling for older ES models |
| Leave version screen | **AC** | decompiled `diag_checksum`: loops `_render; _check_ac` until AC pressed |

Legend for what the screens do: full-ink → blank → box → checkerboard `01010101` → checkerboard `10101010` → **version/checksum screen** → contrast → 49-key keyboard test → `TEST OK / Reset All / Press AC` → reset.

## Procedure to perform (numbered, with what to record)

Record everything **verbatim**, screen by screen (photos preferred; if no camera, transcribe exactly, character by character). Before starting, note the current memory contents/mode if you care about them.

**Prologue — external evidence (no keys pressed):**
- [ ] Back label: exact model marking, serial number, any secondary code.
- [ ] Cosmetic clues: printed keypad legends (e.g. presence/absence of `x□□` styling differences), case colour/casting.

**Step A — enter diagnostic:**
1. Press nothing else; hold **SHIFT**, then **7** (both down), then tap **ON** once.
2. Expect: `DIAGNOSTIC` on the first line and `Press AC` lower down.
   - [ ] Record exactly what the splash shows (both lines).
   - If you see this splash → proceed to Step B. If nothing appears (normal boot) → retry pressing 9 a bit faster; record the failure mode if it persists.

**Step B — enter the test sequence:**
3. Quickly press **9**.
   - Expected (from the GY454XE reference): the screen goes **fully black** (all segments lit) — first LCD test.
   - [ ] Record whether you get the all-black pattern or something else.

**Step C — advance the five display tests:**
4. Press **SHIFT**. Expected sequence:
   1. all-ink (black), 2. all-blank, 3. box outline, 4. checkerboard `01010101`, 5. checkerboard `10101010`.
   - [ ] For each: describe/draw the pattern; note **any stuck or missing pixel rows/segments** (this is a free hardware defect scan).

**Step D — the decisive evidence (version screen):**
5. After the fifth SHIFT, the **version checksum screen** appears. Expected layout (verified from `diag_checksum`):
   - Line 1: `<ROM reference> Ver<x>` (emulator GY454XE reference renders its stored string; community examples: `GY-455 VerA`, `GY465X VerG`)
   - a `SUM XXXX OK|NG` line (4-hex-digit ROM checksum; `OK` = ROM self-check passes)
   - a `Pd<digit>` field (board strap readout; community: three straps, the third being the P146 pad — thread 7583 p.11)
   - a `Read OK|NG` line
   - `Press AC` prompt at the bottom.
   - [ ] **Record every character of this screen. This single screen is the deliverable.**
   - [ ] Specifically: the exact ROM reference (letters/digits/dashes/exact spacing), the Ver letter, the SUM value, the Pd value, and OK/NG states.

**Step E — contrast screen (optional but cheap):**
6. Press **AC**. Expected: a contrast test display (rskey: `CONTRAST 11h LIGHT DARK` on older ES).
   - [ ] Record the exact text.

**Step F — keyboard test (recommended for completeness):**
7. Press keys one at a time. A counter increments when a key is accepted; the test requires the full matrix (49 keys, order fixed by the firmware). Continue until the screen shows `TEST OK / Reset All / Press AC`.
   - [ ] Note any key that never increments the counter (potential keypad fault).
8. Press **any key** to finish (this performs the documented reset-all) and confirm the calculator reboots normally.

**Step G — after reboot, the free forensics fingerprint (5 seconds, zero risk):**
9. Set **DEG** mode (`SHIFT MODE 3`), and evaluate exactly:
   `arcsin(arccos(arctan(tan(cos(sin(9))))))`
   then subtract 9 (`Ans − 9`) to expose all digits.
   - Known values: `9.00000000733338` ≈ the ES-PLUS/EX-era (OKI-chip) math library line (documented for fx-115ES/fx-300ES by Sebastian's table, for fx-991ES PLUS in thread 7583 p.2 #45); `9.00000000733343` = older HCD62121-era line. **This is a family/chip fingerprint, NOT an edition discriminator** — record it only as corroborating evidence. (This supersedes the earlier draft procedure in [[Hardware/Processor Identification]] — see that note's status line.)
   - [ ] Record the final displayed value and the `Ans−9` digits.

## Result template (fill in)

| Item | Observed |
|------|----------|
| Back label model / serial | |
| Splash line 1 / line 2 | |
| 9-press result | |
| Pattern anomalies | |
| **ROM reference (Ver screen line 1)** | |
| **Ver letter** | |
| **SUM value / OK/NG** | |
| **Pd value** | |
| **Read OK/NG** | |
| Contrast screen text | |
| Key test notes | |
| Forensics `arcsin(arccos(arctan(tan(cos(sin(9))))))` | |
| `Ans − 9` digits | |

## How the answer will be read (known-revision comparison)

Verified reference points from the sources:
- TI-Planet (991ES PLUS official/clone comparison): the official fx-991ES PLUS of that revision displays **`GY-455 VerA`**; the wiki-linked thread lists the 991ES PLUS software references as **`GY-450 VerA`, `GY-455 VerA`, `GY-455 VerB`** across its life; a community example of the version screen format is **`GY465X VerG / SUM 7A03 OK / Pd- Read OK / Press AC`** (thread 7583 p.2 #49); the 991ES(fx-570VN+) variant example is `LY710X VerA`.
- Thread 7583 p.4 #127: the dumped **`GY454XE`** (fx-570ES PLUS) and the 991ES PLUS **`GY455XE`** ROMs differ *"in a byte of model name"* — i.e. same GYX generation, sibling model.
- gyx-decomp README: the **latest** GYX revisions of fx-570/991ES PLUS are `GY454X VerF`/`GY455X VerF` (with a debug menu not present in the decomp source); our archived dump is `GY454XE` (footer at ROM `1:FFFC`-region string table).

Decision rules for the recorded result (labels to apply after data lands):
- Version string **matches the `GY455X/GY454X … VerF` or `GY-455 Ver…` GYX family** → LARGELY-LIKELY: unit is in the same firmware generation as our archived dump and the community tooling; proceed to adaptation reassessment (see FINAL-REPORT E20 section).
- String is a **`GY-45x VerA/B`** form → first-generation 991ES PLUS firmware; gadget offsets from the GYX decomp may not match; treat any payload as revision-specific and re-verify before touching the device.
- String is missing, or the pattern/Pd output is impossible per the verified flow → stops: unit may be a clone/non-GYX hardware; branch to source-level verification before anything else.
- `SUM … NG` on the version screen would indicate a corrupted ROM/boot area (unexpected; investigate before any further step).

## E20a — Emulator reference run (ground truth for comparison)

Run against `vendor/CasioEmuX/models/fx570esplus/rom.bin` (SHA-256 `1a1b575f…71071`, footer `GY454XE`), script `tools/experiments/e20a.lua`, log `artifacts/experiments/e20a-run.log`. Presses: SHIFT(0x07)+7(0x02) held → ON(0xFF=chipset reset) → keep held through boot → 9(0x22) → SHIFT×6 → (exit) ON. Everything below is CONFIRMED in that log.

- Splash captured: `DIAGNOSTIC` / `PRESS AC` exactly as the decomp's string table predicts.
- Check block at `0x860E` in-diagnostic: `00 00 00 00 0B 0A 09 08 07 06 05 04 03 02 01 00` (vs. standard `0F 0E 0D 0C 0B 0A 09 08 07 06 05 04 03 02 01 00` before; restored after the exit reset) — empirically validating thread p.7 #246's firmware analysis.
- Exit via ON: normal reboot confirmed, block restored.
- More than 5 SHIFT presses is harmless: after the version screen the ROM loops on `check_ac` (AC only), so a 6th SHIFT does nothing beyond redrawing the same text; the log's 5th and 6th snapshots are identical.
- Timing note: the `SUM`/`Pd`/`Read` lines of the version screen render considerably later than the first text line (the `_diag_get_checksum` double 0xFFFF-iteration code scan takes on the order of a million emulated instructions); on a real calculator this is a sub-second distraction, but on the device expect line 1 first and the rest appearing after a short pause.

**Reference version screen buffer art (log `after SHIFT advance 5`, first text line; all other LCD rows blank in this snapshot):**

```
  ###  #   #    #  #####     #  #   #       #   #              #####
 #   # #   #   ##  #        ##   # #        #   #   ###  # ##  #
 #      # #   # #  ####    # #    #          # #   #   # ##  # ####
 # ###   #   #  #      #  #  #   # #         # #   ##### #     #
 #   #   #   ##### #   #  ##### #   #         #    #     #     #
  ####   #      #   ###      #  #   #         #     ###  #     #####
```

Reading of the line: begins `GY45`, then a `Ver`-shaped segment, then a two-character code; this is **LIKELY** `GY45 Ver4X`: the diag print (`diag_checksum`, `unk4_1.c`) emits the ROM string table's 4 chars + a literal `Ver` + the pair that follows in the table, and the archived ROM's string table at `1:FFF4` reads `GY454XE `. The exact glyph-level caption is not CONFIRMED because we only have ASCII art to read; when the user performs Step D on the physical unit, a photo of their real screen will settle the caption for *their* revision directly.

## Cross-checks already logged
- `diag_initloop` (decompiled, `src/c/unk/unk4_1.c`): key 9 → allowed; AC → abort; **timeout path also exits** (~"a couple of seconds" window — hence TI-Planet's "quickly").
- Five display screens + version screen + contrast + 49-key test, in that order, from `_diagnostic` and `diag_check_key`.
- `p0 / p1 / p146` strap bits in the emulator's keyboard model (Keyboard.cpp `RecalculateKI`) correspond exactly to the three Pd straps community-documented (thread p.11 #428/#429) — same mechanism, two independent sources.
