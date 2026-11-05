# Firmware Strategy

## Current strategy (evidence-based)
1. **Study layer** (now): ISA + SFR understanding via CasioEmuX against the verified fx-570ES PLUS ROM ([[Firmware/ROM Inventory]]).
2. **Session-scoped execution** (mid-term goal): ROP/hackstring loader approach — custom code runs only transiently; documented honestly in [[Software/Custom Software]].
3. **No persistent firmware replacement** — mask ROM makes it impossible on this silicon class ([[Firmware/Firmware Feasibility]]). If someone's end-goal requires a different permanent firmware, that is route B (new hardware), not this calculator's chip.

## What would change the strategy (only these three, all unlikely)
| Trigger | Effect |
|---------|--------|
| Disproof: the 2011+ ES-PLUS die is actually flash-based | Re-evaluate programming path + EASE compatibility |
| Discovery of an undocumented ROM-paging window (dump >128 KB) | Re-check firmware replacement boundary |
| Direct identification of the die (self-test reveals part number) | Refine silicon-level claims everywhere |

## Guardrails encoded (bearers of bad news welcome)
- Never state or imply "flashed/patched firmware" from an ROP demo.
- Any on-device experiment sequence must be non-destructive key-entry; no voltage in; no hardware writes.
