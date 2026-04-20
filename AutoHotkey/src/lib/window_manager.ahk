#Requires AutoHotkey v2.0
#Include "common.ahk"

class WindowManager {
    static snapGrid := 16
    static historyByHwnd := Map()
    static historyMax := 20

    static active() {
        try {
            return WinGetID("A")
        } catch as e {
            Common_Log("WinGetID failed: " . e.Message)
            return 0
        }
    }

    static getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2) {
        if (!hwnd)
            return 1

        WinGetPos &wx, &wy, &ww, &wh, hwnd
        monCount := MonitorGetCount()
        monitorIndex := 1
        found := false

        Loop monCount {
            i := A_Index
            MonitorGet i, &tmx1, &tmy1, &tmx2, &tmy2
            if (wx >= tmx1 && wx < tmx2 && wy >= tmy1 && wy < tmy2) {
                mx1 := tmx1, my1 := tmy1, mx2 := tmx2, my2 := tmy2
                monitorIndex := i
                found := true
                break
            }
        }

        if (!found && monCount >= 1) {
            MonitorGet 1, &mx1, &my1, &mx2, &my2
        }
        return monitorIndex
    }

    static snap(value, grid := 0) {
        if (!grid || grid <= 0) {
            grid := WindowManager.snapGrid
        }
        if (grid <= 0)
            return value
        return Round(value / grid) * grid
    }

    static notifyNoWindow(message := "対象ウィンドウがありません") {
        Common_Notify("AHK Window", message, 2, 1)
    }

    static pushHistory(hwnd) {
        if (!hwnd)
            return

        try {
            WinGetPos &wx, &wy, &ww, &wh, hwnd
        } catch {
            return
        }

        if (!WindowManager.historyByHwnd.Has(hwnd)) {
            WindowManager.historyByHwnd[hwnd] := []
        }

        history := WindowManager.historyByHwnd[hwnd]
        if (history.Length > 0) {
            last := history[history.Length]
            if (last.x = wx && last.y = wy && last.w = ww && last.h = wh) {
                return
            }
        }

        history.Push({x: wx, y: wy, w: ww, h: wh})
        while (history.Length > WindowManager.historyMax) {
            history.RemoveAt(1)
        }
    }

    static moveWindow(hwnd, x, y, w, h) {
        if (!hwnd)
            return false

        WindowManager.pushHistory(hwnd)
        x := WindowManager.snap(x)
        y := WindowManager.snap(y)
        w := Max(100, WindowManager.snap(w))
        h := Max(100, WindowManager.snap(h))
        WinMove x, y, w, h, hwnd
        return true
    }

    static moveHalf(side) {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }

        WindowManager.getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2)
        monW := mx2 - mx1
        monH := my2 - my1

        switch side {
            case "left":
                x := mx1, y := my1, w := monW / 2, h := monH
            case "right":
                x := mx1 + monW / 2, y := my1, w := monW / 2, h := monH
            case "top":
                x := mx1, y := my1, w := monW, h := monH / 2
            case "bottom":
                x := mx1, y := my1 + monH / 2, w := monW, h := monH / 2
            default:
                return
        }
        WindowManager.moveWindow(hwnd, x, y, w, h)
    }

    static moveToGrid(row, col, rows := 2, cols := 2) {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }

        WindowManager.getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2)
        monW := mx2 - mx1
        monH := my2 - my1
        if (rows <= 0 || cols <= 0)
            return

        cellW := monW / cols
        cellH := monH / rows

        x := mx1 + col * cellW
        y := my1 + row * cellH
        w := cellW
        h := cellH
        WindowManager.moveWindow(hwnd, x, y, w, h)
    }

    static moveCenter() {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }

        WinGetPos &wx, &wy, &ww, &wh, hwnd
        WindowManager.getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2)
        monW := mx2 - mx1
        monH := my2 - my1
        x := mx1 + (monW - ww) / 2
        y := my1 + (monH - wh) / 2
        WindowManager.moveWindow(hwnd, x, y, ww, wh)
    }

    static maximizeActive() {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }
        WindowManager.pushHistory(hwnd)
        WinMaximize hwnd
    }

    static moveToMonitorIndex(hwnd, targetMon) {
        if (!hwnd)
            return false

        WinGetPos &wx, &wy, &ww, &wh, hwnd
        WindowManager.getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2)
        MonitorGet targetMon, &tx1, &ty1, &tx2, &ty2

        monW := mx2 - mx1
        monH := my2 - my1
        if (monW = 0 || monH = 0)
            return false

        relX := (wx - mx1) / monW
        relY := (wy - my1) / monH
        relW := ww / monW
        relH := wh / monH

        tgtW := tx2 - tx1
        tgtH := ty2 - ty1

        nx := tx1 + relX * tgtW
        ny := ty1 + relY * tgtH
        nw := relW * tgtW
        nh := relH * tgtH
        return WindowManager.moveWindow(hwnd, nx, ny, nw, nh)
    }

    static chooseMonitorByDirection(curMon, direction) {
        MonitorGet curMon, &cx1, &cy1, &cx2, &cy2
        ccx := (cx1 + cx2) / 2
        ccy := (cy1 + cy2) / 2
        monCount := MonitorGetCount()

        bestMon := 0
        bestScore := 99999999.0

        Loop monCount {
            i := A_Index
            if (i = curMon)
                continue

            MonitorGet i, &mx1, &my1, &mx2, &my2
            mcx := (mx1 + mx2) / 2
            mcy := (my1 + my2) / 2
            dx := mcx - ccx
            dy := mcy - ccy

            valid := false
            major := 0.0
            minor := 0.0
            switch direction {
                case "left":
                    valid := dx < 0, major := Abs(dx), minor := Abs(dy)
                case "right":
                    valid := dx > 0, major := Abs(dx), minor := Abs(dy)
                case "up":
                    valid := dy < 0, major := Abs(dy), minor := Abs(dx)
                case "down":
                    valid := dy > 0, major := Abs(dy), minor := Abs(dx)
            }

            if (!valid)
                continue

            score := major + (minor * 0.5)
            if (score < bestScore) {
                bestScore := score
                bestMon := i
            }
        }

        return bestMon
    }

    static moveToMonitor(direction := "next") {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }

        monCount := MonitorGetCount()
        if (monCount <= 0) {
            WindowManager.notifyNoWindow("モニタが見つかりません")
            return
        }

        curMon := WindowManager.getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2)
        targetMon := 0
        switch direction {
            case "prev":
                targetMon := curMon = 1 ? monCount : curMon - 1
            case "next":
                targetMon := curMon = monCount ? 1 : curMon + 1
            case "left", "right", "up", "down":
                targetMon := WindowManager.chooseMonitorByDirection(curMon, direction)
                if (!targetMon) {
                    targetMon := curMon = monCount ? 1 : curMon + 1
                }
            default:
                return
        }

        WindowManager.moveToMonitorIndex(hwnd, targetMon)
    }

    static moveToMonitorAndMaximize(direction := "next") {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }
        WindowManager.moveToMonitor(direction)
        WindowManager.pushHistory(hwnd)
        WinMaximize hwnd
    }

    static nudge(dx, dy) {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }

        WinGetPos &wx, &wy, &ww, &wh, hwnd
        nx := WindowManager.snap(wx + dx)
        ny := WindowManager.snap(wy + dy)
        WindowManager.moveWindow(hwnd, nx, ny, ww, wh)
    }

    static resizeBy(dw, dh) {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }
        WinGetPos &wx, &wy, &ww, &wh, hwnd
        WindowManager.moveWindow(hwnd, wx, wy, ww + dw, wh + dh)
    }

    static resizeEdge(edge, amount) {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }
        WinGetPos &x, &y, &w, &h, hwnd

        switch edge {
            case "left":
                x := x - amount, w := w + amount
            case "right":
                w := w + amount
            case "top":
                y := y - amount, h := h + amount
            case "bottom":
                h := h + amount
            default:
                return
        }
        WindowManager.moveWindow(hwnd, x, y, w, h)
    }

    static restorePrevious() {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }
        if (!WindowManager.historyByHwnd.Has(hwnd) || WindowManager.historyByHwnd[hwnd].Length = 0) {
            Common_Notify("AHK Window", "Undo履歴がありません", 2, 1)
            return
        }

        history := WindowManager.historyByHwnd[hwnd]
        prev := history.Pop()
        WinMove prev.x, prev.y, prev.w, prev.h, hwnd
    }

    static isWindowVisible(hwnd) {
        return DllCall("user32\IsWindowVisible", "ptr", hwnd, "int") != 0
    }

    static isWindowCandidate(hwnd, includeMinimized := true, includeToolWindow := false) {
        if (!hwnd)
            return false
        if (!WindowManager.isWindowVisible(hwnd))
            return false

        try {
            if (!includeMinimized && WinGetMinMax(hwnd) = -1)
                return false
        } catch {
            return false
        }

        if (!includeToolWindow) {
            try {
                exStyle := WinGetExStyle(hwnd)
                if (exStyle & 0x80) ; WS_EX_TOOLWINDOW
                    return false
            } catch {
                return false
            }
        }
        return true
    }

    static collectWindowList(processName := "", includeMinimized := true, includeToolWindow := false) {
        out := []
        for hwnd in WinGetList() {
            if (!WindowManager.isWindowCandidate(hwnd, includeMinimized, includeToolWindow))
                continue

            if (processName != "") {
                try {
                    if (WinGetProcessName(hwnd) != processName)
                        continue
                } catch {
                    continue
                }
            }
            out.Push(hwnd)
        }
        return out
    }

    static activateWindow(hwnd) {
        try {
            if (WinGetMinMax(hwnd) = -1) {
                WinRestore hwnd
            }
        } catch {
        }
        WinActivate hwnd
    }

    static cycleWindowFromList(windows) {
        if (windows.Length = 0) {
            Common_Notify("AHK Window", "切り替え対象ウィンドウがありません", 2, 1)
            return
        }

        active := WindowManager.active()
        idx := 0
        Loop windows.Length {
            if (windows[A_Index] = active) {
                idx := A_Index
                break
            }
        }
        nextIdx := idx >= windows.Length ? 1 : idx + 1
        if (idx = 0)
            nextIdx := 1
        WindowManager.activateWindow(windows[nextIdx])
    }

    static nextWindowInSameApp(includeMinimized := true, includeToolWindow := false) {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }
        try {
            proc := WinGetProcessName(hwnd)
        } catch {
            Common_Notify("AHK Window", "アプリ内ウィンドウの取得に失敗しました", 2, 1)
            return
        }
        windows := WindowManager.collectWindowList(proc, includeMinimized, includeToolWindow)
        WindowManager.cycleWindowFromList(windows)
    }

    static nextWindowGlobal(includeMinimized := true, includeToolWindow := false) {
        windows := WindowManager.collectWindowList("", includeMinimized, includeToolWindow)
        WindowManager.cycleWindowFromList(windows)
    }

    static moveCursorToActiveWindowCenter() {
        hwnd := WindowManager.active()
        if (!hwnd) {
            WindowManager.notifyNoWindow()
            return
        }
        WinGetPos &x, &y, &w, &h, hwnd
        MouseMove x + (w // 2), y + (h // 2), 0
    }

    static toggleAlwaysOnTop() {
        try {
            WinSetAlwaysOnTop -1, "A"
        } catch as e {
            Common_Log("toggleAlwaysOnTop failed: " . e.Message)
        }
    }
}
