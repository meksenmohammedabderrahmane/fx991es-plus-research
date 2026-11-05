-- e15.lua — E15: data-loader ROP demo — arbitrary framebuffer output from key presses
--
-- Technique (documented divergence from the community's on-device procedure):
--   * E14 established that pressing [=] on our CasioEmuX build reaches the
--     PC=0x2768 execution point consistently at SP=8D4C (its bare and
--     typed-line variants agree), while the community's hardware path is
--     SP=8DA4 — the emulator's input-parser state diverges there.
--   * The hardware prerequisite the [primary overflow] supplies is fully
--     modelled here instead: the 100-byte payload is written at 0x8154 and
--     the repeat/pump region 0x8154..0x8DFF is filled with the repeating
--     100-byte string (this is byte-for-byte what f_04E50 strcpy + the basic
--     overflow loop do on real hardware, per fxesplus note.md and post #323).
--   * The chain is then given the community's hardware entry state
--     (CSR=1, PC=0x54EE, SP=0x8DA4 — CPU registers are Lua-writable in
--     CasioEmuX) and everything afterwards — every pop, the getkeycode
--     blink loop, y increment via the compensating add, the strcpy stack
--     restore and the infinite loop — runs as genuine payload code.
--
-- Success criteria:
--   * the ROP chain takes over (CSR=1, PC leaves 0x54EE through the payload)
--   * each two-key pair writes byte k1+k2 into the framebuffer at 0xF830+i
--   * keycode calibration: getkeycode value == CasioEmuX button code (key 0x00)
--
dofile("../../tools/experiments/emulib.lua")

local PAYLOAD_HEX =
	"3130e23d3030a032303030f86a273030b244303001012c8531306c743030868b" ..
	"0a44303033333333ee543130b38b4f8b602730306a4f3030268c684f30303334" ..
	"353637383930313260b430308c46313060b43030e23d3030b02c30303333631e" ..
	"3130ec6c"
assert(#PAYLOAD_HEX == 200, "payload must be 200 hex digits")

local FB_WRITE = 0xF830 -- first loader write target (framebuffer row 3)
local STK_TOP = 0x8DA4  -- community entry point (payload bytes 52..55 there)
local REPEAT_END = 0x8E00

local function pc16() return (cpu.csr << 16) | (cpu.pc & ~1) end

local bytes = {}
for i = 1, #PAYLOAD_HEX, 2 do
	bytes[#bytes + 1] = tonumber(PAYLOAD_HEX:sub(i, i + 1), 16)
end
assert(#bytes == 100)

print("")
print("================================================================")
printf("[E15] Data-loader ROP demo: framebuffer output from key pairs — %s", os.date())
print("================================================================")

-- boot settle ---------------------------------------------------------------
printf("[E15] settling 2,000,000 ticks ...")
tick_n(2000000)
printf("[E15] settled: PC=%06X SP=%04X mode=%02X", pc16(), cpu.sp, data[0xF031])

-- payload + simulated pump --------------------------------------------------
print("[E15] injecting payload at 0x8154 and filling repeat region 0x8154..0x8DFF ...")
for i, byte in ipairs(bytes) do
	data[0x8154 + i - 1] = byte
end
for addr = 0x8154, REPEAT_END - 1 do
	data[addr] = bytes[(addr - 0x8154) % 100 + 1]
end

local function expect(addr, off)
	local o = {}
	for k = 0, 3 do o[#o+1] = string.format("%02X", data[addr + k]) end
	local w = table.concat(o, " ")
	local e = string.format("%02X %02X %02X %02X",
		bytes[off + 1], bytes[off + 2], bytes[off + 3], bytes[off + 4])
	printf("[E15]  %04X expect %-12s got %s %s", addr, e, w,
		w == e and "OK" or "MISMATCH")
	return w == e
end
local ok1 = expect(0x8DA4, 52)   -- trigger EE 54 31 30
local ok2 = expect(0x8D9E, 74)   -- end-of-loop region: 60 27 30 30 etc.

-- direct chain launch: community execution-point state -----------------------
printf("[E15] setting CSR=1 PC=0x54EE SP=0x8DA4 (chain entry) ...")
cpu.csr = 1
cpu.pc = 0x54EE
cpu.sp = 0x8DA4
printf("[E15] launched at tick %d", emulib_now())

-- watch the chain's first PC transitions ------------------------------------
printf("[E15] first PC transitions (only changes logged, first 30 shown):")
local last, shown = nil, 0
local chain_ok = false
for i = 1, 3000000 do
	tick_n(1)
	local cur = string.format("%X:%04X", cpu.csr, cpu.pc & 0xFFFF)
	if cur ~= last then
		last = cur
		shown = shown + 1
		if shown <= 30 then
			printf("[E15]   +%08d  CSR=%d PC=%04X SP=%04X", i, cpu.csr, cpu.pc & 0xFFFF, cpu.sp)
		end
	end
	if i == 1000000 and shown > 30 then break end
end
printf("[E15] chain has executed %d distinct PCs", shown)

-- loader byte-writer: two-key pair -> one framebuffer byte -------------------
local write_index = 0
local function read_pair(k1, k2, label)
	Keyboard:PressKey(k1)
	tick_n(40000)
	Keyboard:ReleaseAll()
	tick_n(40000)
	Keyboard:PressKey(k2)
	tick_n(40000)
	Keyboard:ReleaseAll()
	tick_n(40000)

	local addr = FB_WRITE + write_index
	local before = data[addr]
	local observed, wait = nil, 0
	for i = 1, 400000 do
		tick_n(1)
		if data[addr] ~= before then observed = data[addr] wait = i break end
	end
	if observed == nil then observed = data[addr] end
	printf("[E15] pair %-16s wrote %02X at %04X (before %02X, %s)",
		label, observed, addr, before,
		observed ~= before and ("taken after " .. wait .. " ticks") or "no change")
	write_index = write_index + 1
	return observed
end

-- calibration ---------------------------------------------------------------
print("[E15] --- keycode calibration (hypothesis: getkeycode == button code) ---")
local v1 = read_pair(0x00, 0x10, "[1] [2]")
local v2 = read_pair(0x11, 0x22, "[5] [9]")
local calib_ok = (v1 == 0x10) and (v2 == 0x33)
printf("[E15] calibration hypothesis holds: %s", tostring(calib_ok))
if not calib_ok then
	printf("[E15] observed: (%02X,%02X)->%02X  (%02X,%02X)->%02X",
		0x00, 0x10, v1, 0x11, 0x22, v2)
end

-- pattern phase --------------------------------------------------------------
if calib_ok then
	print("[E15] --- pattern phase (pairs ('1', key) -> byte = keycode) ---")
	local pattern = { 0x10, 0x20, 0x30, 0x40, 0x41, 0x22 }
	local keymap  = { [0x10]="[2]", [0x20]="[3]", [0x30]="[=]", [0x40]="[-]",
	                  [0x41]="[/]", [0x22]="[9]" }
	for _, v in ipairs(pattern) do
		read_pair(0x00, v, "'1' " .. keymap[v])
	end
end

-- results --------------------------------------------------------------------
print("[E15] --- final framebuffer ---")
print(fb_render())
printf("[E15] framebuffer 0xF830..0xF84F (payload-recognized region):")
local line = {}
for i = 0, 15 do line[#line+1] = string.format("%02X", data[FB_WRITE + i]) end
print("  F830: " .. table.concat(line, " "))
line = {}
for i = 16, 31 do line[#line+1] = string.format("%02X", data[FB_WRITE + i]) end
print("  F840: " .. table.concat(line, " "))

print("[E15] ==== E15 summary ====")
printf("[E15] ROP chain launcher state verified: trigger at 0x8DA4 %s; restore-region model %s",
	ok1 and "OK" or "MISMATCH", ok2 and "OK" or "MISMATCH")
printf("[E15] chain distinct PCs executed: %d", shown)
printf("[E15] bytes written into framebuffer from key pairs: %d", write_index)
printf("[E15] keycode calibration confirmed: %s", tostring(calib_ok))
printf("[E15] NOTE: chain entry state set directly (CSR=1, PC=0x54EE, SP=0x8DA4) ---")
printf("[E15]       the emulator's own [=] processing diverges at SP=8D4C (see E14)")
printf("[E15] total ticks: %d", emulib_now())
emu:shutdown()
