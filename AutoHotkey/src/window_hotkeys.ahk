#Requires AutoHotkey v2.0
#Include "lib/common.ahk"
#Include "lib/window_manager.ahk"

global gResizeMode := false

; AutoHotkey の修飾キー表記: ! = Alt, ^ = Ctrl, + = Shift, # = Windowsキー

class PomodoroTimer {
    static totalSeconds := 25 * 60
    static remainingSeconds := 25 * 60
    static running := false

    static getTimerFn() {
        static fn := ObjBindMethod(PomodoroTimer, "onTick")
        return fn
    }

    static formatRemaining() {
        mins := Floor(PomodoroTimer.remainingSeconds / 60)
        secs := Mod(PomodoroTimer.remainingSeconds, 60)
        return Format("{:02}:{:02}", mins, secs)
    }

    static toggle() {
        if (PomodoroTimer.running) {
            PomodoroTimer.running := false
            SetTimer PomodoroTimer.getTimerFn(), 0
            Common_Notify("Pomodoro", "一時停止 " . PomodoroTimer.formatRemaining(), 2, 1)
            return
        }

        if (PomodoroTimer.remainingSeconds <= 0) {
            PomodoroTimer.remainingSeconds := PomodoroTimer.totalSeconds
        }
        PomodoroTimer.running := true
        SetTimer PomodoroTimer.getTimerFn(), 1000
        Common_Notify("Pomodoro", "開始 " . PomodoroTimer.formatRemaining(), 2, 1)
    }

    static reset() {
        PomodoroTimer.running := false
        PomodoroTimer.remainingSeconds := PomodoroTimer.totalSeconds
        SetTimer PomodoroTimer.getTimerFn(), 0
        Common_Notify("Pomodoro", "リセット 25:00", 2, 1)
    }

    static skip() {
        PomodoroTimer.running := false
        SetTimer PomodoroTimer.getTimerFn(), 0
        PomodoroTimer.remainingSeconds := PomodoroTimer.totalSeconds
        Common_Notify("Pomodoro", "スキップ -> 25:00", 2, 1)
    }

    static onTick() {
        if (!PomodoroTimer.running) {
            return
        }

        PomodoroTimer.remainingSeconds -= 1
        if (PomodoroTimer.remainingSeconds > 0) {
            return
        }

        PomodoroTimer.running := false
        PomodoroTimer.remainingSeconds := PomodoroTimer.totalSeconds
        SetTimer PomodoroTimer.getTimerFn(), 0
        Common_Notify("Pomodoro", "25分終了", 4, 1)
    }
}

FindWindowByCandidates(candidates) {
    for exe in candidates {
        windows := WinGetList("ahk_exe " . exe)
        if (windows.Length > 0) {
            return windows[1]
        }
    }
    return 0
}

ActivateOrRunAndMaximize(appName, candidates) {
    hwnd := FindWindowByCandidates(candidates)
    if (hwnd) {
        try {
            WinActivate hwnd
            WinMaximize hwnd
            return
        } catch {
        }
    }

    launched := false
    for exe in candidates {
        try {
            Run exe
            launched := true
            break
        } catch {
        }
    }

    if (!launched) {
        Common_Notify("App Launch", appName . " の起動に失敗しました", 3, 1)
        return
    }

    Sleep 300
    hwnd := FindWindowByCandidates(candidates)
    if (!hwnd) {
        Common_Notify("App Launch", appName . " は起動中ですがウィンドウ未検出", 3, 1)
        return
    }

    try {
        WinActivate hwnd
        WinMaximize hwnd
    } catch {
        Common_Notify("App Launch", appName . " の前面化/最大化に失敗しました", 3, 1)
    }
}

EnterResizeMode() {
    global gResizeMode
    gResizeMode := true
    Common_Notify("resizeM", "resizeM ON (Esc / Q で終了)", 2, 1)
}

ExitResizeMode() {
    global gResizeMode
    gResizeMode := false
    Common_Notify("resizeM", "resizeM OFF", 1, 1)
}

; 常時ホットキー
; Win + Ctrl + Shift + R: AutoHotkey 設定を再読み込みする
#^+r::Reload

; Win + Ctrl + Shift + Q: resizeM などのモーダル状態をリセットする
#^+q::{
    ExitResizeMode()
    Common_Notify("AHK", "モーダル状態をリセットしました", 2, 1)
}

; Win key copy/paste
; Win + C: Ctrl + C を送信してコピーする
#c::Send "^c"

; Win + V: Ctrl + V を送信して貼り付ける
#v::Send "^v"

; Win + W: Ctrl + W を送信してタブやウィンドウを閉じる
#w::Send "^w"

; アプリ起動/前面化して最大化
; Alt + E: Explorer を起動または前面化して最大化する
!e::ActivateOrRunAndMaximize("Explorer", ["explorer.exe"])

; Alt + G: Slack を起動または前面化して最大化する
!g::ActivateOrRunAndMaximize("Slack", ["slack.exe"])

; Alt + M: Firefox を起動または前面化して最大化する
!m::ActivateOrRunAndMaximize("Firefox", ["firefox.exe"])

; Alt + /: Asana を起動または前面化して最大化する
!/::ActivateOrRunAndMaximize("Asana", ["Asana.exe", "asana.exe"])

; Alt + N: WezTerm を起動または前面化して最大化する
!n::ActivateOrRunAndMaximize("Wezterm", ["wezterm-gui.exe", "wezterm.exe"])

; Alt + ,: Obsidian を起動または前面化して最大化する
!,::ActivateOrRunAndMaximize("Obsidian", ["Obsidian.exe"])

; Alt + .: Google Chrome を起動または前面化して最大化する
!.::ActivateOrRunAndMaximize("Google Chrome", ["chrome.exe"])

; Pomodoro (25:00 fixed)
; Alt + D: Pomodoro を開始または一時停止する
!d::PomodoroTimer.toggle()

; Alt + Shift + D: Pomodoro をスキップして 25:00 に戻す
!+d::PomodoroTimer.skip()

; Alt + Ctrl + D: Pomodoro をリセットして 25:00 に戻す
!^d::PomodoroTimer.reset()

; 画面/ウィンドウ操作（KEYBINDINGS準拠寄り）
; Alt + Ctrl + H/J/K/L: 左/下/上/右方向のモニタへ移動して最大化する
!^h::WindowManager.moveToMonitorAndMaximize("left")
!^j::WindowManager.moveToMonitorAndMaximize("down")
!^k::WindowManager.moveToMonitorAndMaximize("up")
!^l::WindowManager.moveToMonitorAndMaximize("right")

; Alt + Shift + H/J/K/L: ウィンドウを左半分/下半分/上半分/右半分へ配置する
!+h::WindowManager.moveHalf("left")
!+j::WindowManager.moveHalf("bottom")
!+k::WindowManager.moveHalf("top")
!+l::WindowManager.moveHalf("right")

; Alt + T: 同じアプリの次のウィンドウへ切り替える
!t::WindowManager.nextWindowInSameApp(true, true)

; Ctrl + Alt + F: 全アプリを対象に次のウィンドウへ切り替える
^!f::WindowManager.nextWindowGlobal(true, true)

; resizeM mode trigger (tentative)
; Alt + Shift + Space: resizeM モードに入る
!+Space::EnterResizeMode()

#HotIf gResizeMode
; resizeM: Esc / Q / Shift + Q でモードを終了する
Esc::ExitResizeMode()
q::ExitResizeMode()
+q::ExitResizeMode()

; resizeM: A/D/W/S でウィンドウを左/右/上/下へ少し移動する
a::WindowManager.nudge(-24, 0)
d::WindowManager.nudge(24, 0)
w::WindowManager.nudge(0, -24)
s::WindowManager.nudge(0, 24)

; resizeM: H/L/K/J でウィンドウを左半分/右半分/上半分/下半分へ配置する
h::WindowManager.moveHalf("left")
l::WindowManager.moveHalf("right")
k::WindowManager.moveHalf("top")
j::WindowManager.moveHalf("bottom")

; resizeM: Y/O/U/I でウィンドウを 2x2 グリッドの左上/右上/左下/右下へ配置する
y::WindowManager.moveToGrid(0, 0, 2, 2)
o::WindowManager.moveToGrid(0, 1, 2, 2)
u::WindowManager.moveToGrid(1, 0, 2, 2)
i::WindowManager.moveToGrid(1, 1, 2, 2)

; resizeM: F で最大化、C で中央配置する
f::WindowManager.maximizeActive()
c::WindowManager.moveCenter()

; resizeM: = / - でウィンドウ全体を拡大/縮小する
=::WindowManager.resizeBy(80, 80)
-::WindowManager.resizeBy(-80, -80)

; resizeM: Shift + H/L/K/J で左/右/上/下端を広げる
+h::WindowManager.resizeEdge("left", 24)
+l::WindowManager.resizeEdge("right", 24)
+k::WindowManager.resizeEdge("top", 24)
+j::WindowManager.resizeEdge("bottom", 24)

; resizeM: 矢印キーで左/右/上/下方向のモニタへ移動する
Left::WindowManager.moveToMonitor("left")
Right::WindowManager.moveToMonitor("right")
Up::WindowManager.moveToMonitor("up")
Down::WindowManager.moveToMonitor("down")

; resizeM: Space で次のモニタへ移動する
Space::WindowManager.moveToMonitor("next")

; resizeM: [ で直前のウィンドウ位置に戻す
[::WindowManager.restorePrevious()

; resizeM: 半角/全角キー(vkC0)でマウスカーソルをアクティブウィンドウ中央へ移動する
vkC0::WindowManager.moveCursorToActiveWindowCenter()
#HotIf

; 互換の既存ホットキー (Win + Alt)
; Win + Alt + Left/Right/Up/Down: ウィンドウを左半分/右半分/上半分/下半分へ配置する
#!Left::WindowManager.moveHalf("left")
#!Right::WindowManager.moveHalf("right")
#!Up::WindowManager.moveHalf("top")
#!Down::WindowManager.moveHalf("bottom")

; Win + Alt + Numpad7/9/1/3: ウィンドウを 2x2 グリッドの左上/右上/左下/右下へ配置する
#!Numpad7::WindowManager.moveToGrid(0, 0, 2, 2)
#!Numpad9::WindowManager.moveToGrid(0, 1, 2, 2)
#!Numpad1::WindowManager.moveToGrid(1, 0, 2, 2)
#!Numpad3::WindowManager.moveToGrid(1, 1, 2, 2)

; Win + Alt + Enter/Backspace: 次/前のモニタへ移動する
#!Enter::WindowManager.moveToMonitor("next")
#!Backspace::WindowManager.moveToMonitor("prev")

; Win + Alt + Ctrl + 矢印キー: ウィンドウを 10px ずつ移動する
#!^Left::WindowManager.nudge(-10, 0)
#!^Right::WindowManager.nudge(10, 0)
#!^Up::WindowManager.nudge(0, -10)
#!^Down::WindowManager.nudge(0, 10)

; Win + Alt + Space: 常に手前に表示を切り替える
#!Space::WindowManager.toggleAlwaysOnTop()
