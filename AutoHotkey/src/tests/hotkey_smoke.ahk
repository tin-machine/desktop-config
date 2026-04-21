#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "..\..\config\user.ahk"
#Include "..\lib\common.ahk"
#Include "..\lib\window_manager.ahk"

; AutoHotkey の修飾キー表記: ! = Alt, ^ = Ctrl, + = Shift, # = Windowsキー

; ユーザー設定に合わせてスナップグリッドを上書き
try {
    if (IsSet(UserConfig) && UserConfig.Has("SnapGrid")) {
        WindowManager.snapGrid := UserConfig["SnapGrid"]
    }
} catch {
}

; 本番のホットキーと被りにくいキーでスモークテスト
; Win + Alt + Home: ウィンドウを左半分へ配置する
#!Home::WindowManager.moveHalf("left")

; Win + Alt + End: ウィンドウを右半分へ配置する
#!End::WindowManager.moveHalf("right")

; Win + Alt + PageUp: 次のモニタへ移動する
#!PgUp::WindowManager.moveToMonitor("next")

; Win + Alt + PageDown: 前のモニタへ移動する
#!PgDn::WindowManager.moveToMonitor("prev")

; 起動時に軽く通知
TrayTip "臨時ホットキー: Win+Alt+Home/End/PgUp/PgDn", "AHK smoke", 1
