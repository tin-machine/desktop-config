#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "..\..\config\user.ahk"
#Include "..\lib\common.ahk"
#Include "..\lib\window_manager.ahk"

; ユーザー設定に合わせてスナップグリッドを上書き
try {
    if (IsSet(UserConfig) && UserConfig.Has("SnapGrid")) {
        WindowManager.snapGrid := UserConfig["SnapGrid"]
    }
} catch {
}

; 本番のホットキーと被りにくいキーでスモークテスト
#!Home::WindowManager.moveHalf("left")
#!End::WindowManager.moveHalf("right")
#!PgUp::WindowManager.moveToMonitor("next")
#!PgDn::WindowManager.moveToMonitor("prev")

; 起動時に軽く通知
TrayTip "臨時ホットキー: Win+Alt+Home/End/PgUp/PgDn", "AHK smoke", 1
