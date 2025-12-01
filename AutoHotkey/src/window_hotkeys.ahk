#Requires AutoHotkey v2.0
#Include "lib/window_manager.ahk"

; 基本スナップ (Win + Alt + 矢印)
#!Left::WindowManager.moveHalf("left")
#!Right::WindowManager.moveHalf("right")
#!Up::WindowManager.moveHalf("top")
#!Down::WindowManager.moveHalf("bottom")

; 四隅 (Win + Alt + テンキー)
#!Numpad7::WindowManager.moveToGrid(0, 0, 2, 2)
#!Numpad9::WindowManager.moveToGrid(0, 1, 2, 2)
#!Numpad1::WindowManager.moveToGrid(1, 0, 2, 2)
#!Numpad3::WindowManager.moveToGrid(1, 1, 2, 2)

; モニタ間移動 (Win + Alt + Enter / Backspace)
#!Enter::WindowManager.moveToMonitor("next")
#!Backspace::WindowManager.moveToMonitor("prev")

; 微調整 (Win + Alt + Ctrl + 矢印)
#!^Left::WindowManager.nudge(-10, 0)
#!^Right::WindowManager.nudge(10, 0)
#!^Up::WindowManager.nudge(0, -10)
#!^Down::WindowManager.nudge(0, 10)

; 常に最前面トグル (Win + Alt + Space)
#!Space::WindowManager.toggleAlwaysOnTop()
