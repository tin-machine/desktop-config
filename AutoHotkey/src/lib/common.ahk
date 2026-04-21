#Requires AutoHotkey v2.0

; 共通関数のみ。キーバインド定義は window_hotkeys.ahk などに置く。

; 最低限のログ出力。必要に応じて拡張予定。
Common_Log(message) {
    ts := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    OutputDebug Format("[AHK] {} - {}", ts, message)
}

Common_Notify(title, message, seconds := 3, icon := 1) {
    try {
        ; AutoHotkey v2: TrayTip(Text, Title?, Options?)
        ; `seconds` は関数互換のため受け取るが、表示時間はOS側挙動に委ねる。
        TrayTip message, title, icon
    } catch as e {
        Common_Log("TrayTip failed: " . e.Message)
    }
}
