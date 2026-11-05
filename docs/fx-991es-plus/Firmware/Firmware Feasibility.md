# Firmware Feasibility (F)

## Verdict up front (with exact reasoning)
**Permanent firmware replacement on the original silicon: NOT possible, with High confidence**, because:
1. The 2011+ single-chip generation uses **mask ROM**: firmware patterned into a metallization layer at the factory. There is no flash cell to electrically rewrite. (Class-level fact for masks parts; consistent with every ES-PLUS community result to date — nobody has ever rewritten ES-PLUS ROM.)
2. On-chip debug (family feature) enables **read/step**, not reprogramming. Programming pathways documented in family datasheets apply to **flash variants** ("Q"-suffix parts in LAPIS part-number conventions). Our part class is not Q.
3. Offline modifications of the dump only work in an emulator.

## What IS possible without hardware modification
| Achievable | Mechanism | Where recorded |
|------------|-----------|----------------|
| Run arbitrary bytes via ROP (transient) | RAM-state exploit at boot routine level | [[Software/ROP Research]] |
| Replace runtime behaviour *for a session*: custom menus, screens, functions | ROP + screen-buffer SFR writes; demo status: community demonstrated scrolling text etc. | same |
| Persist a "bootstub-like" behaviour | Not by ROM writing — but the calculator re-enters its boot routine after power loss; any on-device method must re-inject each power cycle | community state of art; confirm details in [[Research/Historical Research]] |

## Nuance to keep honest
- "Permanent firmware replacement" ≠ "persistent behavior". The second can be approached (e.g., re-triggering exploit chains at each reset via battery-preservation quirks), but ROM bytes remain factory-original. Any claim of the first is false.
- Flash programming: if a flash-class variant ever were identified inside a Casio calculator board (not our board), the EASE-class programmer + documented VPP/TEST pads MIGHT apply — none verified for our hardware.

## If F must be truly permanent
Route G ([[Decisions/Hardware Decisions]]) replaces the control chip entirely: keep the LCD + keypad and drive them from a new MCU — reuse of hardware without firmware. Feasibility unmeasured (LCD voltages/timings unknown yet).
