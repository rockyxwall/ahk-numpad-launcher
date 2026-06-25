# ahk-numpad-launcher

**`mainScript.ahk`** is the only file you touch. It loads everything from `lib/`.

## Hotkeys

| Combo | Action |
|-------|--------|
| `Numpad0 + 1–9` | Toggle slot |
| `Numpad0 + Left/Right` | Switch virtual desktop |
| `Numpad1 + +/-/*` | Slot 1 speed up/down, toggle fixed position |
| `Numpad1 + /` | Slot 1 reset to default speed |

Every hotkey is dual-bound for NumLock on/off (`NumpadIns` replaces `Numpad0`).

## Adding a slot

```
#Include "lib\newClass.ahk"     → in the imports section
... N, NewClass                  → in the SLOT map
```

That's it. The router calls `NewClass.Toggle()` automatically — no switch, no case, no wiring.

## Requirements

- Windows 7+
- [AutoHotkey v2.0](https://www.autohotkey.com/)
