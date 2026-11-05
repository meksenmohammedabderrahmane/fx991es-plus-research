-- emulib.lua — shared helpers for CasioEmuX console experiments (Lua 5.3)
-- Loaded via dofile() from the console; assumes `emu`, `data`, `cpu` exist from
-- the C Lua bridge, and lua-common.lua is loaded (script=emulator/lua-common.lua).
--
-- Execution model (verified empirically, see experiment log E15-notes):
--   * The emulator's background timer thread does not drive ticks in our
--     environment, so ALL stepping is done manually with emu:tick() loops here
--     ("lint" step probe used this). A key press is emulated by holding with
--     Keyboard:PressKey(code), ticking, then Keyboard:ReleaseAll() and a gap.
--   * framebuffer: data-space 0xF800, 33 rows x 16 bytes, 12 bytes/row displayed
--     (96 x 32 + status row) — per Screen.cpp (HW_ES_PLUS), MSB-first pixels.
--   * screen mode/reg SFRs: 0xF031 mode, 0xF030 range, 0xF032 contrast.
--   * input buffer 0x8154 (100 bytes), via vendor/fxesplus docs + thread 7583.

local FBBASE = 0xF800
local FBROWS = 33
local ROWSIZE = 16
local now_ticks = 0

local function tick_n(n)
	for i = 1, n do
		emu:tick()
	end
	now_ticks = now_ticks + n
	return now_ticks
end

-- step until condition (max cap so a broken loop can't hang the run)
local function step_until(cond, max, every)
	max = max or 5000000
	every = every or 200000
	for i = 1, max do
		emu:tick()
		now_ticks = now_ticks + 1
		if i % every == 0 and cond() then
			return now_ticks, true
		end
		if cond() then
			return now_ticks, true
		end
	end
	return now_ticks, false
end

local function hold_key(code, nt, gap)
	nt = nt or 40000
	gap = gap or 80000
	Keyboard:PressKey(code)
	tick_n(nt)
	Keyboard:ReleaseAll()
	tick_n(gap)
end

-- framebuffer ------------------------------------------------------------
-- pixels MSB-first per byte (Screen.cpp render loop: mask=0x80 shifting right)
local function fb_bytes()
	local t = {}
	for iy = 0, FBROWS - 1 do
		for ix = 0, ROWSIZE - 1 do
			t[iy * ROWSIZE + ix + 1] = data[FBBASE + iy * ROWSIZE + ix]
		end
	end
	return t
end

local function fb_render()
	local t = fb_bytes()
	local out = {}
	for iy = 0, FBROWS - 1 do
		local line = { string.format("%02d|", iy) }
		for ix = 0, 11 do
			local b = t[iy * ROWSIZE + ix + 1]
			for bit = 7, 0, -1 do
				line[#line + 1] = (b >> bit) & 1 == 1 and "#" or " "
			end
			if ix % 3 == 2 then line[#line + 1] = " " end
		end
		out[#out + 1] = table.concat(line)
	end
	out[#out + 1] = string.rep("+", 108)
	return table.concat(out, "\n")
end

local function fb_w()
	local parts = {}
	for iy = 0, FBROWS - 1 do
		local row = {}
		for ix = 0, ROWSIZE - 1 do
			local b = data[FBBASE + iy * ROWSIZE + ix]
			if b ~= 0 then
				row[#row + 1] = string.format("%X+%X:%02X", FBBASE, iy * ROWSIZE + ix, b)
			end
		end
		if #row > 0 then
			parts[#parts + 1] = table.concat(row, " ")
		end
	end
	return #parts > 0 and table.concat(parts, "\n") or "(framebuffer all zero)"
end

local function fb_bytes_row(iy)
	local t = {}
	for ix = 0, ROWSIZE - 1 do
		t[ix + 1] = data[FBBASE + iy * ROWSIZE + ix]
	end
	return t
end

local function fb_hash()
	local h = 0
	for iy = 0, FBROWS - 1 do
		for ix = 0, ROWSIZE - 1 do
			h = (h * 31 + data[FBBASE + iy * ROWSIZE + ix]) % 4294967296
		end
	end
	return h
end

local function buf_hex(addr, n)
	local parts = {}
	for i = 0, n - 1, 16 do
		local line = { string.format("%04X:", addr + i) }
		for j = 0, 15 do
			line[#line + 1] = string.format("%02X", data[addr + i + j])
		end
		parts[#parts + 1] = table.concat(line, " ")
	end
	return table.concat(parts, "\n")
end

local function buf_str(addr, n)
	local out = {}
	for i = 0, n - 1 do
		local b = data[addr + i]
		out[#out + 1] = (b >= 0x20 and b < 0x7F) and string.char(b) or "."
	end
	return table.concat(out)
end

_G.tick_n = tick_n
_G.step_until = step_until
_G.hold_key = hold_key
_G.fb_render = fb_render
_G.fb_w = fb_w
_G.fb_bytes = fb_bytes
_G.fb_bytes_row = fb_bytes_row
_G.fb_hash = fb_hash
_G.buf_hex = buf_hex
_G.buf_str = buf_str
_G.emulib_now = function() return now_ticks end

print("[emulib] loaded (manual-step debugger), helpers ready")
