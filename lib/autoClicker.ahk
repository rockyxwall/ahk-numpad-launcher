#Requires AutoHotkey v2.0

; ═══════════════════════════════════════════════════════════════════════════
; AUTO CLICKER
; ─────────────────────────────────────────────────────────────────────────
; Repeatedly clicks the mouse at the current cursor position.
; Speed up/down and fixed position controls via slot hotkeys.
; ═══════════════════════════════════════════════════════════════════════════
class AutoClicker {
    ; ── Settings ────────────────────────────────────────────────────────────
    static CLICK_SPEED := 250       ; ms between clicks
    static SPEED_STEP  := 150       ; ms per +/- press
    static MIN_SPEED   := 10
    ; MAX_SPEED not set — no upper cap

    ; ── State ───────────────────────────────────────────────────────────────
    static running := false
    static fixedPos := false
    static fixedX   := 0
    static fixedY   := 0

    ; ── Called by router ────────────────────────────────────────────────────
    static Toggle() {
        AutoClicker.running := !AutoClicker.running
        if AutoClicker.running
            SetTimer ObjBindMethod(AutoClicker, "_Loop"), AutoClicker.CLICK_SPEED
        else
            SetTimer ObjBindMethod(AutoClicker, "_Loop"), 0
    }

    ; ── Slot controls (no-ops when not running) ─────────────────────────────
    static SpeedUp() {
        if !AutoClicker.running
            return
        AutoClicker.CLICK_SPEED := Max(AutoClicker.MIN_SPEED, AutoClicker.CLICK_SPEED - AutoClicker.SPEED_STEP)
        SetTimer ObjBindMethod(AutoClicker, "_Loop"), AutoClicker.CLICK_SPEED
        AutoClicker._Notify "AutoClicker: " AutoClicker.CLICK_SPEED "ms"
    }

    static SpeedDown() {
        if !AutoClicker.running
            return
        AutoClicker.CLICK_SPEED += AutoClicker.SPEED_STEP
        SetTimer ObjBindMethod(AutoClicker, "_Loop"), AutoClicker.CLICK_SPEED
        AutoClicker._Notify "AutoClicker: " AutoClicker.CLICK_SPEED "ms"
    }

    static ToggleFixed() {
        if !AutoClicker.running
            return
        AutoClicker.fixedPos := !AutoClicker.fixedPos
        if AutoClicker.fixedPos {
            MouseGetPos &x, &y
            AutoClicker.fixedX := x
            AutoClicker.fixedY := y
            AutoClicker._Notify "AutoClicker: FIXED (" AutoClicker.fixedX ", " AutoClicker.fixedY ")"
        } else {
            AutoClicker._Notify "AutoClicker: FREE"
        }
    }

    ; ── Internal ─────────────────────────────────────────────────────────────
    static _Loop() {
        if !AutoClicker.running
            return
        if AutoClicker.fixedPos
            Click AutoClicker.fixedX " " AutoClicker.fixedY
        else
            Click
    }

    static _Notify(msg) {
        ToolTip msg
        SetTimer () => ToolTip(), -1500
    }
}

; ── Slot 1 control hotkeys (Numpad1 prefix, dual-bound for NumLock) ─────
Numpad1 & NumpadAdd::
NumpadEnd & NumpadAdd::
{
    AutoClicker.SpeedUp()
}

Numpad1 & NumpadSub::
NumpadEnd & NumpadSub::
{
    AutoClicker.SpeedDown()
}

Numpad1 & NumpadMult::
NumpadEnd & NumpadMult::
{
    AutoClicker.ToggleFixed()
}
