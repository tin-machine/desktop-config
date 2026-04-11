# Hammerspoon Keybindings

このファイルは `init.lua` と `private/config.lua` の現在の設定を元にしたキーバインド一覧です。

## 表記

- `cmd` = Command
- `ctrl` = Control
- `alt` = Option
- `shift` = Shift

## 常時有効（デフォルト）

| キー | 動作 | 定義元 |
|---|---|---|
| `cmd + ctrl + shift + R` | Hammerspoon 設定をリロード | `init.lua` |
| `cmd + ctrl + shift + Q` | Modal supervisor の初期化/リセット | `modalmgr.lua` |
| `alt + e` | Finder を起動/前面化して最大化 | `private/config.lua` |
| `alt + g` | Slack を起動/前面化して最大化 | `private/config.lua` |
| `alt + m` | Firefox を起動/前面化して最大化 | `private/config.lua` |
| `alt + /` | Asana を起動/前面化して最大化 | `private/config.lua` |
| `alt + n` | Wezterm を起動/前面化して最大化 | `private/config.lua` |
| `alt + ,` | Obsidian を起動/前面化して最大化 | `private/config.lua` |
| `alt + .` | Google Chrome を起動/前面化して最大化 | `private/config.lua` |
| `alt + d` | Pomodoro 開始/一時停止 | `private/config.lua` |
| `alt + shift + d` | Pomodoro 次フェーズへスキップ | `private/config.lua` |
| `alt + ctrl + d` | Pomodoro リセット（25:00） | `private/config.lua` |
| `alt + shift + h` | 左ディスプレイに移動して最大化 | `private/config.lua` |
| `alt + shift + j` | 下ディスプレイに移動して最大化 | `private/config.lua` |
| `alt + shift + k` | 上ディスプレイに移動して最大化 | `private/config.lua` |
| `alt + shift + l` | 右ディスプレイに移動して最大化 | `private/config.lua` |
| `alt + ctrl + h` | 左半分に配置 | `private/config.lua` |
| `alt + ctrl + j` | 下半分に配置 | `private/config.lua` |
| `alt + ctrl + k` | 上半分に配置 | `private/config.lua` |
| `alt + ctrl + l` | 右半分に配置 | `private/config.lua` |
| `alt + t` | 前面アプリ内で次のウィンドウへ移動 | `private/config.lua` |
| `ctrl + alt + f` | `hs.window.switcher.nextWindow()` | `private/config.lua` |

## モード起動キー（デフォルト）

| キー | モード | 備考 | 定義元 |
|---|---|---|---|
| `cmd + R` | `resizeM` | ウィンドウ操作モード | `init.lua` |

## `resizeM` モード内キー

| キー | 動作 |
|---|---|
| `escape` / `Q` | `resizeM` を終了 |
| `A` / `D` / `W` / `S` | 微移動（左/右/上/下） |
| `H` / `L` / `K` / `J` | 半分配置（左/右/上/下） |
| `Y` / `O` / `U` / `I` | 四隅配置（左上/右上/左下/右下） |
| `F` | フルスクリーン |
| `C` | 中央配置 |
| `=` / `-` | 拡大 / 縮小 |
| `shift + H` / `shift + L` / `shift + K` / `shift + J` | 微リサイズ（左/右/上/下） |
| `left` / `right` / `up` / `down` | 隣接ディスプレイへ移動 |
| `space` | 次のディスプレイへ移動 |
| `[` | 直前操作を Undo |
| `` ` `` | マウスカーソルをウィンドウ中央へ |
