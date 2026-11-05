-- e16.lua — E16: ROP data-loader event logger / keycode calibration
--
-- Evidence so far (E15, E15b, E15c):
--   * chain entry (CSR=1, PC=0x54EE, SP=0x8DA4) runs the payload; two
--     iterations fired *before any key press* (C0 -> FB F830 and F840),
--     i.e. the payload loop advances its write pointer by 0x10 (a display
--     row) per iteration, and its idle k1+k2 sum is a constant 0xC0.
--   * E15's pair polls watched a stale cursor (F830/F831) so they never
--     caught a real write; this run logs every FB-region write event on
--     the fly instead, tagged with tick, PC and CPU state.
--
-- Questions this run answers:
--   Q1. Idle-iteration rate and write-address progression (stride).
--   Q2. Does a single key press change k (-> byte value vs idle 0xC0)?
--   Q3. Is the chain still executing (PC sane) at each write?
--
dofile("../../tools/experiments/emulib.lua")

local PAYLOAD_HEX =
	"3130e23d3030a032303030f86a273030b244303001012c8531306c743030868b" ..
	"0a44303033333333ee543130b38b4f8b602730306a4f3030268c684f30303334" ..
	"353637383930313260b430308c46313060b43030e23d3030b02c30303333631e" ..
	"3130ec6c"

local FB_LO, FB_HI = 0xF820, 0xF85F   -- rows 2..5 (written region observed in E15)
local POLL_EVERY   = 100     -- ticks between FB-region polls
local now_tick     = 0

local function pc16() return (cpu.csr << 16) | (cpu.pc & ~1) end

-- event watcher ---------------------------------------------------------------
local prev = {}
local function snapshot()
	for i = 0, FB_HI - FB_LO do
		prev[i] = data[FB_LO + i] or 0
	end
end
local events = 0
local function toint(v)
	if type(v) == "number" then return v end
	return tonumber(v) or 0
end
local function poll(reason)
	for i = 0, FB_HI - FB_LO do
		local b = data[FB_LO + i]
		if b == nil then
			b = prev[i] -- unmapped: treat as unchanged
		elseif prev[i] == nil then
			prev[i] = b -- first observation = baseline, not an event
		elseif b ~= prev[i] then
			events = events + 1
			printf("[E16] W#%02d %-8s tick=%08d PC=%06X SP=%04X @%04X: %02X->%02X",
				events, reason, toint(now_tick), toint(pc16()),
				toint(cpu.sp), toint(FB_LO + i), toint(prev[i]), toint(b))
			prev[i] = b
		end
		prev[i] = b or prev[i]
	end
end
local function tick_poll(n, reason)
	for i = 1, n do
		emu:tick()
		now_tick = now_tick + 1
		if now_tick % POLL_EVERY == 0 then poll(reason) end
	end
end

print("")
print("================================================================")
printf("[E16] ROP loader event calibration — %s", os.date())
print("================================================================")

-- boot settle ------------------------------------------------------------------
printf("[E16] settling 2,000,000 ticks ...")
tick_poll(2000000, "boot")
printf("[E16] settled: PC=%06X SP=%04X mode=%02X", pc16(), cpu.sp, data[0xF031])

-- inject payload + pump region (same as E15) -----------------------------------
local bytes = {}
for i = 1, #PAYLOAD_HEX, 2 do bytes[#bytes + 1] = tonumber(PAYLOAD_HEX:sub(i, i + 1), 16) end
for i, byte in ipairs(bytes) do data[0x8154 + i - 1] = byte end
for addr = 0x8154, 0x8DFF do
	data[addr] = bytes[(addr - 0x8154) % 100 + 1]
end
print("[E16] payload injected, region 0x8154..0x8DFF pumped")

-- phase A: launch chain, watch idle behaviour ----------------------------------
snapshot()
cpu.csr = 1
cpu.pc = 0x54EE
cpu.sp = 0x8DA4
printf("[E16] chain launched at tick %08d", now_tick)
printf("[E16] --- phase A: idle observation, 1,500,000 ticks ---")
tick_poll(1500000, "A-idle")
printf("[E16] after phase A: %d write events, PC=%06X SP=%04X, F830/F831/F840=%02X %02X %02X",
	events, pc16(), cpu.sp, data[0xF830], data[0xF831], data[0xF840])

-- phase B: single key presses, watching writes ---------------------------------
local function press_watch(code, name, wait_ticks)
	printf("[E16] --- press [%s] (code %02X) ---", name, code)
	local before = events
	Keyboard:PressKey(code)
	tick_poll(40000, "press-" .. name)
	Keyboard:ReleaseAll()
	tick_poll(wait_ticks, "gap-" .. name)
	printf("[E16]   events after press: %d (delta %d), PC=%06X F831=%02X F840=%02X F850=%02X",
		events, events - before, pc16(), data[0xF831], data[0xF840], data[0xF850])
end

press_watch(0x00, "1", 400000)
press_watch(0x10, "2", 400000)
press_watch(0x11, "5", 400000)
press_watch(0x30, "=", 400000)

-- final byte-state census ======================================================
print("[E16] --- FB event summary ---")
printf("[E16] total write events: %d", events)
local line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF820 + i]) end
print("  F820 (row 2): " .. table.concat(line, " "))
line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF830 + i]) end
print("  F830 (row 3): " .. table.concat(line, " "))
line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF840 + i]) end
print("  F840 (row 4): " .. table.concat(line, " "))
line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF850 + i]) end
print("  F850 (row 5): " .. table.concat(line, " "))
print("[E16] final framebuffer:")
print(fb_render())
printf("[E16] total ticks: %d", now_tick)
emu:shutdown()
