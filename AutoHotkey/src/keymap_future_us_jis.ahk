#Requires AutoHotkey v2.0

; US101 / JIS 配列差分を吸収するための将来拡張用ファイル。
; EnableFutureUSJIS が true のときだけ読み込む想定。
try {
    if (!IsSet(UserConfig) || !UserConfig.Has("EnableFutureUSJIS") || !UserConfig["EnableFutureUSJIS"]) {
        return
    }
} catch {
    return
}

; TODO: US101/JIS の記号キー差分をここに記述する。
; 例) `;` と `:` の入れ替え、`@` と `"` の位置調整など。
