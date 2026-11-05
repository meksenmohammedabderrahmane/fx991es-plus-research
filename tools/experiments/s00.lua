-- S00.lua — Boot observation experiment
-- Console-script, run via: casioemu_x.exe model=models/fx570esplus/model.lua exit_on_console_shutdown
-- with stdin:  dofile('.../tools/experiments/s00.lua')
--
-- Goal: learn (1) boot timeline in emulated ticks, (2) screen-mode SFR states,
-- (3) framebuffer layout behaviour of real firmware, (4) what pressing [1] then [=]
-- does to the input buffer 0x8154 — prerequisites for the E14 injection experiment.
--
-- Everything printed to stdout = the experiment log. No mutation of emulator state
-- beyond pressing two keys on the emulated keypad.

dofile("../../tools/experiments/emulib.lua")

local BOOTTEST = {}

print("")
print("================================================================")
print("[S00] Boot observation — " .. os.date())
print("[S00] ROM under test: models/fx570esplus/rom.bin")
print("[S00] Goal: boot timeline / screen-regime / input-buffer state")
print("================================================================")

-- periodic heartbeat: log tick + screen regs + fb hash --------------------------------
local last_hash = -1
addposttick(function()
	if emulib_now() % 100000 == 0 then
		local h = fb_hash()
		if h ~= last_hash then
			last_hash = h
			printf("[S00] tick=%09d mode=%02X range=%02X contrast=%02X fbhash=%08X", emulib_now(), data[0xF031], data[0xF030], data[0xF032], h)
		end
	end
end)

-- phase 1: at "boot settle" (1.5M ticks ≈ generous for 32 kHz-derived boot) snapshot everything
sched(1500000, function()
	print("[S00] ---- phase 1: boot settled, snapshot ----")
	printf("[S00] tick=%09d", emulib_now())
	printf("[S00] screen SFRs: mode(0xF031)=%02X range(0xF030)=%02X contrast(0xF032)=%02X", data[0xF031], data[0xF030], data[0xF032])
	printf("[S00] PC = %06X, SP = %04X", (cpu.csr << 16) | cpu.pc, cpu.sp)
	print("[S00] framebuffer (0xF800, 33x16, 12 cols visible):")
	print(fb_render())
	print("[S00] non-zero framebuffer bytes:")
	print(fb_w())
	print("[S00] input buffer 0x8154 (0x40 bytes):")
	print(buf_hex(0x8154, 0x40))
	printf("[S00] SFR screen-mode log done; pressing [1] (COMP) via keyinj file now")
	
end)

-- phase 2: press [1] (main menu -> COMP), wait, press [=], wait, snapshot input buffer
sched(1600000, function()
	print("[S00] ---- phase 2: press [1] then [=] ----")
	local f = io.open("../../tools/experiments/key-1.key", "wb")
	f:write(string.char(0x00))
	f:close()
	Keyboard:KeyInject("../../tools/experiments/key-1.key", 200, 300)
	print("[S00] key [1] (code 0x00) injected")
end)

sched(2600000, function()
	print("[S00] snapshot after [1]: framebuffer:")
	print(fb_render())
	printf("[S00] input buffer 0x8154 (0x40 bytes):")
	print(buf_hex(0x8154, 0x40))
end)

sched(2700000, function()
	local f = io.open("../../tools/experiments/key-eq.key", "wb")
	f:write(string.char(0x30))
	f:close()
	Keyboard:KeyInject("../../tools/experiments/key-eq.key", 200, 300)
	print("[S00] key [=] (code 0x30) injected")
end)

sched(3400000, function()
	print("[S00] snapshot after [=]: framebuffer:")
	print(fb_render())
	printf("[S00] input buffer 0x8154 (0x80 bytes):")
	print(buf_hex(0x8154, 0x80))
	printf("[S00] PC = %06X, SP = %04X", (cpu.csr << 16) | cpu.pc, cpu.sp)
end)

-- phase 3: exit
sched(3600000, function()
	print("[S00] ---- done, shutting down ----")
	emu:shutdown()
end)
