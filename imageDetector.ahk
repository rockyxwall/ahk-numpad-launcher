#Requires AutoHotkey v2.0
#SingleInstance Force

; ── State ───────────────────────────────────────────────────────────────────
global imageDetectorRunning := false

; ── Toggle ──────────────────────────────────────────────────────────────────
ToggleImageDetector() {
    global imageDetectorRunning
    imageDetectorRunning := !imageDetectorRunning

    if (imageDetectorRunning)
        SetTimer ImageDetectorLoop, 100
    else
        SetTimer ImageDetectorLoop, 0
}

; ── Timer callback ──────────────────────────────────────────────────────────
ImageDetectorLoop() {
    static IMAGE_FILE       := A_ScriptDir "\target.png"
    static COLOR_TOLERANCE  := 50
    static TRANSPARENT_COLOR := "Black"
    static WAIT_AFTER_CLICK := 4000

    global imageDetectorRunning
    if !imageDetectorRunning
        return

    try {
        searchOptions := "*" COLOR_TOLERANCE " *Trans" TRANSPARENT_COLOR " "

        if ImageSearch(&fx, &fy, 0, 0, A_ScreenWidth, A_ScreenHeight, searchOptions IMAGE_FILE) {
            cx := A_ScreenWidth // 2
            cy := A_ScreenHeight // 2

            Click "Down", cx, cy
            Sleep 2500
            Click "Up"
            Sleep 200

            Click "Down", cx, cy
            Sleep 2500
            Click "Up"
            Sleep 200

            Click "Down", cx, cy
            Sleep 2500
            Click "Up"
            Sleep 200

            Click "Down", cx, cy
            Sleep 2800
            Click "Up"
            Sleep 200

            Click cx, cy
            Sleep 1000
            Click cx, cy

            Sleep WAIT_AFTER_CLICK
        }
    } catch {
        imageDetectorRunning := false
        SetTimer ImageDetectorLoop, 0
    }
}
