#Requires AutoHotkey v2.0
#SingleInstance Force

; ── State ───────────────────────────────────────────────────────────────────
global autoClickerRunning := false

; ── Toggle ──────────────────────────────────────────────────────────────────
ToggleAutoClicker() {
    static CLICK_SPEED := 250

    global autoClickerRunning
    autoClickerRunning := !autoClickerRunning

    if (autoClickerRunning)
        SetTimer AutoClickerLoop, CLICK_SPEED
    else
        SetTimer AutoClickerLoop, 0
}

; ── Timer callback ──────────────────────────────────────────────────────────
AutoClickerLoop() {
    global autoClickerRunning
    if !autoClickerRunning
        return
    Click
}
