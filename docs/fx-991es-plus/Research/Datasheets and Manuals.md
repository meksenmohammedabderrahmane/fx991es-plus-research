# Datasheets and Manuals

## On hand (vendor/nXU8100-resources)
| Document | Notes | Use |
|----------|-------|-----|
| `nX-U8100 Core Instruction Manual.pdf` | The ISA + architecture definition (memory spaces p.12, instruction tables, timing §3.3) | Source of truth for ISA |
| `nXU8100-datasheet-translated.pdf` + original JP datasheet | Official nX-U8/100 spec (per fxesdev: "may be outdated") | registers/peripherals family-level |
| (other ML610x manuals we downloaded separately) | ML610Q435/436/438 user's manuals; ML610901 resources if found | family peripherals + debug details (MIT caution: chip-specific applicability) |

## Flagged as chip-specific (use carefully)
- ML610Q380/383/384/385 manual examples cited by fxesdev intro (different calculator die class; memory-layout citation purpose).
- ML610Q435: same "RISC CPU + LCD" family; useful for debug register names — do NOT treat SFR addresses as calculator die facts.

## Related Casio calculator docs
- Official Casio fx-991ES PLUS manual (functionality-level, RE-irrelevant except UI tests).
- cnCalc / casiocalc wiki pages on 991ES/ES PLUS hardware (second-degree sources; each claim quoted into [[Research/Historical Research]] with URL).

## Gaps
- No datasheet found so far naming the 2011+ ES-PLUS single-chip part or the 2nd-edition part → the die identity remains a research question, not a gap in reading.
- nX-U16/U8 manuals: emulator CPU.cpp references `nX-U16` table for DSR-prefixed displacement forms (ML610 U16-style manual not yet in repo → fetch candidate when needed).
