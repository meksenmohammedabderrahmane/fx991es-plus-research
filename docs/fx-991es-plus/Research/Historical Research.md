# Historical Research

> Status: primary-source mining done in-session (subagent runs hit usage limits and produced no reports). Sources fetched 2026-11-01. License note: casiocalc wiki content is CC BY-SA 3.0 — we summarize with attribution and link to originals.

## 1) The original thread — community.casiocalc.org/topic/7583

**"FX-82/-83GT/-115/-991ES PLUS Hacking"** — started by **SopaXorzTaker, 21 Aug 2016**; 514 replies, 13 pages. Key posts (documented in thread index post #1, links in original):

| Topic | Post | Content status |
|-------|------|----------------|
| ROP tutorial | page 9, #61618 | to be pulled when needed (ROP mechanics already systemic in wiki + repos) |
| JS hackstring helper | page 9, #61626 | utility |
| Character map image | page 6, #61010 (+ imgur.com/TTg6Phb.jpg) | source of character-code table |
| Scrolling text demo | page 9, #61627 + video #61628 | proof-of-ACE demo |
| Calculator font | page 9, #61629 | font data |
| How to enter a hackstring (991ES+) | page 8, #61301 (+ short #60990) | procedure |
| **ROM dump hackstring** | page 8, #61348 | author note: "No longer needed now as we already have the ROM" ⇒ **on-device ROM dump was achieved** |
| Hardware description | page 8, #61257 & #61352 (incl. KI/KO ports #61275, timer #61327/#61337, LCD #61344, getkey #61398) | hardware windows into the die |
| OKI datasheet reference | [n203_R06.pdf](https://www.oki.com/jp/Home/JIS/Books/KENKAI/n203/pdf/203_R06.pdf) | LAPIS/OKI official doc (the "rare CPU" documentation) |

## 2) Architecture identification history ( synthesis of quotes)

| Date | Claim | Verdict (what later research showed) |
|------|-------|-------------------------------------|
| 2016-08 | "fx-82/991ES PLUS are SuperH architecture" (frankmar98, SopaXorzTaker post #3, #11 quoting HCD62121/SuperH opcode tables) | Misinterpretation — character codes misread as opcodes of SuperH/HCD62121 |
| 2016-08 | "By the way, SuperH may not be the exact instruction set used. HCD62121's set significantly differs." (post #16) | Transition to "same architecture family, different chip" |
| 2016-08 | "the sequences for Ans and r do not match up with Hitachi instructions… they do match to the SuperH ones though" (post #20) | Still hypothesis-era |
| 2017+ | Hackaday description: "8-bit CPU of an obscure architecture called **nX-U8/100** … manually dumped ROM image allows to execute arbitrary code using ROP" | Correct architecture (LAPIS/OKI nX-U8/100) — settled; matches our own ROM analysis |
| 2024+ | fxesdev repos + `gyx-decomp` treat nX-U8/100 (ROHM incl.) as given | No further doubt |

Root cause of early confusion, per evidence: hackstring bytes *are* the character table, not the instruction encoding; instructions appear only after ROM-relative re-interpretation. (Cross-check with our disassembly: `rom.bin` disassembles coherently only under nX-U8/100 patterns — E2/E3 in [[Experiments/Experiment Log]].)

## 3) Overflow discovery authorship
- Hackaday description: "buffer overflow… originally discovered by a small group of calculator hackers on Baidu" (fx-es(ms) tieba, thread 4663446751). CN-community credit → luego elaborated by casiocalc/wiki into the reproducible "basic overflow".

## 4) Emulator archaeology (recorded disagreement between eras)
- Aug 2016 (thread #29/#36): the then-available fx-82ES emulator (omnimaga-linked) was found to contain no embedded ROM ("only the calculator's software, not hardware is emulated").
- Later state (RomDumper repo, 2021+): **official Casio emulators carry real per-model ROMs** extractable from `SimU8.dll`. Reconciled: different emulator products/versions; the 2016 test targeted an x86-rewritten variant. Both statements are true within their scope. (Cite: thread posts quoted above; `vendor/RomDumper/dump.c`.)

## 5) Test pads P156–P159 — what was CONFIRMED vs HYPOTHESIZED
- **SopaXorzTaker post #5 (2016-08-21)**: "Interesting are P156-P159 which seem to be some kind of a debug port. Also… vertical row of three contact points near P101. These don't go anywhere else, which suggests that they might be reserved for testing." → explicitly speculative wording *("seem", "might")*.
- Post #6: "P101 is solder-bridged on your board. I guess that's a configuration jumper… Maybe has to do something with the lack of a solar battery?" → hypothesis.
- **casiocalc wiki `hardware:PCB (ES)` page** (fetched 2026-11-01): a *photo catalog* only — board codes RCA501157/PWB-GY380-1, RCA503162/PWB-GY381-1, RCA503700/PWB-GY381-1, RCA502171/PWB-GY380A2-1 (+ SR380/381 photos). **No text on this page assigns signals to P156–P159.**
- Verdict: **P156–P159 never received a confirmed public signal mapping for mask-ROM ES-PLUS boards.** The only *documented* multi-pin mapping in the wider ecosystem is the later **flash-variant ClassWiz-inherited hardware** (RESET_N/TEST1_N/TEST0/VPP conventions in `nX-U8_Debug` usage context) — a different part, NOT this mask-ROM generation.
- Consequence for our project (my `XS991-HW` board): 2×2 unsilked pads remain UNVERIFIED (see [[Hardware/Test Pads]]); community-era pad labels use the *other* generation's numbering (P1xx) that doesn't apply to our silks.

## 6) Hackaday project page (fetched 2026-11-01)
- Project **28446: "Casio fx-ES PLUS Reverse Engineering Project"** by SopaXorzTaker (+ user202729), created 2017-12-03, marked "last updated 9 years ago", **0 logs, 0 files** → effectively dormant after launch.
- Description claims (verbatim-level summary): nX-U8/100 identification; Harvard jump-to-arbitrary + manually dumped ROM → ROP; Baidu-group overflow origin; goals = custom loader + documentation; "we have also developed an open-source emulator" (= LBPHacker/CasioEmu, linked from page; the same lineage CasioEmuX forks).
- Real legacy: the GitHub repos + wiki + user202729's projects carried the work after the Hackaday page stalled.
- Comments: 2021 flarn2006 "Where is your research?" → 2022 raspiduino reply pointing to the casiocalc thread (link drift issue documented).

## 7) Wiki pages fetched (with URL + license)
| Page | Key content for us |
|------|--------------------|
| [/hackstring](http://casiocalc.wikidot.com/hackstring) | 100-char (200 EX) input area rule; basic overflow prerequisite; ES PLUS method: fill cache → [AC][◀]; "box"-style method; **r evaluated out-of-submode calls a function-pointer array** → unexpected code (the r-trick); STAT submode timing trick ([AC], ~0.5 s, [ON] during Disp) |
| [/rop-chain-explanation](http://casiocalc.wikidot.com/rop-chain-explanation) | ROP destination classes (pop pc / after push lr / …+rt using LR), "set lr" gadget pattern (call trivial → rt; guards), **why stack must be restored by the chain** (functions corrupt the stack holding the chain) |
| [/hardware:pcb-es](http://casiocalc.wikidot.com/hardware:pcb-es) | first-generation board-code catalog (RCA50xxxx / PWB-GY380/381 series) — no signal mappings |
| [/basic-overflow](http://casiocalc.wikidot.com/basic-overflow) (+`/mode-68`, `/memory-map`, `/timer`, `/display`, `/keyboard`, `/unknown-sfrs`, `/symbol-table`, `/stpacp`, `/applications-of-r`) | not yet fetched — fetch on demand per topic |

## 8) External links inventory (from thread index)
- OKI nX doc: https://www.oki.com/jp/Home/JIS/Books/KENKAI/n203/pdf/203_R06.pdf
- Thread index links (listed in §1) — collect full text of specific posts later via per-post fetch (pageN + #entry ID format works).
- Baidu fx-es(ms) thread: http://tieba.baidu.com/p/4663446751 (CN; historical origin)
- cnCalc thread on emulator glitch: http://www.cncalc.org/thread-6854-1-5.html
- 2016-era fx-82ES emulator resource (omnimaga): superseded — the official Casio emulators are now the ROM source.

## 9) Cross-check ledger (community claim vs our evidence)
| Community claim | Our independent check | Agreement |
|-----------------|----------------------|-----------|
| SuperH-like architecture (2016) | ROM disassembles cleanly as nX-U8/100; not SuperH | community later self-corrected; archaeological record kept |
| "we already have the ROM" (2017) | rom.bin GY454XE footer + hash match + real firmware strings | ✅ |
| Hackstring input area 0x8154, 100-byte window | `CasioEmuX` model.lua + hackstring-tutorial.txt agree | ✅ |
| ROP destination classes (wiki) | `trowelib` gadget semantics match (`pop pc`, `rt`, LR use) | ✅ |
| Board codes RCA501157/PWB-GY380/381 (2010-era) | Our board = `XS991-HW` — different family | different boards shown; updated as expected |
