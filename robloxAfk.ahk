#Requires AutoHotkey v2.0
#SingleInstance Force

; ── State ───────────────────────────────────────────────────────────────────
global robloxAFKRunning := false

; ── Toggle ──────────────────────────────────────────────────────────────────
ToggleRobloxAFK() {
    global robloxAFKRunning
    robloxAFKRunning := !robloxAFKRunning

    if (robloxAFKRunning) {
        RobloxAFKLoop()
        SetTimer RobloxAFKLoop, 900000
    } else {
        SetTimer RobloxAFKLoop, 0
    }
}

; ── Timer callback ──────────────────────────────────────────────────────────
RobloxAFKLoop() {
    static ROBLOX_PROCESS   := "RobloxPlayerBeta.exe"
    static CHECK_INTERVAL   := 2000
    static MAX_SEARCH_TIME  := 30000

    global robloxAFKRunning

    if !robloxAFKRunning
        return

    if !ProcessExist(ROBLOX_PROCESS)
        return

    ; ── Scenario A: Roblox on current desktop ────────────────────────────────
    if WinExist("ahk_exe " ROBLOX_PROCESS) {
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

        if !wasActive {
            Sleep 600
            WinMinimize
            Sleep 300
        }
        return
    }

    ; ── Scenario B: Roblox on another desktop ────────────────────────────────
    originalWindow := WinGetID("A")

    Send "{LWin down}{LCtrl down}{Right}{LWin up}{LCtrl up}"
    Sleep 500

    searchStartTime := A_TickCount

    while ((A_TickCount - searchStartTime) < MAX_SEARCH_TIME) {
        if WinExist("ahk_exe " ROBLOX_PROCESS) {
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

            Sleep 600
            WinMinimize
            Sleep 300
            break
        }
        Sleep CHECK_INTERVAL
    }

    Send "{LWin down}{LCtrl down}{Left}{LWin up}{LCtrl up}"
    Sleep 500

    try WinActivate "ahk_id " originalWindow
}
