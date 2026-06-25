#Requires AutoHotkey v2.0

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
            SetTimer ObjBindMethod(RobloxAFK, "_Run"), RobloxAFK.INTERVAL
        } else {
            SetTimer ObjBindMethod(RobloxAFK, "_Run"), 0
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
