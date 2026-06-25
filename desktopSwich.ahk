#Requires AutoHotkey v2.0

; Works whether NumLock is on or off
$Numpad0::
$NumpadIns::
{
    Send "{LWin down}{LCtrl down}"
    KeyWait "Numpad0"
    KeyWait "NumpadIns"
    Send "{LWin up}{LCtrl up}"
}