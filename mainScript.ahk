#Requires AutoHotkey v2.0
#SingleInstance Force

; ═══════════════════════════════════════════════════════════════════════════
; ACTION CLASS IMPORTS
; Add a #Include line here for each action.
; ═══════════════════════════════════════════════════════════════════════════
#Include "lib\autoClicker.ahk"
#Include "lib\holdToggle.ahk"
#Include "lib\robloxAFK.ahk"

; ═══════════════════════════════════════════════════════════════════════════
; CONFIGURATION — only thing you ever touch
; Map slot number → class object
; Use "Disabled" to leave a slot empty
; ═══════════════════════════════════════════════════════════════════════════
global SLOT := Map(
    1, AutoClicker,
    2, HoldToggle,
    3, RobloxAFK,
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
SetMouseDelay -1

; ═══════════════════════════════════════════════════════════════════════════
; ACTION ROUTER  (never needs editing)
; ═══════════════════════════════════════════════════════════════════════════
ExecuteSlot(n) {
    global SLOT
    c := SLOT.Has(n) ? SLOT[n] : "Disabled"
    if (c = "Disabled")
        return
    c.Toggle()
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
{
    ExecuteSlot(1)
}

Numpad0 & Numpad2::
Numpad0 & NumpadDown::
NumpadIns & Numpad2::
NumpadIns & NumpadDown::
{
    ExecuteSlot(2)
}

Numpad0 & Numpad3::
Numpad0 & NumpadPgDn::
NumpadIns & Numpad3::
NumpadIns & NumpadPgDn::
{
    ExecuteSlot(3)
}

Numpad0 & Numpad4::
Numpad0 & NumpadLeft::
NumpadIns & Numpad4::
NumpadIns & NumpadLeft::
{
    ExecuteSlot(4)
}

Numpad0 & Numpad5::
Numpad0 & NumpadClear::
NumpadIns & Numpad5::
NumpadIns & NumpadClear::
{
    ExecuteSlot(5)
}

Numpad0 & Numpad6::
Numpad0 & NumpadRight::
NumpadIns & Numpad6::
NumpadIns & NumpadRight::
{
    ExecuteSlot(6)
}

Numpad0 & Numpad7::
Numpad0 & NumpadHome::
NumpadIns & Numpad7::
NumpadIns & NumpadHome::
{
    ExecuteSlot(7)
}

Numpad0 & Numpad8::
Numpad0 & NumpadUp::
NumpadIns & Numpad8::
NumpadIns & NumpadUp::
{
    ExecuteSlot(8)
}

Numpad0 & Numpad9::
Numpad0 & NumpadPgUp::
NumpadIns & Numpad9::
NumpadIns & NumpadPgUp::
{
    ExecuteSlot(9)
}

