#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; エントリポイント: 設定の読み込みとモジュールの #Include
#Include "lib/common.ahk"
#Include "lib/window_manager.ahk"
#Include "keymap_caps_as_ctrl.ahk"
#Include "keymap_future_us_jis.ahk"
#Include "window_hotkeys.ahk"

; ユーザー設定に応じた初期化
try {
    if (IsSet(UserConfig) && UserConfig.Has("SnapGrid")) {
        WindowManager.snapGrid := UserConfig["SnapGrid"]
    }
} catch {
    ; config がなければデフォルト値のまま
}

; 将来的にトレイメニューやプロファイル切替 GUI を追加する余地あり。
