# AGENTS.md — AutoHotkey Codebase Guide

## Language & Runtime
- **Language:** AutoHotkey v2.0 only (no v1.x compatibility)
- **Required directive:** `#Requires AutoHotkey v2.0` at the top of every script
- **Single instance:** `#SingleInstance Force` when only one copy should run
- **Execution:** Scripts run via `AutoHotkey64.exe` or right-click → "Run Script". No build step.

## Build / Lint / Test Commands
- **No build system, no package manager, no test framework.**
- **Lint:** Use `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe / syntax script.ahk` to check syntax without running.
- **Run a script:** `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" script.ahk`
- **Run a single test:** There is no test framework. To test, run the script and toggle the feature via its hotkey.
- **Type-checking:** None — AHK v2 is dynamically typed. Use `static`/`global` discipline instead.
- **CI:** None. This is a personal utility repo.

## Project Structure
```
AutoHotkey/
  mainScript.ahk       # Central launcher — class-based, slot/router pattern
  autoClicker.ahk      # Standalone auto-clicker (procedural style)
  desktopSwich.ahk     # Desktop-switch hotkey (procedural style)
  imageDetector.ahk    # Image-search clicker (procedural style)
  robloxAfk.ahk        # Roblox AFK bypass (procedural style)
  target.png           # Test image used by imageDetector.ahk
  AGENTS.md            # This file
```

There are two supported architectural styles (both in use):

### 1. Class-based (mainScript.ahk)
Use for the central launcher. Each action is a **class** with only `static` members.
- `static` config constants at top (UPPER_SNAKE_CASE)
- `static` state booleans (lowercase)
- `static Toggle()` as the public entry point (called by router)
- `static _Xxx()` as private helpers (prefixed with `_`)
- Timer callbacks use `ObjBindMethod(ClassName, "_MethodName")`
- No constructor, no `__New`, no instantiation — pure static classes.

### 2. Procedural (standalone .ahk files)
Use for self-contained single-purpose scripts that run independently.
- `global` state variables
- Free functions (PascalCase), `ToggleXxx()` convention
- `SetTimer XxxLoop, 0` to stop, `SetTimer XxxLoop, N` to start
- `static` locals for config constants inside the loop function

## Code Style Guidelines

### Imports / Includes
- No module system. Use `#Include "file.ahk"` to share code between scripts (avoid when possible).
- Prefer one `.ahk` = one self-contained script. Dependencies should be minimal.

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
| Classes | PascalCase | `AutoClicker`, `HoldToggle` |
| Functions | PascalCase | `ToggleAutoClicker()`, `ExecuteSlot()` |
| Static methods | PascalCase | static `Toggle()`, `_Loop()` |
| Global vars | camelCase | `autoClickerRunning` |
| Static class fields | lowercase | `static running := false` |
| Static config consts | UPPER_SNAKE | `static CLICK_SPEED := 250` |
| Local vars | camelCase | `searchStartTime`, `wasActive` |
| Labels (callbacks) | PascalCase | `AutoClickerLoop:` |
| Hotkey names | AHK native | `Numpad0 & Numpad1::` |
| Files | PascalCase / camelCase | `mainScript.ahk`, `robloxAfk.ahk` |

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
- Use `SetTimer ObjBindMethod(ClassName, "Method"), ms` in class-based code.
- Use `SetTimer FunctionName, ms` in procedural code.
- Pass `0` (not `"Off"`) to stop a timer.
- Minimum ~50ms for responsive loops; 100+ ms for background polling.

### CoordMode & Global Setup
- Place `CoordMode` directives at the top of the script, after `#Requires`.
- Use `CoordMode "Pixel", "Screen"` and `CoordMode "Mouse", "Screen"` for screen-relative coordinates.
- Declare `global` variables at the top, grouped by purpose.

### Error Handling
- Use `try/catch` sparingly — only around operations that legitimately fail (e.g., `WinActivate` on a missing window, `ImageSearch` parsing errors).
- In catch blocks, stop any running timers and reset state to false.
- Do NOT wrap normal logic in try/catch. Let AHK's built-in error dialog surface bugs.
- Use `ProcessExist()` checks before assuming a target process is running.

### Comments
- Section headers use box-drawing chars (═, ─, █).
- Inline comments: `  ; explanation` — two spaces before semicolon.
- `; ── Called by router ──────────────────────────` for public entry points.
- `; ── Internal ──────────────────────────────────` for private helpers.
- No comments on obvious code. Comment the *why*, not the *what*.

### Hotkeys
- Dual-map hotkeys to work with NumLock on (Numpad0) and off (NumpadIns):
  ```ahk
  Numpad0 & Numpad1::
  NumpadIns & Numpad1::
  Numpad0 & NumpadEnd::
  NumpadIns & NumpadEnd::
  {
      ExecuteSlot(1)
  }
  ```
- Use `$` prefix (`$Numpad0::`) when a hotkey should not be triggered by its own `Send`.
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
- Do NOT use `SetTimer` with label names in class-based code — use `ObjBindMethod`.
- Do NOT use `global` inside functions unless you absolutely need to mutate module state.
- Do NOT add external dependencies or NuGet/pip/npm packages.
- Do NOT create files outside this directory.
