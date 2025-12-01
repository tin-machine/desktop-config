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
    window_hotkeys.ahk     ; ホットキー定義 (Win+Alt ベース)
    keymap_caps_as_ctrl.ahk; CapsLock→Ctrl 完全リマップ
    keymap_future_us_jis.ahk; US/JIS 差分吸収の将来用スケルトン
    lib/
      window_manager.ahk   ; ウィンドウ移動/リサイズロジック
      common.ahk           ; 簡易ログ
    tests/                 ; 検証用スペース (空)
```

## Main Entry (`src/main.ahk`)
- `#Requires AutoHotkey v2.0`, `#SingleInstance Force`。
- `config/user.ahk` を最初に読み込み、`WindowManager.snapGrid` を上書き可能。
- モジュール: `common`, `window_manager`, キーマップ、ホットキーを順に `#Include`。
- 将来のトレイメニュー/プロファイル切替 GUI 追加を想定した余地あり。

## Window Manager (`src/lib/window_manager.ahk`)
- 責務: アクティブウィンドウ取得、所属モニタ判定、スナップ、半分/グリッド配置、モニタ間移動、微調整、最前面トグル。
- 主なメソッド:
  - `active()`: アクティブウィンドウの hwnd を返却 (失敗時 0)。
  - `getMonitorOfWindow(hwnd, &mx1, &my1, &mx2, &my2)`: ウィンドウ左上座標で所属モニタを決定し矩形を取得。見つからない場合は第1モニタにフォールバック。
  - `snap(value, grid := 0)`: デフォルト 16px (`snapGrid`) で丸め。
  - `moveHalf(side)`: モニタ半分 (left/right/top/bottom) に配置。
  - `moveToGrid(row, col, rows := 2, cols := 2)`: グリッド分割配置 (四隅 1/4 など)。
  - `moveToMonitor(direction := "next")`: 相対座標比率を維持したまま隣接モニタへ循環移動。
  - `nudge(dx, dy)`: スナップ付きで微調整。
  - `toggleAlwaysOnTop()`: 常に最前面をトグル。

## Hotkeys (`src/window_hotkeys.ahk`)
- ベース修飾: Win + Alt。
- 半分配置: Win+Alt+←/→/↑/↓。
- 四隅 1/4: Win+Alt+Numpad7/9/1/3 (2x2 グリッド)。
- モニタ移動: Win+Alt+Enter (次), Win+Alt+Backspace (前)。
- 微調整: Win+Alt+Ctrl+矢印 (10px)。
- 常に最前面: Win+Alt+Space。

## Keymaps
- `keymap_caps_as_ctrl.ahk`: `SetCapsLockState "AlwaysOff"` + `CapsLock::Ctrl` で Caps を完全に Ctrl 化。コメントで将来 Hyper キー化案への分岐余地を残す。
- `keymap_future_us_jis.ahk`: `UserConfig.EnableFutureUSJIS` が true のときだけ適用するスケルトン。US/JIS 記号差分をここで吸収予定 (TODO コメントあり)。

## User Config (`config/user.ahk`)
- Map で `SnapGrid` (デフォルト 16) と `EnableFutureUSJIS` (デフォルト false) を保持。
- `.gitignore` によりリポジトリ外管理。環境ごとのオーバーライドを自由に追加可能。

## Open Points / Next Considerations
- US/JIS 差分表の具体化と `keymap_future_us_jis.ahk` 実装。
- Hyper キー運用 (Caps を独自修飾化) へのスイッチ方法を設計。
- ログやデバッグ UI の強化 (`common.ahk` に集約)。
- トレイメニュー/プロファイル切替 GUI、設定リロードホットキーなどの運用改善。
- テスト/検証スクリプト (`src/tests`) の追加検討。
