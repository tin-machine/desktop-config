#Requires AutoHotkey v2.0
#Include "common.ahk"

class WindowManager {
    static snapGrid := 16

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

    static moveHalf(side) {
        hwnd := WindowManager.active()
        if (!hwnd)
            return

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

        x := WindowManager.snap(x)
        y := WindowManager.snap(y)
        w := WindowManager.snap(w)
        h := WindowManager.snap(h)

        WinMove x, y, w, h, hwnd
    }

    static moveToGrid(row, col, rows := 2, cols := 2) {
        hwnd := WindowManager.active()
        if (!hwnd)
            return

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

        x := WindowManager.snap(x)
        y := WindowManager.snap(y)
        w := WindowManager.snap(w)
        h := WindowManager.snap(h)

        WinMove x, y, w, h, hwnd
    }

    static moveToMonitor(direction := "next") {
        hwnd := WindowManager.active()
        if (!hwnd)
            return

        WinGetPos &wx, &wy, &ww, &wh, hwnd
        monCount := MonitorGetCount()
        if (monCount <= 0)
            return

        curMon := WindowManager.getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2)
        targetMon := direction = "prev" ? (curMon = 1 ? monCount : curMon - 1) : (curMon = monCount ? 1 : curMon + 1)

        MonitorGet targetMon, &tx1, &ty1, &tx2, &ty2

        monW := mx2 - mx1
        monH := my2 - my1
        if (monW = 0 || monH = 0)
            return

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

        nx := WindowManager.snap(nx)
        ny := WindowManager.snap(ny)
        nw := WindowManager.snap(nw)
        nh := WindowManager.snap(nh)

        WinMove nx, ny, nw, nh, hwnd
    }

    static nudge(dx, dy) {
        hwnd := WindowManager.active()
        if (!hwnd)
            return

        WinGetPos &wx, &wy, &ww, &wh, hwnd
        nx := WindowManager.snap(wx + dx)
        ny := WindowManager.snap(wy + dy)
        WinMove nx, ny, ww, wh, hwnd
    }

    static toggleAlwaysOnTop() {
        try {
            WinSetAlwaysOnTop -1, "A"
        } catch as e {
            Common_Log("toggleAlwaysOnTop failed: " . e.Message)
        }
    }
}
