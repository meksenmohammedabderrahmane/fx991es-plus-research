-- S01.lua — Boot observation (manual-step edition)
-- Console-script: emulate deterministically, watch boot, then press [1] and [=].
-- Reproduction (from repo root, in UCRT64 env):
--   cd fx991esplus-research/vendor/CasioEmuX
--   PATH="/c/msys64/ucrt64/bin:$PATH" emulator/casioemu_x.exe \
--       model=models/fx570esplus script=emulator/lua-common.lua exit_on_console_shutdown=1 < in.txt
--   in.txt line: dofile("../../tools/experiments/s01.lua")

dofile("../../tools/experiments/emulib.lua")

print("")
print("================================================================")
printf("[S01] Boot observation (manual-step) — %s", os.date())
printf("[S01] ROM: models/fx570esplus/rom.bin (SHA-256 1a1b57…71071, GY454XE)")
printf("[S01] Goal: boot timeline / screen SFRs / framebuffer / input buffer state")
print("================================================================")

-- heartbeat during boot: log interesting changes
local last_fb_hash, last_pc = -1, -1
local function bootlog()
	local pc = (cpu.csr << 16) | (cpu.pc & ~1)
	local h = fb_hash()
	if pc ~= last_pc or h ~= last_fb_hash then
		printf("[S01] tick=%09d pc=%06X sp=%04X mode=%02X range=%02X contrast=%02X fbhash=%08X",
			emulib_now(), pc, cpu.sp, data[0xF031], data[0xF030], data[0xF032], h)
		last_pc, last_fb_hash = pc, h
	end
end

local function bootlog_step()
	return step_until(function() return false end, 4000000, 1)
	-- can't log inside step_until condition; use post-tick style instead:
end

-- simpler: instrumented stepping loop with logging every cycle where PC crosses
print("[S01] --- stepping 2_000_000 ticks, logging changes ---")
local prev_fb = -1
for i = 1, 2000000 do
	emu:tick()
	now = emulib_now() + i
	if i % 100000 == 0 then
		printf("[S01] tick=%09d pc=%06X mode=%02X fbhash=%08X", i, (cpu.csr << 16) | (cpu.pc & ~1), data[0xF031], fb_hash())
	end
end

print("[S01] --- framebuffer after boot settle ---")
printf("[S01] PC = %06X, SP = %04X", (cpu.csr << 16) | cpu.pc, cpu.sp)
printf("[S01] screen mode=%02X range=%02X contrast=%02X", data[0xF031], data[0xF030], data[0xF032])
print(fb_render())
print("[S01] non-zero framebuffer bytes:")
print(fb_w())
print("[S01] input buffer 0x8154 (0x40):")
print(buf_hex(0x8154, 0x40))

-- press [1] (key code 0x00 = main-menu COMP choice)
print("[S01] --- pressing [1] (code 0x00) for 40000 ticks ---")
hold_key(0x00, 40000, 160000)
printf("[S01] PC = %06X, SP = %04X", (cpu.csr << 16) | cpu.pc, cpu.sp)
printf("[S01] input buffer 0x8154 (0x40) after [1]:")
print(buf_hex(0x8154, 0x40))
print(fb_render())

-- press [=]
print("[S01] --- pressing [=] (code 0x30) for 40000 ticks ---")
hold_key(0x30, 40000, 160000)
printf("[S01] PC = %06X, SP = %04X", (cpu.csr << 16) | cpu.pc, cpu.sp)
printf("[S01] input buffer 0x8154 (0x40) after [=]:")
print(buf_hex(0x8154, 0x40))
print(fb_render())

-- press [5] (code 0x11; arbitrary digit test on COMP line)
print("[S01] --- pressing [5] (code 0x11) ---")
hold_key(0x11, 40000, 160000)
printf("[S01] PC = %06X", (cpu.csr << 16) | cpu.pc)
print(buf_hex(0x8154, 0x10))
print(fb_render())

ema_shutdown_guard = nil
print("[S01] ---- S01 complete. You may now run an experiment phase with emu already settled.")
emu:shutdown()
