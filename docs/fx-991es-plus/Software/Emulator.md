# Emulator

## Chosen implementation: CasioEmuX (active fork) — BUILT ✅
- Build completed on MSYS2 **UCRT64** (GCC 15.2) with SDL2 + SDL2_image + lua5.3 + readline (pacman packages). Warnings only; see `tools/build-cemux.cmd` (workspace).
- Build notes for reproducibility:
  1. Repo ships **placeholder** `src/Gui/imgui/*.{h,cpp}` files containing only the path of the original author's local imgui checkout — replace them with real imgui files from the `imgui/` submodule (done by copy script in session; if re-cloning fresh, re-copy `imgui/*.cpp|*.h`, `imgui/imconfig.h`, `imgui/imstb_*.h`, `imgui/backends/imgui_impl_sdl2.*`, `imgui_impl_sdlrenderer2.*`).
  2. cmd.exe cannot expand `src\*\*.cpp`; the script builds a g++ response file (`obj/sources.txt`) instead.
  3. `-I` paths: `%UCRT64%/include/SDL2`, `%UCRT64%/include/lua5.3`.

## Run instructions (validated model: fx-570ES PLUS)
```
copy vendor\fxesplus\dumps\rom.bin vendor\CasioEmuX\models\fx570esplus\rom.bin
casioemu_x.exe model=models/fx570esplus/model.lua
```
- `model=` accepts model name (Emulator resolves in `models/`); `exit_on_console_shutdown` flag exists for headless-ish runs.
- Lua console: hosted in-process (Emulator::ExecuteCommand), supports `inject()`, `break_at(0x2768)`, ppc readouts, memory dumps. Reference: `models/fx570esplus/model.lua` uses `writeRAM(0x8154, ...)`-style calls in the hackstring demo flows (exact function names from lua bridge — verify against console help `?` at runtime).

## Emulator accuracy to validate (experiment list → [[Experiments/Experiment Log]])
1. Boot screen timings vs real calculator.
2. Integer register/SFR write traps (`0xF014`, `0xF028`).
3. Screen-buffer semantics at `0xF800` (mode + flip bits).
4. Interrupt edge cases (manual §3.3 timing claims; emulator comments).
5. Hackstring injection end-to-end vs real-device behavior known from community videos of demos (device-side validation is later).

## Older CasioEmu (user202729)
- Meson-based, not built here (no meson toolchain); superseded functionally by CasioEmuX; useful as documentation cross-reference.

## Official Casio emulators
- For provenance (RomDumper) and accuracy cross-check of hacks; runs on their licensed binary — use only as reference oracle.
