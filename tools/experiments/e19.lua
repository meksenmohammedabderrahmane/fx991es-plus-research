-- e19.lua — E19: alternate chain entry at the natural [=] execution point
--
-- Evidence so far:
--   * Synthetic entry (CSR=1, PC=0x54EE, SP=0x8DA4): chain executes ~10.4k
--     transitions in ~24k ticks, never reaches the loader's getkeycode gadget
--     (0x0B45E), dies via 0x8C44 epilogue -> garbage at 0xAF830 -> OS loop
--     (PC=0x4836). In-window presses (E18) produce NO loader FB writes.
--   * E14 variant B: typed 100-char line + payload overwrite + [=] hits
--     PC=0x2768 with SP=0x8D4C (top of stack 74 70 00 00), deterministically,
--     twice in a row on consecutive ticks.
--
-- This run reproduces that natural state exactly, but instead of just
-- observing the 0x2768 pass it injects the chain entry *at that point*
-- (CSR=1, PC=0x2768, SP=observed) and watches the FB while pressing '1'/'2'
-- inside the window. If the loader stage engages, (*y)=0xF830 gets 0x31+0x32.
--
dofile("../../tools/experiments/emulib.lua")

local PAYLOAD_HEX =
	"3130e23d3030a032303030f86a273030b244303001012c8531306c743030868b" ..
	"0a44303033333333ee543130b38b4f8b602730306a4f3030268c684f30303334" ..
	"353637383930313260b430308c46313060b43030e23d3030b02c30303333631e" ..
	"3130ec6c"
assert(#PAYLOAD_HEX == 200, "payload must be 200 hex digits")

local KEY_AC = 0x42
local KEY_1  = 0x00
local KEY_2  = 0x10

local FB_LO, FB_HI = 0xF820, 0xF85F
local POLL_EVERY   = 100
local GETKEY_LO, GETKEY_HI = 0x0B45C, 0x0B464 -- getkeycode gadget window

local now_tick = 0
local function pc16() return (cpu.csr << 16) | (cpu.pc & ~1) end

-- framebuffer watcher (same as E16/E18) -----------------------------------------
local prev = {}
local fbev = 0
local function poll(reason)
	for i = 0, FB_HI - FB_LO do
		local b = data[FB_LO + i]
		if b == nil then b = prev[i]
		elseif prev[i] == nil then prev[i] = b
		elseif b ~= prev[i] then
			fbev = fbev + 1
			printf("[E19] FB#%02d %-6s tick=%08d PC=%06X SP=%04X @%04X: %02X->%02X",
				fbev, reason, now_tick, pc16(), cpu.sp, FB_LO + i, prev[i], b)
			prev[i] = b
		end
	end
end

local trace = {}
local trace_start
local lastpc
local getkey_hits = 0
local function tick_trace(n, reason)
	for i = 1, n do
		emu:tick()
		now_tick = now_tick + 1
		local p = pc16()
		if p ~= lastpc then
			lastpc = p
			trace[#trace + 1] = { t = now_tick, pc = p, sp = cpu.sp }
		end
		if GETKEY_LO <= (p & 0xFFFF) and (p & 0xFFFF) <= GETKEY_HI then
			getkey_hits = getkey_hits + 1
		end
		if now_tick % POLL_EVERY == 0 then poll(reason) end
	end
end

print("")
print("================================================================")
printf("[E19] natural 0x2768 entry + FB watch — %s", os.date())
print("================================================================")

printf("[E19] settling 2,000,000 ticks ...")
tick_n(2000000)
now_tick = now_tick + 0 -- tick_n tracked; keep now_tick in sync via emulib_now
now_tick = emulib_now()
printf("[E19] settled: PC=%06X SP=%04X mode=%02X", pc16(), cpu.sp, data[0xF031])

-- ---- reproduce E14 variant B: AC, type 100 '1', overwrite buffer --------------
Keyboard:PressKey(KEY_AC)
tick_n(40000)
Keyboard:ReleaseAll()
tick_n(200000)

print("[E19] typing 100 '1' tokens (event-verified presses)")
local type_ok = true
for i = 1, 100 do
	Keyboard:PressKey(KEY_1)
	local ok = step_until(function()
		return data[0x8154 + i - 1] == 0x31 and data[0x8154 + i] == 0
	end, 60000, 1)
	Keyboard:ReleaseAll()
	tick_n(8000)
	if not ok then
		printf("[E19] ABORT: typing stalled at token %d (tick %d)", i, emulib_now())
		type_ok = false
		break
	end
end
if type_ok then
	printf("[E19] typed 100 tokens; buffer head: %s", buf_hex(0x8154, 0x10):gsub("\n", " "))
	now_tick = emulib_now()
end

assert(type_ok, "E19 could not type the 100-char buffer")

-- inject payload into 0x8154.. exactly like E14's variant B (no pump fill) -------
local adr = 0x8154
for i = 1, #PAYLOAD_HEX, 2 do
	data[adr] = tonumber(PAYLOAD_HEX:sub(i, i + 1), 16)
	adr = adr + 1
end
printf("[E19] payload written to 0x8154..0x%04X; tail: %s", adr - 1,
	buf_hex(0x81B4, 4):gsub("\n", " "))

-- arm 0x2768, press '=', inject chain entry at the very first pass ---------------
local entry_seen = false
local entry_tick, entry_sp, entry_top = 0, 0, "??"
break_at(0x2768, function()
	entry_seen = true
	entry_tick = emulib_now()
	entry_sp = cpu.sp
	entry_top = string.format("%02X %02X %02X %02X",
		data[cpu.sp], data[cpu.sp + 1], data[cpu.sp + 2], data[cpu.sp + 3])
	-- inject: CSR=1 at the natural execution point (PC stays 0x2768)
	cpu.csr = 1
	unbreak_at(0x2768)
end)

printf("[E19] pressing [=] (code 0x30) ...")
Keyboard:PressKey(0x30)
step_until(function() return entry_seen end, 3000000, 1)
Keyboard:ReleaseAll()
if not entry_seen then
	printf("[E19] ABORT: 0x2768 never fired within budget (tick %d)", emulib_now())
	emu:shutdown()
	return
end
printf("[E19] entry pass at tick=%d SP=%04X top=%s -> CSR forced to 1", entry_tick, entry_sp, entry_top)
now_tick = emulib_now()
trace_start = #trace + 1

-- in-window presses: k1='1', k2='2' -> expect one FB write 0x63 at (*y) ----------
local function press_quick(code, name, hold, gap)
	Keyboard:PressKey(code)
	tick_trace(hold, name)
	Keyboard:ReleaseAll()
	tick_trace(gap, name .. "-gap")
	printf("[E19] pressed [%s] done tick=%d; F830=%02X F831=%02X F840=%02X PC=%06X",
		name, now_tick, data[0xF830], data[0xF831], data[0xF840], pc16())
end

tick_trace(2000, "post-entry")
press_quick(KEY_1, "1", 3000, 3000) -- k1 = '1'
press_quick(KEY_2, "2", 3000, 5000) -- k2 = '2' -> expect FB write 0x63
press_quick(0x11, "5", 3000, 5000)  -- k1 = '5'
press_quick(0x22, "9", 3000, 5000)  -- k2 = '9' -> expect 0x6E
tick_trace(60000, "cool")

printf("[E19] trace size: %d transitions since entry", #trace - trace_start + 1)
printf("[E19] getkeycode-window (0x0B45C..0x0B464) PC hits: %d", getkey_hits)
printf("[E19] after window: PC=%06X SP=%04X F830=%02X F831=%02X F840=%02X",
	pc16(), cpu.sp, data[0xF830], data[0xF831], data[0xF840])

-- long tail --------------------------------------------------------------------
tick_trace(1200000, "tail")
printf("[E19] after tail: PC=%06X SP=%04X", pc16(), cpu.sp)

-- dump: entry surroundings + last transitions -----------------------------------
printf("[E19] stack at entry (0x8D4C): %s", buf_hex(entry_sp, 16):gsub("\n", " "))
printf("[E19] last 40 PC transitions since entry:")
local n = #trace
local start = math.max(trace_start, n - 39)
for i = start, n do
	printf("[E19]   t=%08d PC=%06X SP=%04X", trace[i].t, trace[i].pc, trace[i].sp)
end

print("[E19] ==== E19 summary ====")
printf("[E19] FB write events total (incl. cursor blink): %d", fbev)
local line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF830 + i]) end
print("  F830 (row 3): " .. table.concat(line, " "))
line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF840 + i]) end
print("  F840 (row 4): " .. table.concat(line, " "))
printf("[E19] non-blink loader writes: %d", fbev - 52) -- 52-blink baseline from E18
printf("[E19] final PC = %06X SP = %04X", pc16(), cpu.sp)
printf("[E19] total ticks: %d", now_tick)
emu:shutdown()
