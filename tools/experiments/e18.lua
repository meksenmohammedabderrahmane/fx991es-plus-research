-- e18.lua — E18: keys pressed INSIDE the ~24k-tick chain-execution window
--
-- Evidence (E15, E15b, E16, E17):
--   * Chain entry (CSR=1, PC=0x54EE, SP=0x8DA4) executes ~10.4k ROM-gadget
--     transitions in about 24k ticks, then falls into the OS main loop
--     (PC=0x4836). E17's presses all landed AFTER that window.
--   * The payload's loader stage (new_loader.asm) blocks per iteration on
--     getkeycode() x2 and writes (k1+k2)&0xFF to (*y); on device y starts at
--     0xF830 (patched in payload comment/byte "30F8").
--   * FB writes seen so far are only the firmware cursor blink at 0x00B3xx.
--
-- This run presses '1' and '2' (pair -> 0x31+0x32 = 0x63 expected at (*y))
-- starting a few thousand ticks after launch, keeps the FB watch running and
-- traces every PC transition, dumping the tail around chain-death.
--
dofile("../../tools/experiments/emulib.lua")

local PAYLOAD_HEX =
	"3130e23d3030a032303030f86a273030b244303001012c8531306c743030868b" ..
	"0a44303033333333ee543130b38b4f8b602730306a4f3030268c684f30303334" ..
	"353637383930313260b430308c46313060b43030e23d3030b02c30303333631e" ..
	"3130ec6c"

local FB_LO, FB_HI = 0xF820, 0xF85F
local POLL_EVERY   = 100

local now_tick = 0
local function pc16() return (cpu.csr << 16) | (cpu.pc & ~1) end

-- watchers ---------------------------------------------------------------------
local prev = {}
local fbev = 0
local function poll(reason)
	for i = 0, FB_HI - FB_LO do
		local b = data[FB_LO + i]
		if b == nil then b = prev[i]
		elseif prev[i] == nil then prev[i] = b
		elseif b ~= prev[i] then
			fbev = fbev + 1
			printf("[E18] FB#%02d %-6s tick=%08d PC=%06X SP=%04X @%04X: %02X->%02X",
				fbev, reason, now_tick, pc16(), cpu.sp, FB_LO + i, prev[i], b)
			prev[i] = b
		end
	end
end

local trace = {}
local lastpc
local function tick_trace(n, reason)
	for i = 1, n do
		emu:tick()
		now_tick = now_tick + 1
		local p = pc16()
		if p ~= lastpc then
			lastpc = p
			trace[#trace + 1] = { t = now_tick, pc = p, sp = cpu.sp }
		end
		if now_tick % POLL_EVERY == 0 then poll(reason) end
	end
end

print("")
print("================================================================")
printf("[E18] in-window key presses — %s", os.date())
print("================================================================")

printf("[E18] settling 2,000,000 ticks ...")
tick_trace(2000000, "boot")
printf("[E18] settled: PC=%06X SP=%04X mode=%02X", pc16(), cpu.sp, data[0xF031])
local boottrace = #trace

-- inject + pump -----------------------------------------------------------------
local bytes = {}
for i = 1, #PAYLOAD_HEX, 2 do bytes[#bytes + 1] = tonumber(PAYLOAD_HEX:sub(i, i + 1), 16) end
for i, byte in ipairs(bytes) do data[0x8154 + i - 1] = byte end
for addr = 0x8154, 0x8DFF do
	data[addr] = bytes[(addr - 0x8154) % 100 + 1]
end
printf("[E18] injected/pumped; trigger 0x8DA4 = %02X %02X (payload bytes 53-54: %02X %02X)",
	data[0x8DA4], data[0x8DA5], bytes[53], bytes[54])

-- launch -----------------------------------------------------------------------
cpu.csr = 1
cpu.pc = 0x54EE
cpu.sp = 0x8DA4
printf("[E18] chain launched at tick %d", now_tick)
local launch_event = #trace + 1

-- immediate key presses inside the execution window ------------------------------
local function press_quick(code, name, hold, gap)
	Keyboard:PressKey(code)
	tick_trace(hold, name)
	Keyboard:ReleaseAll()
	tick_trace(gap, name .. "-gap")
	printf("[E18] pressed [%s] done tick=%d; F830=%02X F831=%02X F840=%02X PC=%06X",
		name, now_tick, data[0xF830], data[0xF831], data[0xF840], pc16())
end

-- give the chain ~3k ticks to reach its first getkeycode call
tick_trace(3000, "post-launch")
press_quick(0x00, "1", 3000, 3000)   -- k1 = '1'
press_quick(0x10, "2", 3000, 5000)   -- k2 = '2'  -> expect one FB write 0x63
press_quick(0x11, "5", 3000, 5000)   -- k1 = '5'
press_quick(0x22, "9", 3000, 5000)   -- k2 = '9'  -> expect 0x35+0x39 = 0x6E
tick_trace(60000, "cool")

printf("[E18] trace size: %d transitions (boot baseline %d)", #trace, boottrace)
printf("[E18] after window: PC=%06X SP=%04X F830=%02X F831=%02X F840=%02X",
	pc16(), cpu.sp, data[0xF830], data[0xF831], data[0xF840])

-- long tail: is any loader loop still alive? ------------------------------------
tick_trace(1200000, "tail")
printf("[E18] after tail: PC=%06X SP=%04X", pc16(), cpu.sp)

-- trace dump --------------------------------------------------------------------
printf("[E18] last 40 PC transitions (excluding boot):")
local n = #trace
local start = math.max(boottrace + 1, n - 39)
for i = start, n do
	printf("[E18]   t=%08d PC=%06X SP=%04X", trace[i].t, trace[i].pc, trace[i].sp)
end

-- summary -----------------------------------------------------------------------
print("[E18] ==== E18 summary ====")
printf("[E18] FB write events total (incl. cursor blink): %d", fbev)
local line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF830 + i]) end
print("  F830 (row 3): " .. table.concat(line, " "))
line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF840 + i]) end
print("  F840 (row 4): " .. table.concat(line, " "))
printf("[E18] final PC = %06X SP = %04X", pc16(), cpu.sp)
printf("[E18] total ticks: %d", now_tick)
emu:shutdown()
