#Requires AutoHotkey v2.0
#SingleInstance Force

; ═══════════════════════════════════════════════════════════════════════════
; CONFIGURATION - CHANGE ACTIONS HERE
; ═══════════════════════════════════════════════════════════════════════════

ACTION_NUM1 := "AutoClicker"   ; Num0+Num1 = Auto Clicker
ACTION_NUM2 := "HoldToggle"    ; Num0+Num2 = Hold Toggle
ACTION_NUM3 := "RobloxAFK"     ; Num0+Num3 = Roblox AFK Bypass
ACTION_NUM4 := "Disabled"      ; Num0+Num4 = Nothing
ACTION_NUM5 := "Disabled"      ; Num0+Num5 = Nothing
ACTION_NUM6 := "Disabled"      ; Num0+Num6 = Nothing
ACTION_NUM7 := "Disabled"      ; Num0+Num7 = Nothing
ACTION_NUM8 := "Disabled"      ; Num0+Num8 = Nothing
ACTION_NUM9 := "Disabled"      ; Num0+Num9 = Nothing

; ═══════════════════════════════════════════════════════════════════════════
; SYSTEM CONFIGURATION
; ═══════════════════════════════════════════════════════════════════════════
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

global autoClickerRunning := false
global robloxAFKRunning   := false
global heldInputs         := Map()   ; tracks everything currently held

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
; NUMBER KEY ACTIONS
; ═══════════════════════════════════════════════════════════════════════════

Numpad0 & Numpad1::
Numpad0 & NumpadEnd::
NumpadIns & Numpad1::
NumpadIns & NumpadEnd::
{
    global ACTION_NUM1
    ExecuteAction(ACTION_NUM1)
}

; ── Num2: HoldToggle needs to capture co-pressed key at trigger time ───────
Numpad0 & Numpad2::
Numpad0 & NumpadDown::
NumpadIns & Numpad2::
NumpadIns & NumpadDown::
{
    global ACTION_NUM2
    if (ACTION_NUM2 = "HoldToggle")
        HoldToggleCapture()
    else
        ExecuteAction(ACTION_NUM2)
}

Numpad0 & Numpad3::
Numpad0 & NumpadPgDn::
NumpadIns & Numpad3::
NumpadIns & NumpadPgDn::
{
    global ACTION_NUM3
    ExecuteAction(ACTION_NUM3)
}

Numpad0 & Numpad4::
Numpad0 & NumpadLeft::
NumpadIns & Numpad4::
NumpadIns & NumpadLeft::
{
    global ACTION_NUM4
    ExecuteAction(ACTION_NUM4)
}

Numpad0 & Numpad5::
Numpad0 & NumpadClear::
NumpadIns & Numpad5::
NumpadIns & NumpadClear::
{
    global ACTION_NUM5
    ExecuteAction(ACTION_NUM5)
}

Numpad0 & Numpad6::
Numpad0 & NumpadRight::
NumpadIns & Numpad6::
NumpadIns & NumpadRight::
{
    global ACTION_NUM6
    ExecuteAction(ACTION_NUM6)
}

Numpad0 & Numpad7::
Numpad0 & NumpadHome::
NumpadIns & Numpad7::
NumpadIns & NumpadHome::
{
    global ACTION_NUM7
    ExecuteAction(ACTION_NUM7)
}

Numpad0 & Numpad8::
Numpad0 & NumpadUp::
NumpadIns & Numpad8::
NumpadIns & NumpadUp::
{
    global ACTION_NUM8
    ExecuteAction(ACTION_NUM8)
}

Numpad0 & Numpad9::
Numpad0 & NumpadPgUp::
NumpadIns & Numpad9::
NumpadIns & NumpadPgUp::
{
    global ACTION_NUM9
    ExecuteAction(ACTION_NUM9)
}

; ═══════════════════════════════════════════════════════════════════════════
; ACTION ROUTER
; ═══════════════════════════════════════════════════════════════════════════
ExecuteAction(actionName)
{
    if (actionName = "AutoClicker")
        ToggleAutoClicker()
    else if (actionName = "RobloxAFK")
        ToggleRobloxAFK()
    ; "HoldToggle" and "Disabled" do nothing here intentionally
}

; ═══════════════════════════════════════════════════════════════════════════
; AUTO CLICKER
; ═══════════════════════════════════════════════════════════════════════════
ToggleAutoClicker()
{
    static CLICK_SPEED := 250  ; Milliseconds between clicks

    global autoClickerRunning
    autoClickerRunning := !autoClickerRunning

    if (autoClickerRunning)
        SetTimer AutoClickerLoop, CLICK_SPEED
    else
        SetTimer AutoClickerLoop, 0
}

AutoClickerLoop()
{
    global autoClickerRunning
    if !autoClickerRunning
        return
    Click
}

; ═══════════════════════════════════════════════════════════════════════════
; HOLD TOGGLE
; ─────────────────────────────────────────────────────────────────────────
; Num0 + Key/Button        → hold that input down
; Num0 + same Key again    → release just that input
; Num0 + 2 alone           → release ALL held inputs
;
; Supported: RButton, MButton, XButton1, XButton2,
;            a-z, 0-9, F1-F12, Space, Tab, Enter,
;            Backspace, Escape, Up, Down, Left, Right,
;            LShift, RShift, LCtrl, RCtrl, LAlt, RAlt
;
; Uses SendEvent so it does not conflict with other AHK scripts
; that use Send or SendInput.
; ═══════════════════════════════════════════════════════════════════════════
HoldToggleCapture()
{
    global heldInputs

    ; Give Windows time to register the co-pressed key/button
    Sleep 40

    detectedKey := ""

    ; ── Mouse buttons (LButton excluded — usually the trigger click itself) ─
    static mouseButtons := ["RButton", "MButton", "XButton1", "XButton2"]
    for btn in mouseButtons
    {
        if GetKeyState(btn, "P")
        {
            detectedKey := btn
            break
        }
    }

    ; ── Letters ────────────────────────────────────────────────────────────
    if (detectedKey = "")
    {
        loop parse, "abcdefghijklmnopqrstuvwxyz"
        {
            if GetKeyState(A_LoopField, "P")
            {
                detectedKey := A_LoopField
                break
            }
        }
    }

    ; ── Digits ─────────────────────────────────────────────────────────────
    if (detectedKey = "")
    {
        loop parse, "0123456789"
        {
            if GetKeyState(A_LoopField, "P")
            {
                detectedKey := A_LoopField
                break
            }
        }
    }

    ; ── Function + misc keys ───────────────────────────────────────────────
    if (detectedKey = "")
    {
        static extraKeys := ["F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
                             "Space","Tab","Enter","Backspace","Escape",
                             "Up","Down","Left","Right",
                             "LShift","RShift","LCtrl","RCtrl","LAlt","RAlt"]
        for k in extraKeys
        {
            if GetKeyState(k, "P")
            {
                detectedKey := k
                break
            }
        }
    }

    ; ── No extra key = release everything ──────────────────────────────────
    if (detectedKey = "")
    {
        ReleaseAllHeld()
        return
    }

    ; ── Already held? Release only that one ────────────────────────────────
    if heldInputs.Has(detectedKey)
    {
        SendEvent "{" detectedKey " up}"
        heldInputs.Delete(detectedKey)
        return
    }

    ; ── Not held? Hold it ──────────────────────────────────────────────────
    SendEvent "{" detectedKey " down}"
    heldInputs[detectedKey] := true
}

ReleaseAllHeld()
{
    global heldInputs
    for key, _ in heldInputs
        SendEvent "{" key " up}"
    heldInputs := Map()
}

; ═══════════════════════════════════════════════════════════════════════════
; ROBLOX AFK BYPASS
; ═══════════════════════════════════════════════════════════════════════════
ToggleRobloxAFK()
{
    global robloxAFKRunning
    robloxAFKRunning := !robloxAFKRunning

    if (robloxAFKRunning)
    {
        RobloxAFKLoop()
        SetTimer RobloxAFKLoop, 900000
    }
    else
    {
        SetTimer RobloxAFKLoop, 0
    }
}

RobloxAFKLoop()
{
    static ROBLOX_PROCESS  := "RobloxPlayerBeta.exe"
    static CHECK_INTERVAL  := 2000
    static MAX_SEARCH_TIME := 30000

    global robloxAFKRunning

    if !robloxAFKRunning
        return

    if !ProcessExist(ROBLOX_PROCESS)
        return

    ; ── Scenario A: Roblox on current desktop ─────────────────────────────
    if WinExist("ahk_exe " ROBLOX_PROCESS)
    {
        wasActive := WinActive("ahk_exe " ROBLOX_PROCESS)

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

        if !wasActive
        {
            Sleep 600
            WinMinimize
            Sleep 300
        }

        return
    }

    ; ── Scenario B: Roblox on another desktop ─────────────────────────────
    originalWindow := WinGetID("A")

    Send "{LWin down}{LCtrl down}{Right}{LWin up}{LCtrl up}"
    Sleep 500

    searchStartTime := A_TickCount

    while ((A_TickCount - searchStartTime) < MAX_SEARCH_TIME)
    {
        if WinExist("ahk_exe " ROBLOX_PROCESS)
        {
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

            Send "y"
            Sleep 200

            Sleep 600
            WinMinimize
            Sleep 300

            break
        }

        Sleep CHECK_INTERVAL
    }

    Send "{LWin down}{LCtrl down}{Left}{LWin up}{LCtrl up}"
    Sleep 500

    try {
        WinActivate "ahk_id " originalWindow
    }
}
