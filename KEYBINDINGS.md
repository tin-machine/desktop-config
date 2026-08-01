# Cross-platform Keybindings

> このファイルは `bindings/actions.yaml` から生成されます。直接編集せず、
> 操作契約または各platformのannotation manifestを更新してください。

## 操作一覧

| Action | 動作 | macOS / Hammerspoon | Windows / AutoHotkey | KDE Plasma / KWin |
|---|---|---|---|---|
| `resize_mode_enter` | ウィンドウ操作モードへ入る | `Cmd+R` | `Alt+Shift+Space` | — |
| `half_left` | 左半分へ配置 | `Alt+Shift+H` | `Alt+Shift+H` | `Alt+Shift+H` |
| `half_bottom` | 下半分へ配置 | `Alt+Shift+J` | `Alt+Shift+J` | `Alt+Shift+J` |
| `half_top` | 上半分へ配置 | `Alt+Shift+K` | `Alt+Shift+K` | `Alt+Shift+K` |
| `half_right` | 右半分へ配置 | `Alt+Shift+L` | `Alt+Shift+L` | `Alt+Shift+L` |
| `monitor_left_maximize` | 左モニターへ移動して最大化 | `Alt+Ctrl+H` | `Alt+Ctrl+H` | `Alt+Ctrl+H` |
| `monitor_down_maximize` | 下モニターへ移動して最大化 | `Alt+Ctrl+J` | `Alt+Ctrl+J` | `Alt+Ctrl+J` |
| `monitor_up_maximize` | 上モニターへ移動して最大化 | `Alt+Ctrl+K` | `Alt+Ctrl+K` | `Alt+Ctrl+K` |
| `monitor_right_maximize` | 右モニターへ移動して最大化 | `Alt+Ctrl+L` | `Alt+Ctrl+L` | `Alt+Ctrl+L` |
| `corner_nw` | 左上四分割へ配置 | `resizeM → Y` | `resizeM → Y` | `Meta+Alt+Y` |
| `corner_ne` | 右上四分割へ配置 | `resizeM → O` | `resizeM → O` | `Meta+Alt+O` |
| `corner_sw` | 左下四分割へ配置 | `resizeM → U` | `resizeM → U` | `Meta+Alt+U` |
| `corner_se` | 右下四分割へ配置 | `resizeM → I` | `resizeM → I` | `Meta+Alt+I` |
| `maximize` | 最大化 | `resizeM → F` | `resizeM → F` | `Meta+Alt+F` |
| `center` | 現在のモニター中央へ配置 | `resizeM → C` | `resizeM → C` | `Meta+Alt+C` |
| `monitor_next` | 次のモニターへ移動 | `resizeM → Space` | `resizeM → Space` | `Meta+Alt+Space` |
| `undo_window_operation` | 直前のウィンドウ配置を復元 | `resizeM → [` | `resizeM → [` | `Meta+Alt+[` |

## 意図的な差異

- `resize_mode_enter` / Windows / AutoHotkey: WindowsではWin系標準ショートカットとの競合を避け、Alt+Shift+Spaceを使用する。
- `corner_nw` / KDE Plasma / KWin: KWin Scriptは裸キーを安全に取得するモーダル入力APIを持たないため、Meta+Alt付きグローバルショートカットを使用する。
- `corner_ne` / KDE Plasma / KWin: KWin Scriptは裸キーを安全に取得するモーダル入力APIを持たないため、Meta+Alt付きグローバルショートカットを使用する。
- `corner_sw` / KDE Plasma / KWin: KWin Scriptは裸キーを安全に取得するモーダル入力APIを持たないため、Meta+Alt付きグローバルショートカットを使用する。
- `corner_se` / KDE Plasma / KWin: KWin Scriptは裸キーを安全に取得するモーダル入力APIを持たないため、Meta+Alt付きグローバルショートカットを使用する。
- `maximize` / KDE Plasma / KWin: KWinではresizeMを設けず、Meta+Alt付きグローバルショートカットとして提供する。
- `center` / KDE Plasma / KWin: KWinではresizeMを設けず、Meta+Alt付きグローバルショートカットとして提供する。
- `monitor_next` / KDE Plasma / KWin: KWinではresizeMを設けず、Meta+Alt付きグローバルショートカットとして提供する。
- `undo_window_operation` / KDE Plasma / KWin: KWinではresizeMを設けず、Meta+Alt付きグローバルショートカットとして提供する。

## CIで検査する内容

- 必須platformの実装漏れ
- 操作契約とannotationのキー・context不一致
- 同一platform/context内のキー衝突
- annotationが示す実装断片の消失
- 理由のないcanonical bindingからの差異
- この生成ドキュメントの更新漏れ
