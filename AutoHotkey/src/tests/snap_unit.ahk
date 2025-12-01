#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "..\lib\window_manager.ahk"

AssertEqual(expected, actual, label := "") {
    if (expected != actual) {
        MsgBox Format("[FAIL] {} Expected: {} Actual: {}", label, expected, actual)
        ExitApp 1
    }
}

; snapGrid のデフォルトは 16
AssertEqual(0, WindowManager.snap(0), "zero")
AssertEqual(16, WindowManager.snap(10), "round up")
AssertEqual(16, WindowManager.snap(16), "exact")
AssertEqual(32, WindowManager.snap(24), "round up 24->32")
AssertEqual(-16, WindowManager.snap(-10), "negative")

; grid を指定した場合
AssertEqual(20, WindowManager.snap(18, 20), "custom grid 20")
AssertEqual(40, WindowManager.snap(39, 20), "custom grid 39->40")

MsgBox "All snap tests passed."
ExitApp 0
