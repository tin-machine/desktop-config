#Requires AutoHotkey v2.0

; 最低限のログ出力。必要に応じて拡張予定。
Common_Log(message) {
    ts := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    OutputDebug Format("[AHK] {} - {}", ts, message)
}

Common_Notify(title, message, seconds := 3, icon := 1) {
    try {
        TrayTip title, message, seconds, icon
    } catch as e {
        Common_Log("TrayTip failed: " . e.Message)
    }
}
