# PCB Analysis

> Based on 2 user-supplied photographs (top view + angled detail). No electrical measurements taken yet. Photographic observations are facts about the *photos*; functional attributions are marked with confidence.

## Manufacturing identifiers

| Identifier | Location | Interpretation | Confidence |
|------------|----------|----------------|------------|
| `XS991-HW` (twice) | board silkscreen | Board part number. Does not match the older RCA50xxxx / PWB-GYxxxx codes recorded in the casiocalc wiki for fx-ES/ES PLUS boards | Hypothesis: newer board code family (post-2011) — Med |
| `JY7216` | silkscreen | Likely production lot/date code ("JY" + 7216 e.g. year/week). Consistent with Casio batch-date silks on similar calculators | Hypothesis — Low/Med |

## Observed component inventory

| Component | Observation | Attribution | Confidence |
|-----------|-------------|-------------|------------|
| Main COB blob | Single large black epoxy blob, upper area | Microcontroller with on-chip ROM (single-chip generation) | Med (photo) |
| 32.768 kHz crystal | Cylindrical crystal near COB | Sub-clock (32 kHz) for RTC/base timing. Matches all ML610xx nX-U8/100 chips which require a 32.768 kHz subclock crystal | High (part) / Med (function) |
| CR2025 coin cell | Large coin battery holder | Backup power for SRAM + RTC (calculator keeps memory when AAA removed) | High |
| AAA cell contacts | Lower edge | Main battery | High |
| FPC + LCD module | Ribbon to monochrome LCD | LCD connection (see [[Hardware/LCD Architecture]]) | High (observed) |
| Pad clusters | Edge rows with silks labels `P07`, `P12…P32`-style | See dedicated note [[Hardware/Test Pads]] | Med |
| 2×2 unsilked pad cluster | Near COB blob | Candidate TEST/reset pads — UNVERIFIED, needs measurement before any wiring | Low |

## What the single-blob layout implies (edition)

- The 2009 first-edition fx-ES PLUS calculators are described by the community as **two-chip** designs (source: casiocalc wiki lists separate board/photo evidence; second source via user202729 issue #4 discussion). Our board shows **one** COB and no second sizable IC.
- ⇒ Our unit is consistent with the post-2011 single-chip xs-revision generation (or later 2nd edition). Exact edition still requires device-side tests ([[Hardware/Processor Identification]]).
- The community links the 2011+ revision to a 128 KB ROM single-chip part; the part number for the ES-PLUS xs-revision is **not published anywhere the community has found** — treat identity of the exact die as Open.

## Cross-reference
- fx-83GT Plus project annotates an older-era PCB with pads named `P102…P167` (from Cambleton/fx-83GT_Plus repo photos) — **different numbering scheme from ours**; do not transplant those pad meanings onto this board.
- ML610Q435/436/438 datasheets use port naming `P00–Pn3` etc., consistent with the style of our silks (P07, P12…). Naming similarity is weak evidence only — see [[Hardware/Processor Identification]].

## Attachments / photos
- (To be saved by user into this folder as `images/*.jpg` — original photos live only in chat; no binary duplication in vault.)
