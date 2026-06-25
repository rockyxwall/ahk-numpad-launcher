# AGENTS.md — AutoHotkey Codebase Guide

## Language & Runtime
- **Language:** AutoHotkey v2.0 only (no v1.x compatibility)
- **Required directive:** `#Requires AutoHotkey v2.0` at the top of every script
- **Single instance:** `#SingleInstance Force` when only one copy should run
- **Execution:** Scripts run via `AutoHotkey64.exe` or right-click → "Run Script". No build step.

## Build / Lint / Test Commands
- **No build system, no package manager, no test framework.**
- **Lint:** `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" /syntax script.ahk`
- **Run a script:** `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" mainScript.ahk`
- **Run a single action:** Load the script and press the bound Numpad hotkey (Numpad0+Numpad1 etc.)
- **Type-checking:** None — AHK v2 is dynamically typed. Use `static`/`global` discipline.
- **CI:** None. This is a personal utility repo.

## Project Structure
```
AutoHotkey/
  mainScript.ahk       # Central launcher — slot/router pattern, #Includes lib/
  lib/
    autoClicker.ahk     # AutoClicker class
    holdToggle.ahk      # HoldToggle class
    robloxAFK.ahk       # RobloxAFK class
    img/
      target.png        # Asset used by external scripts (if any)
  AGENTS.md
```

## Architecture: Pure Static Classes

Every action is a **class** in `lib/` with only `static` members. No constructors, no `__New`, no instantiation.

- `static` config constants at top (UPPER_SNAKE_CASE)
- `static` state booleans (lowercase)
- `static Toggle()` as the public entry point (called by router via `ExecuteSlot`)
- `static _Xxx()` as private helpers (prefixed with `_`)
- Timer callbacks use `ObjBindMethod(ClassName, "_MethodName")`

## Code Style Guidelines

### Imports / Includes
- `mainScript.ahk` uses `#Include "lib\filename.ahk"` to pull in action classes.
- Each `lib/*.ahk` file is self-contained with its own `#Requires AutoHotkey v2.0`.
- No module system, no circular dependencies, no `#Include` from within lib/ files.

### Formatting
- No semicolons (AHK v2 uses line-based syntax).
- Spaces inside parentheses: `if (condition)`, not `if(condition)`.
- Braces on separate lines for functions/hotkeys.
- One blank line between functions/sections; two blank lines between classes.
- 4-space indentation. No tabs.
- Line length: no strict limit, but prefer under 120 chars.

### Section Dividers
Use box-drawing characters for visual sections:
```ahk
; ═══════════════════════════════════════════════════════════════════════════
; SECTION TITLE
; ─────────────────────────────────────────────────────────────────────────
; Description line
; ═══════════════════════════════════════════════════════════════════════════
```
Use `; ── Subsection ────────────────────────────────────────────────────` for subsections.

### Naming Conventions
| Thing | Convention | Example |
|-------|-----------|---------|
| Classes | PascalCase | `AutoClicker`, `HoldToggle`, `RobloxAFK` |
| Functions | PascalCase | `ExecuteSlot()`, `Toggle()` |
| Static methods | PascalCase | `static Toggle()`, `static _Loop()` |
| Static state fields | lowercase | `static running := false`, `static held := Map()` |
| Static config consts | UPPER_SNAKE | `static CLICK_SPEED := 250` |
| Local vars | camelCase | `searchStartTime`, `wasActive`, `originalWindow` |
| Files (lib/) | camelCase | `autoClicker.ahk`, `holdToggle.ahk` |
| Hotkey names | AHK native | `Numpad0 & Numpad1::` |

### Toggle Pattern (always the same)
```ahk
static running := false

static Toggle() {
    ClassName.running := !ClassName.running
    if ClassName.running
        SetTimer ObjBindMethod(ClassName, "_Loop"), INTERVAL
    else
        SetTimer ObjBindMethod(ClassName, "_Loop"), 0
}

static _Loop() {
    if !ClassName.running
        return
    ; ...do work...
}
```

### Timers
- Always use `SetTimer ObjBindMethod(ClassName, "Method"), ms`.
- Pass `0` (not `"Off"`) to stop a timer.
- Minimum ~50ms for responsive loops; 100+ ms for background polling.
- Never use label-based `SetTimer` in class-based code.

### Slot / Router Pattern
- `mainScript.ahk` defines a `global SLOT := Map(1, "AutoClicker", 2, "HoldToggle", ...)`
- `ExecuteSlot(n)` looks up the name in `SLOT`, calls `ClassName.Toggle()` via `switch`.
- Adding a new action: create class in `lib/`, add entry to `SLOT`, add `case` to `switch`.
- Dual hotkey binding (Numpad0 + NumpadIns) for every slot, NumLock-agnostic.

### CoordMode & Global Setup
- Place `CoordMode` directives at the top of `mainScript.ahk`, after `#Requires`.
- `CoordMode "Pixel", "Screen"` and `CoordMode "Mouse", "Screen"` for screen-relative coords.
- Declare `global` variables at the top, grouped by purpose.

### Error Handling
- Use `try/catch` sparingly — only around operations that legitimately fail (e.g., `WinActivate` on a missing window).
- In catch blocks, stop any running timers and reset state to `false`.
- Do NOT wrap normal logic in `try/catch`. Let AHK's built-in error dialog surface bugs.
- Use `ProcessExist()` checks before assuming a target process is running.

### Comments
- Section headers use box-drawing chars (═, ─, █).
- Inline comments: `  ; explanation` — two spaces before semicolon.
- `; ── Called by router ─────────────────────` for public entry points.
- `; ── Internal ─────────────────────────────` for private helpers.
- No comments on obvious code. Comment the *why*, not the *what*.

### Hotkeys
- Dual-map every hotkey to work with NumLock on (Numpad0) and off (NumpadIns):
  ```ahk
  Numpad0 & Numpad1::
  NumpadIns & Numpad1::
  Numpad0 & NumpadEnd::
  NumpadIns & NumpadEnd::
  {
      ExecuteSlot(1)
  }
  ```
- Wrap multi-line hotkey bodies in `{ }`.

### Send vs SendEvent
- Use bare `Send` for simple key sequences.
- Use `SendEvent` when you need exact click coordinates: `SendEvent "{Click x y}"`.
- Always send key-up events explicitly for held keys.
- Use `{LWin down}{LCtrl down}...{LWin up}{LCtrl up}` for chorded hotkeys to avoid sticky keys.

### Sleep & Timing
- Use `Sleep ms` (not `Sleep, ms` — no comma in v2).
- Use `A_TickCount` for timing windows (e.g., search retry loops).
- Avoid `Sleep` in tight loops longer than ~30 seconds — use a timer callback instead.

### What NOT to do
- Do NOT use v1 syntax (`Send ^c`, comma-separated params, `%var%`).
- Do NOT use `SetTimer` with label names — use `ObjBindMethod`.
- Do NOT use `global` inside functions unless absolutely necessary to mutate module state.
- Do NOT add external dependencies (no NuGet/pip/npm packages).
- Do NOT create files outside this repository.
- Do NOT use `global` for class state — use `static` class fields instead.
