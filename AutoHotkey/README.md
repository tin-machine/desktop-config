# AutoHotkey Setup

Windows 10/11 で動作する AutoHotkey v2 用のキーボード中心ウィンドウ管理スクリプトです。`src/main.ahk` をスタートアップに登録して利用します。

## 使い方
1. AutoHotkey v2 をインストール。
2. `config/user.ahk` を自環境に合わせて編集（`SnapGrid` など）。
3. `src/main.ahk` を実行（またはスタートアップにショートカットを配置）。

主なホットキー:
- Win+C / F / K / V / W: Ctrl+C / F / K / V / W を送信
- Win+Alt+←/→/↑/↓: 左/右/上/下 半分に配置
- Win+Alt+Numpad7/9/1/3: 四隅 1/4 配置
- Win+Alt+Enter / Backspace: 次/前 モニタへ移動
- Win+Alt+Ctrl+矢印: 10px 微調整
- Win+Alt+Space: 常に最前面 トグル
- CapsLock: Ctrl として動作

Windows 標準ショートカットとの重なり:
- Win+C: Copilot または Search を上書き
- Win+F: Feedback Hub を上書き
- Win+K: Cast を上書き
- Win+V: クリップボード履歴を上書き
- Win+W: Widgets を上書き

ディレクトリ構成や設計メモは `spec.md` を参照してください。
