# ROM Inventory & Provenance

> Rule: no binary is trusted without origin + SHA-256. Workspace master record: `fx991esplus-research/artifacts/rom-hashes.txt`.

## Verified binaries
| File | Size | SHA-256 | Provenance | Model | Real HW or emulator |
|------|------|---------|------------|-------|---------------------|
| `fxesplus/dumps/rom.bin` | 131072 | `1a1b575f130b3fa4c79a598881181f5a137edb45e398cd9b78ae5baf9b071071` | user202729/fxesplus repo `dumps/`; matches hash list in `CasioEmuX/models/fx570esplus/readme.txt` | fx-570ES PLUS | REAL hardware dump (per readme provenance) |
| `fxesplus/dumps/segment0.bin` | 65536 | `baa3fd545a67bdb7c312043d257cbf0530ebb4776115e9610f437798d3a28d1c` | same repo | **different revision — see audit below** | real HW (unattributed) |
| `fxesplus/dumps/segment1.bin` | 65536 | `5d72ab3ec72acd0e053720c6c3485bd0e52c45260ca8e1885d11bbf3c8d785ca` | same repo | **different board family — see audit below** | real HW (unattributed) |
| `fxesplus/dumps/font0.bin` | 990 | `1a1ef7d78f65451d84660902dcd1c96452772cfc62cb972de0d3060245fe8d62` | same | — | extracted font data |
| `fxesplus/dumps/font1.bin` | 660 | `90b470ab321a726b78905d71bb8dee886b616050c1c53abf968f306069d2dd65` | same | — | extracted font data |
| `fxesplus/dumps/font2.bin` | 120 | `d8a600caab70906c6276b80b149e6d01fa4cc08ca17a536fcb26e8d8d2e81ccb` | same | — | extracted font data |

## ROM internal identity check (fact)
- Bytes at `rom.bin` end (file offset 0x1FFFD) carry Casio ROM code string **"GY454XE"** — consistent with the GY-4xx board family naming known from cnCalc records (82ES = GY-450, 991ES = GY-455). **Implication:** this dump's board family code matches the fx-991/570 ES-PLUS hardware family; dump provenance is coherent (not a random concatenation or emulator artifact).
- Segment count: dump = 128 KB = 2 × 64 KB segments; single contiguous nX-U8 code space for ES-PLUS per `csr_mask 0x0001`.

## What we do NOT yet have
- A dump originating from **my personal fx-991ES PLUS** (needs either the official 991ES-PLUS emulator + RomDumper, or hardware/dump via ROP on-device).
- Any dump from the 2nd-edition hardware (if my unit is one): unknown.

## Legitimate acquisition routes available (ranking by zero-cost + legality)
1. **Official Casio emulator + RomDumper** (`vendor/RomDumper/dump.c`): documented offsets into `SimU8.dll`; produces ROM+RAM from the *official emulator package*. Cost: official emulator download (free). Note: gives the *emulator's* model ROM — for the 991ES PLUS specifically the community has a separate model config (`CasioEmuX/models/fx991esplus_emu`).
2. **ROP ROM-read on-device** (skilled: community has demonstrated reading ROM bytes out via screen-render gadgets; documented in casiocalc wiki + trowelib gadget db) — real hardware, non-destructive (writes nothing).
3. Hardware debug readout — blocked until pads + programmer case is proven ([[Hardware/Debug Interfaces]]).

## Dump audit (2026-11-01, block-level comparison)
| Test | Result |
|------|--------|
| `segment0.bin == rom.bin[0:65536]`? | No — first difference at byte 0; only 21/1024 64-byte blocks identical |
| `segment0.bin` blocks found anywhere in `rom.bin`? | 21 blocks, all at their own index ⇒ **segment0 = a different ROM revision of the lower half, not a rearrangement** |
| `segment1.bin` blocks found anywhere in `rom.bin`? | 0 of 1024 ⇒ segment1 is **not** from this ROM at all |
| Tails | `rom.bin` ends `…\xFF\xFF\xFF\xFF GY454XE )\x89\x01\x01`; `segment0.bin` ends in zeros (no marker); `segment1.bin` ends `… LY710XA 4\x12\x00\x00` — **board-family code `LY710XA`**, not GY |

⇒ The `dumps/` folder of the fxesplus repo mixes **multiple dump sources/revisions**. `rom.bin` remains the config-backed fx-570ES PLUS GY454XE image (hash-matched). Segment files need their model/revision identified before any further use (tracked in [[Research/Open Questions]]).

## External corroboration found (ecosystem scan)
- **`gyx-decomp`** (Codeberg, maintained; archived GitHub mirror `fxesdev/gy454xe-decomp`): community decompilation project of the ES PLUS **GYX** firmware class — belongs to the same generation as our `GY454XE` dump. Documents: CCU8-built (LARGE/NEAR models), Casio ASM + C mix, SDK `.lib` linking — deep validation resource for our ISA study. Cloned into `vendor/igy454xe-decomp` (archived) and `vendor/gyx-decomp` (live).
| Model dir | hardware_id | real_hardware flag | ROM mask |
|-----------|-------------|--------------------|----------|
| `models/fx570esplus` | 3 (HW_ES_PLUS) | 1 | code reads masked `0x1FFFE` |
| `models/fx991esplus_emu` | 3 | 0 (emulator-only model) | same class |
