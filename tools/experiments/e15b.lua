-- e15b.lua — E15 sweep: which chain-entry state makes the post-#331 payload
-- run its in-buffer loader in the *emulator* ROM (GY454)?
--
-- Background (documented in the report):
--   * The community payload targets the real-hardware ROM: at SP=8DA4 the
--     sequence is pivot/pop PCs 54EE -> ... -> 8C26 (pointer into the payload
--     itself, where the loader code runs straight from the buffer).
--   * E14+plain-E15 showed that entering at (CSR=1, PC=0x54EE, SP=0x8DA4)
--     does run our inverted-payload bytes as code at 0x8C26 but then falls
--     into the emulator firmware idle loop at 0x7EA8 — the ROM differs.
--   * This sweep tries entry states directly and watches whether PC stays in
--     the buffer-code window (0x8100..0x8E00) — i.e. loader running.
--
dofile("../../tools/experiments/emulib.lua")

local PAYLOAD_HEX =
	"3130e23d3030a032303030f86a273030b244303001012c8531306c743030868b" ..
	"0a44303033333333ee543130b38b4f8b602730306a4f3030268c684f30303334" ..
	"353637383930313260b430308c46313060b43030e23d3030b02c30303333631e" ..
	"3130ec6c"

local bytes = {}
for i = 1, #PAYLOAD_HEX, 2 do
	bytes[#bytes + 1] = tonumber(PAYLOAD_HEX:sub(i, i + 1), 16)
end

local function pc16() return (cpu.csr << 16) | (cpu.pc & ~1) end

local function pump_and_set(csr, pc, sp, label)
	tick_n(200000)
	for i, byte in ipairs(bytes) do
		data[0x8154 + i - 1] = byte
	end
	for addr = 0x8154, 0x8DFF do
		data[addr] = bytes[(addr - 0x8154) % 100 + 1]
	end
	cpu.csr = csr
	cpu.pc = pc
	cpu.sp = sp
	printf("[E15B] --- entry %s: CSR=%d PC=%04X SP=%04X ---", label, csr, pc, sp)

	-- trace: count PC samples inside the buffer window vs other regions
	local seen, inbuf, samples = {}, 0, 0
	local pcbase, nonbuf = {}, {}
	for i = 1, 60 do
		tick_n(5000)
		samples = samples + 1
		local v = pc16()
		seen[string.format("%06X", v)] = (seen[string.format("%06X", v)] or 0) + 1
		if v >= 0x8100 and v < 0x8E00 then inbuf = inbuf + 1
		elseif not pcbase[string.format("%06X", v)] and #nonbuf < 12 then
			pcbase[string.format("%06X", v)] = true
			nonbuf[#nonbuf+1] = string.format("%06X", v)
		end
	end
	printf("[E15B]   %d samples, in-buffer: %d", samples, inbuf)
	printf("[E15B]   distinct non-buffer PCs: 0x%s",
		table.concat(nonbuf, " 0x"))
	printf("[E15B]   top PCs:")
	local top = {}
	for k, v in pairs(seen) do top[#top+1] = { k, v } end
	table.sort(top, function(a, b) return a[2] > b[2] end)
	for i = 1, math.min(6, #top) do
		printf("[E15B]     %s x%d", top[i][1], top[i][2])
	end
	-- framebuffer delta indicator
	printf("[E15B]   F830/F831 now: %02X %02X", data[0xF830], data[0xF831])
	return data[0xF830], data[0xF831]
end

print("")
print("================================================================")
printf("[E15B] Entry-state sweep for payload-as-code — %s", os.date())
print("================================================================")
tick_n(2000000)

-- A: hardware story, but CSR=0 (54EE is a ROM address)
pump_and_set(0, 0x54EE, 0x8DA4, "A CSR=0 PC=54EE")

-- B: direct jump into the in-buffer loader at its pointer target
pump_and_set(0, 0x8C26, 0x8DA4, "B CSR=0 PC=8C26")

-- C: direct jump into the loader at the very start of the buffer
pump_and_set(0, 0x8154, 0x8DA4, "C CSR=0 PC=8154")

-- D: self point / retest — lean SP high in the stack
pump_and_set(0, 0x8C26, 0x8D9E, "D CSR=0 PC=8C26 SP=8D9E")

printf("[E15B] sweep done, total ticks %d", emulib_now())
emu:shutdown()
