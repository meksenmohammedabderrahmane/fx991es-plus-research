# Custom Software (route A plan)

Feasibility ladder (each step evidence-checked before the next):

## Ladder
1. **View internals**: ROP demo that prints RAM/ROM to screen (community-proven; emulator reproduction planned).
2. **Clean input handling**: build an input layer (keycodes → menu) *inside* a ROP/hackstring session. Functions limited to gadget library + injected bytes in the 100-byte budget — hard constraint.
3. **Mini-interpreter**: not on-device alone: interpreter code must live in ROM — impossible without persistent ROM write. ⇒ on-device custom software = *sequences re-injected each session* + ROM helpers. This is a fundamental ceiling; it defines "custom software on original hardware" honestly.
4. **DOC/site comparison**: what demo feats are known to work (list): scrolling text, ROM readback, memcpy chains, interrupt-involved demos (to be verified from historical agent output).
5. **If 2nd edition**: entire offsets/ROP adaptation unknown → start ladder only after edition tests.

## What this implies for design
- "Custom calculator environment" on original hardware = **session-scoped loader** (enter hackstring → chain → minimal shell); each power cycle re-entry needed.
- Anything bigger (real interpreter, file system, settings storage) → route B ([[Decisions/Hardware Decisions]]).

## Battery-of-tests deferred
- Only after emulation reproduction passes + device edition identification (see [[Research/Open Questions]]).
