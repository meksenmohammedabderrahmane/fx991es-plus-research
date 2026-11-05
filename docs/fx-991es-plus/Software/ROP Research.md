# ROP Research

## Status
- Community-proven technique on fx-ES PLUS family; my unit untested. CasioEmuX provides the re-creation environment (ach. sequence: emulator first, then real calculator).

## Mechanism chain (established by community docs + our repo evidence)
1. **Input representation**: STAT submode/68-mode allows entries beyond normal UIeds; a 100-byte window of raw characters (input copy at RAM `0x8154`).
2. **Basic overflow** (`vendor/fxesplus/docs/basic-overflow.txt`): exact key sequence creates an out-of-bounds write condition in the input parser, letting a hand-built byte string overwrite stack.
3. **Hackstring** (`docs/hackstring-tutorial.txt`): the crafted byte string; built with the *unstable character* trick (cursor-move increments through full character set); payload = nibble-swapped "decimal" digits decoding to `seg:XXXX` ROP chain addresses.
4. **Gadget execution**: return-address slots call ROM gadgets: documented exemplars include `0:7EF8` (`ER8=[ER0]` load), `1:32F2` (`[er0]=er2` store), `0:2760` `strcpy_null`, `0:3136` screen render (trowelib + CasioEmuX break_at(0x2768)).

## Constraints
- Stack instructions are expensive → long chains, partial register control.
- Only code in ROM segments is fetchable (Harvard remap) ⇒ no RAM shellcode.
- Chain length bounded by input window + stack layout (offsets are edition-sensitive).

Community ROP framework established (wiki `rop-chain-explanation`, CC BY-SA, merged from [[Research/Historical Research]]):
- ROP destinations: (a) gadgets ending in `pop pc`; (b) start just after a function's `push lr`; (c) chain ending with `rt` — requires LR pre-set with "good" value (a `set lr` gadget: `call b; pop pc` where `b` is trivial + `rt`); (d) `push lr … pop pc`-style helper functions.
- **The ROP chain lives on the stack and functions clobber it** — chains must restore/continue via copies; this is why RAM-region-copy gadgets matter.
- Payload device = hackstring, decode matched the character map (see [[Software/ROP Research]] ladder).

## Tooling we have

| File | Role |
|------|------|
| `vendor/570-991esp-rop-tools` (trowelib) | gadget database w/ nX-U8 semantic comments |
| `vendor/pyu8rop` | python gadget/chain builder |
| `vendor/anyrop-translator` | chain → hackstring text translator |
| `vendor/fxesplus/tools` | misc: (list function of each script when surveyed) |

## Experiment ladder (planned, see [[Experiments/Experiment Log]])
1. Reproduce basic overflow in CasioEmuX by lua injection (no keys) — verify expected state divergence.
2. Inject a known demo hackstring (e.g. render "CASIO"→scroll) via `inject()` and step the chain.
3. Chain × ROM readback onto screen (dumps ROM bytes to display) in emulator.
4. Only then: on-device reproduction of step 2 — my calc = fx-991ES PLUS; the dump we test against is fx-570ES PLUS: same engine family, but **record every difference**: if our unit is 2nd edition, offsets may differ.

## Rules
- Nothing in this note changes persistent ROM.
- Before anything runs on my unit: repeat full on-device worksheet mode 68 + steps from tutorial and record device responses (non-destructive; only entering key sequences).
