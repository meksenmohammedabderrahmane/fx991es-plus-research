-- e17.lua — E17: press keys DURING the chain's active window
--
-- Evidence (E15, E15b, E16):
--   * E16: after chain entry (CSR=1, PC=0x54EE, SP=0x8DA4) the chain executes
--     ~1.4M ticks of ROM-gadget code (E15's PC transitions) and returns to the
--     OS main loop (PC=0x4836 SP=8DE2). No FB writes besides the periodic
--     cursor blink (00<->C0 at rows 2..5, firmware PC=0x00B3xx, ~152.7k ticks).
--   * E15's key pairs were pressed AFTER that window (missed); the loader's
--     getkeycode gadget must consume presses while the chain is still running.
--   * Loader (new_loader.asm = payload #331): byte = (k1+k2) & 0xFF written to
--     (*y); per keypairs.py/compiler typing token keycodes: getkeycode('1') =
--     K_1 = 0x31 etc.; idle garbage previously seen as constant C0.
--
-- Experiment: launch chain, then press '1', '2', '5', '=' singly inside the
-- first 300k ticks (pairing pattern from the loader: each write consumes two
-- getkeycode calls), watching every FB write and PC transitions.
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

-- FB write-event watch ---------------------------------------------------------
local prev = {}
local events = 0
local function poll(reason)
	for i = 0, FB_HI - FB_LO do
		local b = data[FB_LO + i]
		if b == nil then b = prev[i]
		elseif prev[i] == nil then prev[i] = b
		elseif b ~= prev[i] then
			events = events + 1
			printf("[E17] W#%02d %-6s tick=%08d PC=%06X SP=%04X @%04X: %02X->%02X",
				events, reason, now_tick, pc16(), cpu.sp, FB_LO + i, prev[i], b)
			prev[i] = b
		end
	end
end
local function tick_poll(n, reason)
	for i = 1, n do
		emu:tick()
		now_tick = now_tick + 1
		if now_tick % POLL_EVERY == 0 then poll(reason) end
	end
end

-- PC transition trace -----------------------------------------------------------
local trace = {}
local function start_trace() trace[#trace + 1] = { tick = now_tick, pc = pc16(), sp = cpu.sp } end
local function stop_trace(label, maxshow)
	local first = trace[1]
	local last  = trace[#trace]
	printf("[E17] trace %s: %d PC-change events: first=%06X@%d last=%06X@%d",
		label, #trace, first.pc, first.tick, last.pc, last.tick)
	local step = math.max(1, math.floor(#trace / maxshow))
	for i = 1, #trace, step do
		printf("[E17]   t=%08d PC=%06X SP=%04X", trace[i].tick, trace[i].pc, trace[i].sp)
	end
end
local lastpc
local function tick_trace(n)
	for i = 1, n do
		emu:tick()
		now_tick = now_tick + 1
		local p = pc16()
		if p ~= lastpc then
			lastpc = p
			trace[#trace + 1] = { tick = now_tick, pc = p, sp = cpu.sp }
		end
		if now_tick % POLL_EVERY == 0 then poll("run") end
	end
end

print("")
print("================================================================")
printf("[E17] keys-during-chain-window run — %s", os.date())
print("================================================================")

printf("[E17] settling 2,000,000 ticks (watcher settling baseline) ...")
tick_poll(2000000, "boot")
printf("[E17] settled: PC=%06X SP=%04X mode=%02X", pc16(), cpu.sp, data[0xF031])

-- inject + pump -----------------------------------------------------------------
local bytes = {}
for i = 1, #PAYLOAD_HEX, 2 do bytes[#bytes + 1] = tonumber(PAYLOAD_HEX:sub(i, i + 1), 16) end
for i, byte in ipairs(bytes) do data[0x8154 + i - 1] = byte end
for addr = 0x8154, 0x8DFF do
	data[addr] = bytes[(addr - 0x8154) % 100 + 1]
end
local chain_ok = (data[0x8DA4] == bytes[53]) and (data[0x8DA5] == bytes[54])
printf("[E17] payload injected; 0x8DA4 trigger bytes = %02X %02X %s",
	data[0x8DA4], data[0x8DA5], chain_ok and "OK" or "MISMATCH")

-- launch + immediate key sequence -------------------------------------------------
cpu.csr = 1
cpu.pc = 0x54EE
cpu.sp = 0x8DA4
printf("[E17] chain launched at tick %d; tracing + pressing immediately", now_tick)

start_trace()
local function press(code, name, hold, gap)
	Keyboard:PressKey(code)
	tick_trace(hold)
	Keyboard:ReleaseAll()
	tick_trace(gap)
	printf("[E17] pressed [%s] (code %02X), done at tick %d (PC=%06X F830=%02X F840=%02X)",
		name, code, now_tick, pc16(), data[0xF830], data[0xF840])
end

press(0x00, "1", 30000, 30000)
printf("[E17] trace so far: %d transitions", #trace)
press(0x10, "2", 30000, 30000)
press(0x11, "5", 30000, 30000)
press(0x30, "=", 30000, 30000)
stop_trace("press-window", 25)

-- settle tail: does anything keep running? ---------------------------------------
printf("[E17] tail: 1,000,000 more ticks ...")
tick_poll(1000000, "tail")
printf("[E17] after tail: PC=%06X SP=%04X events=%d", pc16(), cpu.sp, events)

-- summary ------------------------------------------------------------------------
print("[E17] ==== E17 summary ====")
printf("[E17] FB write events (incl. cursor blink): %d", events)
local line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF830 + i]) end
print("  F830 (row 3): " .. table.concat(line, " "))
line = {}
for i = 0, 15 do line[#line + 1] = string.format("%02X", data[0xF840 + i]) end
print("  F840 (row 4): " .. table.concat(line, " "))
printf("[E17] final PC = %06X SP = %04X", pc16(), cpu.sp)
printf("[E17] total ticks: %d", now_tick)
emu:shutdown()
