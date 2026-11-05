-- e14.lua — E14: hackstring injection + 0x2768 execution-point validation (v3)
--
-- Hypothesis: at the community's *typed* input path, PC=0x2768 fires with
-- SP=8DA4 and payload bytes [52..55] = EE 54 31 30 at the top of the stack;
-- `pop pc` then hands control to the chain (PC=0:54EE, CSR=1).
--
-- v1 finding: bare injection (no typed line) fires 0x2768 at SP=8D4C only,
--   then [=] aborts (line-state length is 0) → back to idle, no takeover.
-- v2 finding: the old v2 typing loop never registered a single key press
--   (its step_until condition was already true), and AC was mis-keyed.
-- This version types 100 chars with an event-verified press loop first.
--
dofile("../../tools/experiments/emulib.lua")

local PAYLOAD_HEX =
	"3130e23d3030a032303030f86a273030b244303001012c8531306c743030868b" ..
	"0a44303033333333ee543130b38b4f8b602730306a4f3030268c684f30303334" ..
	"353637383930313260b430308c46313060b43030e23d3030b02c30303333631e" ..
	"3130ec6c"
assert(#PAYLOAD_HEX == 200, "payload must be 200 hex digits")

local KEY_AC = 0x42 -- 'Space' in model.lua = AC on the fx-570ES Plus faceplate
local KEY_1  = 0x00

local function pc16() return (cpu.csr << 16) | (cpu.pc & ~1) end

local function inject_payload()
	local adr = 0x8154
	for i = 1, #PAYLOAD_HEX, 2 do
		data[adr] = tonumber(PAYLOAD_HEX:sub(i, i + 1), 16)
		adr = adr + 1
	end
end

-- Observation harness: arm 0x2768, press =, log all passes for `budget` ticks.
local function observe(tag, budget)
	local passes = {}
	local chain_seen, chain_tick = false, 0
	break_at(0x2768, function()
		local top = string.format("%02X %02X %02X %02X",
			data[cpu.sp], data[cpu.sp+1], data[cpu.sp+2], data[cpu.sp+3])
		passes[#passes+1] = {
			tick = emulib_now(), sp = cpu.sp, top = top,
			trigger = top == "EE 54 31 30",
		}
		if #passes <= 40 then
			printf("[%s] pass #%02d tick=%09d PC=%06X SP=%04X chip8[SP..SP+3]=%s%s",
				tag, #passes, emulib_now(), pc16(), cpu.sp, top,
				passes[#passes].trigger and "   << TRIGGER EE 54 31 30 + SP 8DA4" or "")
		end
	end)

	printf("[%s] pressing [=] (code 0x30) ...", tag)
	Keyboard:PressKey(0x30)
	for i = 1, budget do
		tick_n(1)
		if cpu.csr == 1 and (pc16() & 0xFFFF) == 0x54EE then
			chain_seen, chain_tick = true, emulib_now()
			printf("[%s] *** CHAIN ENTRY: PC=0:54EE CSR=1 at tick %d ***", tag, emulib_now())
			break
		end
	end
	Keyboard:ReleaseAll()
	tick_n(80000)
	unbreak_at(0x2768)
	return passes, chain_seen
end

-- typed-line preparation ------------------------------------------------------
local function clear_line()
	Keyboard:PressKey(KEY_AC)
	tick_n(40000)
	Keyboard:ReleaseAll()
	tick_n(200000)
end

local function type_ones(n)
	print("[E14] typing `" .. n .. "` '1' tokens (event-verified presses)")
	for i = 1, n do
		Keyboard:PressKey(KEY_1)
		local ok = step_until(function()
			return data[0x8154 + i - 1] == 0x31 and data[0x8154 + i] == 0
		end, 60000, 1)
		Keyboard:ReleaseAll()
		tick_n(8000)
		if not ok then
			printf("[E14] typing stalled at token %d (tick %d)", i, emulib_now())
			return i - 1
		end
	end
	return n
end

local function count_sp_match(passes)
	local match = false
	for _, p in ipairs(passes) do
		if p.trigger then match = true end
	end
	return match
end

print("")
print("================================================================")
printf("[E14] Injection + 0x2768 execution-point validation v3 — %s", os.date())
printf("[E14] ROM SHA-256 1a1b57…71071 (GY454XE), payload = post #331 data loader")
print("================================================================")

printf("[E14] settling 2,000,000 ticks ...")
tick_n(2000000)
printf("[E14] settled: PC=%06X SP=%04X", pc16(), cpu.sp)

-- ---- variant B: typed 100-char line then overwrite + [=] --------------------
printf("[E14] === variant B: typed 100-char line, overwrite with payload, [=] ===")
clear_line()
printf("[E14] buffer after AC: %s", buf_hex(0x8154, 0x10):gsub("\n", " "))
local typed = type_ones(100)
if typed ~= 100 then
	printf("[E14] ABORT: could not type 100 chars (stalled at %d)", typed)
else
	printf("[E14] typed 100 '1' tokens; buffer head: %s", buf_hex(0x8154, 0x10):gsub("\n", " "))
	inject_payload()
	printf("[E14] buffer overwritten with payload; tail of 100 bytes: %s", buf_hex(0x81B4, 4):gsub("\n", " "))
	printf("[E14] payload repeat region 0x81B8..0x81C7: %s", buf_hex(0x81B8, 0x10):gsub("\n", " "))
	passesB, chainB = observe("E14.B", 3000000)
	printf("[E14] variant B: %d passes logged; trigger(SP=8DA4+EE 54 31 30): %s; chain 0:54EE: %s",
		#passesB, tostring(count_sp_match(passesB)), tostring(chainB))
	printf("[E14] variant B final PC=%X:%06X SP=%04X mode=%02X", cpu.csr, pc16() & 0xFFFF,
		cpu.sp, data[0xF031])
end

print("[E14] ==== E14 complete ====")
emu:shutdown()
