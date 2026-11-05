-- e20a.lua — E20a (reference): diagnostic self-test on the verified GY454XE ROM
-- Purpose: press the community-verified SHIFT+7+ON diagnostic entry, then key 9,
-- capturing framebuffer ASCII at each stage, so the PHYSICAL E20 worksheet has a
-- ground-truth version screen to compare the user's fx-991ES PLUS against.
-- Keycodes verified from models/fx570esplus/model.lua + Keyboard.cpp:
--   SHIFT=0x07  7=0x02  9=0x22  AC=0x42  ON=0xFF (BT_POWER -> chipset.Reset())

dofile("../../tools/experiments/emulib.lua")

local K_SHIFT, K_7, K_9, K_AC, K_ON = 0x07, 0x02, 0x22, 0x42, 0xFF
local DIAG_BLOCK = 0x860E   -- community-documented diagnostic check byte (thread p.7 #246)

local function snap(tag)
	printf("\n[E20a] === %s (t=%d) ===\n%s", tag, emulib_now(), fb_render())
end

-- 0) settle baseline: normal boot to home screen
printf("[E20a] ROM: models/fx570esplus/rom.bin (GY454XE, SHA 1a1b57...71071)")
tick_n(400000)
snap("baseline after boot")
print(buf_hex(DIAG_BLOCK, 16))

-- 1) hold SHIFT+7, then ON (full reset with combo still held).
-- v1 fix: the reset is synchronous; the firmware scans the matrix during early
-- boot AFTER it, so the combo must stay held through the whole boot.
Keyboard:PressKey(K_SHIFT)
tick_n(3000)
Keyboard:PressKey(K_7)
tick_n(3000)
printf("[E20a] SHIFT+7 held; pressing ON (0xFF = BT_POWER -> chipset.Reset)")
Keyboard:PressKey(K_ON)
tick_n(1200000)            -- combo held through boot scan --
Keyboard:ReleaseAll()

-- 2) wait for the boot to produce a screen, then dump
tick_n(300000)
snap("after SHIFT+7+ON reset (expect DIAGNOSTIC splash)")

-- 3) press 9 -> test sequence starts (verified: KI4/KO4 enters, AC aborts)
Keyboard:PressKey(K_9)
tick_n(40000)
Keyboard:ReleaseAll()
tick_n(20000)
Keyboard:PressKey(K_9)
tick_n(40000)
Keyboard:ReleaseAll()
tick_n(400000)
snap("after pressing 9 (expect full-ink LCD test pattern)")

-- 4) advance through the 5 display patterns with SHIFT (verified: render_waitshift)
--    fill-ink, fill-blank, box, checkerboard 01, checkerboard 10, then version screen
for k = 1, 6 do
	printf("[E20a] SHIFT advance #%d", k)
	Keyboard:PressKey(K_SHIFT)
	tick_n(40000)
	Keyboard:ReleaseAll()
	tick_n(250000)
	snap("after SHIFT advance " .. k)
end
print(buf_hex(DIAG_BLOCK, 16))

-- 4) exit: press ON (full reset back to normal boot)
printf("[E20a] exiting diag via ON (0xFF reset)")
Keyboard:PressKey(K_ON)
tick_n(1500000)
snap("after exit ON (normal reboot expected)")
print(buf_hex(DIAG_BLOCK, 16))

printf("[E20a] Goodbye")
emu:shutdown()
