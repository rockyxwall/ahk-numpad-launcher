#Requires AutoHotkey v2.0

; ═══════════════════════════════════════════════════════════════════════════
; HOLD TOGGLE
; ─────────────────────────────────────────────────────────────────────────
; Num0 + Key/Button        → hold that input down
; Num0 + same Key again    → release just that input
; Num0 + 2 (alone)         → release ALL held inputs
;
; Supported inputs:
;   Mouse  : RButton, MButton, XButton1, XButton2
;   Letters: a–z
;   Digits : 0–9
;   Misc   : F1–F12, Space, Tab, Enter, Backspace, Escape,
;            Up, Down, Left, Right,
;            LShift, RShift, LCtrl, RCtrl, LAlt, RAlt
; ═══════════════════════════════════════════════════════════════════════════
class HoldToggle {
    ; ── State ───────────────────────────────────────────────────────────────
    static held := Map()

    ; ── Called by router ────────────────────────────────────────────────────
    static Toggle() {
        Sleep 40    ; let co-pressed key register in Windows

        key := HoldToggle._Detect()

        if (key = "")                           ; no co-pressed key → nothing
            return

        if (key = "Escape") {                   ; Esc → release all held
            HoldToggle._ReleaseAll()
            return
        }

        if HoldToggle.held.Has(key) {           ; already held → release it
            SendEvent "{" key " up}"
            HoldToggle.held.Delete(key)
        } else {                                ; not held → hold it
            SendEvent "{" key " down}"
            HoldToggle.held[key] := true
        }
    }

    ; ── Internal: scan for a co-pressed key ─────────────────────────────────
    static _Detect() {
        static mouseButtons := ["RButton", "MButton", "XButton1", "XButton2"]
        static extraKeys    := ["F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
                                "Space","Tab","Enter","Backspace","Escape",
                                "Up","Down","Left","Right",
                                "LShift","RShift","LCtrl","RCtrl","LAlt","RAlt"]

        for btn in mouseButtons
            if GetKeyState(btn, "P")
                return btn

        loop parse, "abcdefghijklmnopqrstuvwxyz"
            if GetKeyState(A_LoopField, "P")
                return A_LoopField

        loop parse, "0123456789"
            if GetKeyState(A_LoopField, "P")
                return A_LoopField

        for k in extraKeys
            if GetKeyState(k, "P")
                return k

        return ""
    }

    ; ── Internal: release everything held ───────────────────────────────────
    static _ReleaseAll() {
        for key, _ in HoldToggle.held
            SendEvent "{" key " up}"
        HoldToggle.held := Map()
    }
}
