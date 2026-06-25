#Requires AutoHotkey v2.0

; ═══════════════════════════════════════════════════════════════════════════
; AUTO CLICKER
; ─────────────────────────────────────────────────────────────────────────
; Repeatedly clicks the mouse at the current cursor position.
; ═══════════════════════════════════════════════════════════════════════════
class AutoClicker {
    ; ── Settings ────────────────────────────────────────────────────────────
    static CLICK_SPEED := 250       ; ms between clicks

    ; ── State ───────────────────────────────────────────────────────────────
    static running := false

    ; ── Called by router ────────────────────────────────────────────────────
    static Toggle() {
        AutoClicker.running := !AutoClicker.running
        if AutoClicker.running
            SetTimer ObjBindMethod(AutoClicker, "_Loop"), AutoClicker.CLICK_SPEED
        else
            SetTimer ObjBindMethod(AutoClicker, "_Loop"), 0
    }

    ; ── Internal ─────────────────────────────────────────────────────────────
    static _Loop() {
        if !AutoClicker.running
            return
        Click
    }
}
