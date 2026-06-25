# AutoHotkey Action Launcher

A slot-based hotkey launcher for AutoHotkey v2. Press **Numpad0 + SlotNumber** to toggle an action on and off. Each action lives in its own file under `lib/` — clean, modular, and easy to extend.

## Actions

| # | Action | What it does |
|---|--------|-------------|
| 1 | **AutoClicker** | Clicks the mouse repeatedly at your cursor (or at a pinned position). Speed up/down with `+` / `-`, reset to default with `/`, pin position with `*`. |
| 2 | **HoldToggle** | Hold down any key (or mouse button) by pressing it simultaneously with the slot hotkey. Press the same combo again to release. Press Esc to release everything at once. |
| 3 | **RobloxAFK** | Every 15 minutes, finds a Roblox window (even on another virtual desktop) and does some light input to reset the AFK timer, then restores focus. |

## How it works

**`mainScript.ahk`** is the brain. It defines a `SLOT` map (slot number → class name) and a router function. You press `Numpad0 + 1` → it calls `AutoClicker.Toggle()`. Each class lives in `lib/<name>.ahk` and is completely self-contained.

Slots 4–9 are reserved but disabled by default. To enable one, just set its name in the `SLOT` map and add a `case` to the `switch`.

## Desktop switching

`Numpad0 + Left/Right` switches virtual desktops — useful companion for the RobloxAFK module.

## Adding a new action

```ahk
; 1. Create lib/yourAction.ahk with a class that has a static Toggle() method
; 2. Add to SLOT map: N, "YourAction"
; 3. Add case to the switch in mainScript.ahk
; 4. If it has per-slot controls (+/-/*), add hotkeys at the bottom of the file
```

No build step. No dependencies. Run with `mainScript.ahk` and it just lives in your tray.

## Requirements

- Windows 7+
- [AutoHotkey v2.0](https://www.autohotkey.com/)
