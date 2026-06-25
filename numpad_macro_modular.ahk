#Requires AutoHotkey v2.0
#SingleInstance Force

; ═══════════════════════════════════════════════════════════════════════════
; CONFIGURATION - only thing you ever touch
; Map slot number → class name
; Use "Disabled" to leave a slot empty
; ═══════════════════════════════════════════════════════════════════════════
global SLOT := Map(
    1, "AutoClicker",
    2, "HoldToggle",
    3, "RobloxAFK",
    4, "Disabled",
    5, "Disabled",
    6, "Disabled",
    7, "Disabled",
    8, "Disabled",
    9, "Disabled"
)

; ═══════════════════════════════════════════════════════════════════════════
; SYSTEM CONFIGURATION
; ═══════════════════════════════════════════════════════════════════════════
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

; ═══════════════════════════════════════════════════════════════════════════
; ACTION ROUTER  (no editing needed ever)
; ═══════════════════════════════════════════════════════════════════════════
ExecuteSlot(n) {
    global SLOT
    name := SLOT.Has(n) ? SLOT[n] : "Disabled"
    if (name = "Disabled" or name = "")
        return
    switch name {
        case "AutoClicker": AutoClicker.Toggle()
        case "HoldToggle":  HoldToggle.Toggle()
        case "RobloxAFK":   RobloxAFK.Toggle()
    }
}

; ═══════════════════════════════════════════════════════════════════════════
; DESKTOP SWITCHING HOTKEYS
; ═══════════════════════════════════════════════════════════════════════════
Numpad0 & Left::
NumpadIns & Left::
{
    Send "{LWin down}{LCtrl down}{Left}{LWin up}{LCtrl up}"
}

Numpad0 & Right::
NumpadIns & Right::
{
    Send "{LWin down}{LCtrl down}{Right}{LWin up}{LCtrl up}"
}

; ═══════════════════════════════════════════════════════════════════════════
; NUMBER KEY HOTKEYS  (no editing needed ever)
; ═══════════════════════════════════════════════════════════════════════════
Numpad0 & Numpad1::
Numpad0 & NumpadEnd::
NumpadIns & Numpad1::
NumpadIns & NumpadEnd::
{ ExecuteSlot(1) }

Numpad0 & Numpad2::
Numpad0 & NumpadDown::
NumpadIns & Numpad2::
NumpadIns & NumpadDown::
{ ExecuteSlot(2) }

Numpad0 & Numpad3::
Numpad0 & NumpadPgDn::
NumpadIns & Numpad3::
NumpadIns & NumpadPgDn::
{ ExecuteSlot(3) }

Numpad0 & Numpad4::
Numpad0 & NumpadLeft::
NumpadIns & Numpad4::
NumpadIns & NumpadLeft::
{ ExecuteSlot(4) }

Numpad0 & Numpad5::
Numpad0 & NumpadClear::
NumpadIns & Numpad5::
NumpadIns & NumpadClear::
{ ExecuteSlot(5) }

Numpad0 & Numpad6::
Numpad0 & NumpadRight::
NumpadIns & Numpad6::
NumpadIns & NumpadRight::
{ ExecuteSlot(6) }

Numpad0 & Numpad7::
Numpad0 & NumpadHome::
NumpadIns & Numpad7::
NumpadIns & NumpadHome::
{ ExecuteSlot(7) }

Numpad0 & Numpad8::
Numpad0 & NumpadUp::
NumpadIns & Numpad8::
NumpadIns & NumpadUp::
{ ExecuteSlot(8) }

Numpad0 & Numpad9::
Numpad0 & NumpadPgUp::
NumpadIns & Numpad9::
NumpadIns & NumpadPgUp::
{ ExecuteSlot(9) }


; ███████████████████████████████████████████████████████████████████████████
; ACTIONS — each class is 100% self-contained.
; To add a new action: write a new class below, put its name in SLOT above.
; To remove: delete the class, set slot to "Disabled".
; Nothing else needs to change ever.
; ███████████████████████████████████████████████████████████████████████████


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
            SetTimer AutoClicker._Loop, AutoClicker.CLICK_SPEED
        else
            SetTimer AutoClicker._Loop, 0
    }

    ; ── Internal ─────────────────────────────────────────────────────────────
    static _Loop() {
        if !AutoClicker.running
            return
        Click
    }
}


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

        if (key = "") {                         ; no extra key → release all
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


; ═══════════════════════════════════════════════════════════════════════════
; ROBLOX AFK BYPASS
; ─────────────────────────────────────────────────────────────────────────
; Fires every 15 minutes. Finds Roblox on any desktop, performs
; human-like input to reset the AFK timer, then restores focus.
; ═══════════════════════════════════════════════════════════════════════════
class RobloxAFK {
    ; ── Settings ────────────────────────────────────────────────────────────
    static PROCESS        := "RobloxPlayerBeta.exe"
    static INTERVAL       := 900000    ; 15 minutes in ms
    static CHECK_INTERVAL := 2000      ; retry interval when searching desktops
    static MAX_SEARCH     := 30000     ; give up searching after 30 seconds

    ; ── State ───────────────────────────────────────────────────────────────
    static running := false

    ; ── Called by router ────────────────────────────────────────────────────
    static Toggle() {
        RobloxAFK.running := !RobloxAFK.running
        if RobloxAFK.running {
            RobloxAFK._Run()
            SetTimer RobloxAFK._Run, RobloxAFK.INTERVAL
        } else {
            SetTimer RobloxAFK._Run, 0
        }
    }

    ; ── Internal ─────────────────────────────────────────────────────────────
    static _Run() {
        if !RobloxAFK.running
            return
        if !ProcessExist(RobloxAFK.PROCESS)
            return

        if WinExist("ahk_exe " RobloxAFK.PROCESS) {
            RobloxAFK._DoActions(WinActive("ahk_exe " RobloxAFK.PROCESS))
            return
        }

        ; Roblox on another desktop — switch and search
        originalWindow := WinGetID("A")
        Send "{LWin down}{LCtrl down}{Right}{LWin up}{LCtrl up}"
        Sleep 500

        t := A_TickCount
        while (A_TickCount - t) < RobloxAFK.MAX_SEARCH {
            if WinExist("ahk_exe " RobloxAFK.PROCESS) {
                RobloxAFK._DoActions(false)   ; always minimize after desktop switch
                break
            }
            Sleep RobloxAFK.CHECK_INTERVAL
        }

        Send "{LWin down}{LCtrl down}{Left}{LWin up}{LCtrl up}"
        Sleep 500
        try WinActivate "ahk_id " originalWindow
    }

    static _DoActions(wasActive) {
        WinActivate
        Sleep 500

        Send "{Right down}"
        Sleep 1000
        Send "{Right up}"
        Sleep 100

        Send "{Left down}"
        Sleep 1000
        Send "{Left up}"
        Sleep 100

        Send "y"
        Sleep 2000

        SendEvent "{Click 1160 893}"
        Sleep 300
        SendEvent "{Click 1177 877}"
        Sleep 2800

        SendEvent "{Click 813 383}"
        Sleep 300
        SendEvent "{Click 806 340}"
        Sleep 400

        Send "y"
        Sleep 200

        if !wasActive {
            Sleep 600
            WinMinimize
            Sleep 300
        }
    }
}
