# AutoHotkey Window Manager Scripts

## Overview
- AutoHotkey v2 ベースのキーボード主体ウィンドウ管理とキーマッピングのセット。
- 対象環境: Windows 10/11、内蔵 JIS キーボード + 外付け US101 を想定。
- エントリポイント: `src/main.ahk` をスタートアップに登録して自動起動。

## Directory Layout
```
AutoHotkey/
  README.md
  .gitignore               ; config/user.ahk, keymap_overrides.ahk を無視
  spec.md
  config/
    user.ahk               ; ユーザー固有設定 (SnapGrid, 将来フラグ)
    keymap_overrides.ahk   ; 任意の個別上書き (未実装、無視設定済み)
  src/
    main.ahk               ; 起動と #Include、一元設定
    window_hotkeys.ahk     ; ホットキー定義 (Alt系 + resizeM + 互換Win+Alt)
    keymap_caps_as_ctrl.ahk; CapsLock→Ctrl 完全リマップ
    keymap_future_us_jis.ahk; US/JIS 差分吸収の将来用スケルトン
    lib/
      window_manager.ahk   ; ウィンドウ移動/リサイズロジック
      common.ahk           ; 簡易ログ/通知
    tests/                 ; 検証用スペース (空)
```

## Main Entry (`src/main.ahk`)
- `#Requires AutoHotkey v2.0`, `#SingleInstance Force`。
- `config/user.ahk` を最初に読み込み、`WindowManager.snapGrid` を上書き可能。
- モジュール: `common`, `window_manager`, キーマップ、ホットキーを順に `#Include`。
- 将来のトレイメニュー/プロファイル切替 GUI 追加を想定した余地あり。

## Window Manager (`src/lib/window_manager.ahk`)
- 責務: アクティブウィンドウ取得、所属モニタ判定、スナップ、半分/グリッド配置、方向付きモニタ移動、微調整、Undo、ウィンドウ巡回、最前面トグル。
- 主なメソッド:
  - `active()`: アクティブウィンドウの hwnd を返却 (失敗時 0)。
  - `getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2)`: ウィンドウ左上座標で所属モニタを決定し矩形を取得。見つからない場合は第1モニタにフォールバック。
  - `snap(value, grid := 0)`: デフォルト 16px (`snapGrid`) で丸め。
  - `moveWindow(...)`: スナップ + 最小サイズ補正 + 履歴保存を統合した移動。
  - `pushHistory(hwnd)` / `restorePrevious()`: 直前状態の保存/復元。
  - `moveHalf(side)`: モニタ半分 (left/right/top/bottom) に配置。
  - `moveToGrid(row, col, rows := 2, cols := 2)`: グリッド分割配置 (四隅 1/4 など)。
  - `moveCenter()`: 現在モニタ中央へ配置。
  - `resizeBy(dw, dh)` / `resizeEdge(edge, amount)`: 拡縮・辺単位リサイズ。
  - `moveToMonitor(direction := "next")`: `left/right/up/down/next/prev` 対応のモニタ移動。
  - `moveToMonitorAndMaximize(direction)`: モニタ移動後に最大化。
  - `nextWindowInSameApp(...)` / `nextWindowGlobal(...)`: アプリ内/全体ウィンドウ巡回。
  - `moveCursorToActiveWindowCenter()`: カーソルをアクティブウィンドウ中心に移動。
  - `nudge(dx, dy)`: スナップ付きで微調整。
  - `toggleAlwaysOnTop()`: 常に最前面をトグル。

## Hotkeys (`src/window_hotkeys.ahk`)
- 常時:
  - `Win+Ctrl+Shift+R`: スクリプト再読み込み
  - `Win+Ctrl+Shift+Q`: モード状態リセット
- アプリ起動/前面化+最大化:
  - `Alt+e/g/m//n/,/.` (`Explorer/Slack/Firefox/Asana/WezTerm/Obsidian/Chrome`)
- Pomodoro:
  - `Alt+d`: 開始/一時停止
  - `Alt+Shift+d`: スキップ
  - `Alt+Ctrl+d`: リセット (25:00)
- ウィンドウ操作:
  - `Alt+Ctrl+h/j/k/l`: 左/下/上/右モニタへ移動して最大化
  - `Alt+Shift+h/j/k/l`: 左/下/上/右半分配置
  - `Alt+t`: 前面アプリ内で次ウィンドウ
  - `Ctrl+Alt+f`: 全体で次ウィンドウ
- `resizeM`:
  - 起動: `Alt+Shift+Space`（暫定）
  - 終了: `Esc` / `q`
  - 内容: 移動、半分/四隅配置、中央、拡縮、方向モニタ移動、Undo、カーソル中央
- 互換:
  - 既存 `Win+Alt` 系ショートカット群を残置 (`#!Left` など)

## Keymaps
- `keymap_caps_as_ctrl.ahk`: `SetCapsLockState "AlwaysOff"` + `CapsLock::Ctrl` で Caps を完全に Ctrl 化。コメントで将来 Hyper キー化案への分岐余地を残す。
- `keymap_future_us_jis.ahk`: `UserConfig.EnableFutureUSJIS` が true のときだけ適用するスケルトン。US/JIS 記号差分をここで吸収予定 (TODO コメントあり)。

## Notification / Logging
- `Common_Log()`: `OutputDebug` へログを出力。
- `Common_Notify()`: `TrayTip` 通知（不発時・モード切替・Pomodoro通知などで利用）。

## User Config (`config/user.ahk`)
- Map で `SnapGrid` (デフォルト 16) と `EnableFutureUSJIS` (デフォルト false) を保持。
- `.gitignore` によりリポジトリ外管理。環境ごとのオーバーライドを自由に追加可能。

## Open Points / Next Considerations
- US/JIS 差分表の具体化と `keymap_future_us_jis.ahk` 実装。
- Hyper キー運用 (Caps を独自修飾化) へのスイッチ方法を設計。
- ログやデバッグ UI の強化 (`common.ahk` に集約)。
- トレイメニュー/プロファイル切替 GUI、設定リロードホットキーなどの運用改善。
- 実機での `exe` 名差異（特に Asana/WezTerm）確認と微調整。
- `Alt+Shift+Space` が競合するアプリ有無の確認と必要時の起動キー見直し。
- テスト/検証スクリプト (`src/tests`) の追加検討。
