# Toolchain

## Available nX-U8/100 toolchain (studying, not yet used to build)
- `vendor/build-tools/mach/oki-u8/`: OKI/LAPIS u8 SDK pieces — `ccu8.exe` (C compiler), `Rasu8.exe` (linker/assembler), `ohu8.exe` (hex converter), `.DCL` descriptor files for ML6104xx parts.
- **No ML610901 DCL** in the drop — meaning commissioning a build *for the calculator die* needs a descriptor file that isn't here; possible workarounds:
  1. Build with the closest DCL and post-process the output (risk: memory layout differs).
  2. Hand-assemble small blobs via custom tools (pyu8rop-built assembler or our own ISA table tool).
- Licensing: the drop is **leaked** material — we use it for study/reference only, not distribution. Any code we write for the calculator should NOT rely on leaked components (assembler can be built from the ISA table instead).

## Our own minimal toolchain plan (clean, license-safe)
1. ISA table (already in `instruction-set.txt` format) →
2. assembler emitting 16-bit words (nasm-style syntax mapping to the table patterns),
3. ELF-less flat binary layout loader for the emulator (CasioEmuX `memory = ...`? check ModelInfo for run-time injection API),
4. optionally a tiny C library subset to call helpers.

## Practical sequence toward custom code (goal)
1. Emulator test harness: python/CasioEmuX-lua `inject()` places code+setup in RAM — but note RAM execution impossible ⇒ our custom blob must be *ROP chain* or *ROM-located helper* — the toolchain must target **gadget-compatible ROM addresses** for a demo; for pure emulator simulation of hypothetical custom firmware, CasioEmuX can be pointed at a modified ROM image (artificial "test ROM") — allowed as offline experiment only.
2. Tools dir: our assembler source plan `fx991esplus-research/tools/` (to be written).
