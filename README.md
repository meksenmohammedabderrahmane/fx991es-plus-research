# fx-991ES PLUS reverse engineering notes

Research notes, experiment logs and emulator tooling from a personal project to understand the Casio fx-991ES PLUS scientific calculator, from the PCB down to the CPU instruction set, and to find out what it realistically takes to run our own code on the original hardware.

Everything here was produced on my own calculator and on a lawfully obtained community ROM dump of its sibling model (fx-570ES PLUS). Nothing was done to anybody else's device.

## Why

The fx-991ES PLUS runs on Casio's nX-U8/100 architecture (an OKI ML610x class die, mostly undocumented for this board). Around 2016 the casiocalc community found ROP and hackstring tricks that appear to run real code on the ES PLUS family, but the claims are hard to verify today: threads are old, the exact firmware revisions involved are unclear, and hardly anyone can reproduce the work on a concrete unit. This project tries to put that fog into order.

## What is in this repository

```
docs/     knowledge base (formatted for Obsidian, readable as plain markdown too)
report/   FINAL-REPORT.md, the master document of the project
images/   two photos of my unit's PCB (board code XS991-HW, silkscreen JY7216)
tools/    Lua scripts that drive the CasioEmuX emulator, plus build/run helpers
artifacts/  experiment logs, ROM hash lists, small disassembly listings
```

The `docs/` folder is an Obsidian vault, so cross references appear as `[[wiki links]]`. On GitHub they just render as text, but every note is self contained. Start with these three:

- `docs/fx-991es-plus/00 - Dashboard.md`, project status at a glance
- `docs/fx-991es-plus/01 - Project Overview.md`, scope and rules
- `report/FINAL-REPORT.md`, everything the project concluded so far

Useful notes inside `docs/`:

- `Architecture/`, the nX-U8/100 CPU, registers, memory map, interrupts
- `Hardware/`, PCB analysis, LCD, keyboard matrix, processor identification, test pads
- `Firmware/`, ROM inventory and provenance, disassembly notes, why firmware replacement is a dead end (mask ROM)
- `Software/`, the emulator setup, toolchain, and the ROP research state
- `Experiments/`, the full experiment log (S00, S01, E14 to E19, E20a) and the E20 device worksheet
- `Research/Historical Research.md`, what the 2016 casiocalc threads actually claimed, with links

The notes follow a strict labelling rule: every claim is tagged CONFIRMED, LIKELY, SPECULATIVE or UNKNOWN, and every claim carries a source. Failed experiments are recorded, not deleted.

## What is deliberately not in this repository

To respect copyright:

- No Casio ROM dumps. Not for the fx-570ES PLUS, not for anything else.
- No decompiled Casio firmware source trees.
- No third-party repositories republished wholesale.

These were used locally during the research and are credited to their authors in `docs/fx-991es-plus/Repositories/Repository Inventory.md` and in the report, with links where they are still findable. If you want to repeat the emulation experiments you need to obtain a ROM dump yourself and check your local law. One exception: `artifacts/experiments/payload-331.hex` is a 2 KB community hackstring payload from the casiocalc ES thread, kept because the E14 to E19 experiment logs reference it byte for byte.

The small disassembly listings in `artifacts/` are my own working notes derived from that local research copy. They are kept because the experiment results make no sense without them.

To be clear about what was and was not achieved: no custom code execution, no framebuffer output and no ROM dump was achieved on any physical calculator in this project. The community payloads were tested in an emulator only, and they did not reproduce there either. The report says this plainly.

## Emulation

The emulator used is CasioEmuX (a community emulator for the nX-U8/100 based Casios), built locally from source with a real ROM image passed at runtime. All experiments are Lua scripts that press keys, poll the framebuffer and dump memory, so every run is reproducible:

- `tools/build-cemux.cmd`, build script
- `tools/experiments/*.lua` and `tools/experiments/run-*.cmd`, one script per experiment
- `artifacts/experiments/*.log`, the captured output of each run

Experiment index, one line each:

- `S00`, `S01`: emulator smoke tests, vector page and string sweep of the local ROM copy
- `E14`: baseline trace of the community payload #331 entry, boot to failure point
- `E15`, `E15b`, `E15c`: framebuffer write tracking, keycode calibration attempts
- `E16`, `E17`, `E18`: chain window tracing and in-window key presses, loader handshake never reached
- `E19`: the alternate natural entry point, deterministic lockup instead of the loader
- `E20a`: full reference run of the built-in diagnostic self test on the emulator, as ground truth for the device worksheet

Phase 3 verdict of the log: the community #331 loader does not engage on the GY454XE dump under either documented entry path in CasioEmuX. The forum claim remains unreproduced here, and possible reasons are discussed in the report.

## The device worksheet

`docs/fx-991es-plus/Experiments/E20 Worksheet.md` is a ready to use, zero cost, non destructive procedure to identify the exact firmware revision of a physical fx-991ES PLUS using only the built-in diagnostic self test (SHIFT 7 ON, then 9, then SHIFT to advance). Every key sequence in it was checked against the original sources before being recommended: the TI-Planet walkthrough, Mike Sebastian's rskey self test pages, and the decompiled diagnostic code of the GY454XE dump. It also corrects a common mistake: the well known `arcsin(arccos(arctan(tan(cos(sin(9))))))` trick is a chip generation fingerprint, not an edition identifier.

Expect the self test to clear the data memory and mode settings when it completes. The worksheet says where and why. Do not store anything you care about first.

## Sources that made this possible

- casiocalc forum, the long ES chain thread (thread 7583) and its wiki, by SopaXorzTaker, user202729 and others
- fxesplus.github.io and the fxesplus-master repository, hackstring and hardware documentation
- CasioEmuX and the gy454xe / gyx decompilation projects, which made the firmware readable
- Mike Sebastian's rskey calculator self test collection
- TI-Planet forum, critor's calculator diagnostic walkthrough
- the nX-U8/100 resources collection and LAPIS/OKI official manuals for the general architecture

Exact links live in the docs, in the report and in the repository inventory note.

## License

The notes, tools and logs in this repository are under the MIT license, see `LICENSE`. Casio's firmware, the community repositories linked above and forum posts belong to their respective authors.
