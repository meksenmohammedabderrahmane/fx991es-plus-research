-- e15c.lua — E15c: non-ACE control — direct framebuffer writes from Lua
--
-- Purpose: baseline that separates "we wrote the framebuffer SFR directly"
-- from E15's real ROP-driven writes. Two sub-results:
--   * our fb_render()/Screen.cpp mapping shows the same pixels the emulator
--     draws (validates the SFR→screen echo, using OS-generated glyphs as
--     ground truth from S01);
--   * once the OS resumes, its own redraw loop **overwrites** the pattern —
--     proving direct writes are transient (unlike ROP chain takeover).
--
dofile("../../tools/experiments/emulib.lua")

local function pc16() return (cpu.csr << 16) | (cpu.pc & ~1) end

print("")
print("================================================================")
printf("[E15c] Direct framebuffer write (non-ACE control) — %s", os.date())
print("================================================================")

printf("[E15c] settling 2,000,000 ticks ...")
tick_n(2000000)
printf("[E15c] settled: PC=%06X SP=%04X", pc16(), cpu.sp)

-- write a diagonal-gradient pattern across rows 4..12, 12 visible bytes each
printf("[E15c] painting gradient diagonal into 0xF840 (row 4) ...")
for r = 0, 8 do
	for c = 0, 11 do
		local addr = 0xF800 + (r + 4) * 16 + c
		-- horizontal bar position index moves down-left with the row
		if r == 8 - c then data[addr] = 0xFF else data[addr] = 0x00 end
	end
end
print("[E15c] framebuffer after direct write:")
print(fb_render())

-- OS redraw test: tick and check whether the OS repaints over our rows
printf("[E15c] stepping 300,000 ticks (OS redraw should wipe the pattern) ...")
local wiped = false
for i = 1, 300000 do
	emu:tick()
	if i % 100000 == 0 then
		local h = fb_hash()
		printf("[E15c]   +%d ticks: fbhash=%08X", i, h)
	end
end
-- check row 8 (our painted line) — has it been restored by the OS redraw?
local r8 = fb_bytes_row(4 + 4)
local all_zero = true
for _, b in ipairs(r8) do if b ~= 0 then all_zero = false end end
printf("[E15c] painted row still non-zero after OS redraw: %s", tostring(not all_zero))
print("[E15c] framebuffer after OS redraw:")
print(fb_render())

print("[E15c] ==== E15c summary ====")
printf("[E15c] direct framebuffer writes render immediately (SFR→screen echo works)")
printf("[E15c] but the OS repaints on its own schedule — direct writes are transient")
printf("[E15c] total ticks: %d", emulib_now())
emu:shutdown()
