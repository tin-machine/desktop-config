# Tests / Diagnostics

このディレクトリは挙動確認用の簡易テストを置く場所です。

## 1) snap_unit.ahk (スナップ丸めの単体テスト)
- 副作用なし。`WindowManager.snap` の挙動を確認。
- 実行方法: `AutoHotkey64.exe snap_unit.ahk`
- 成功時は MsgBox で `All snap tests passed.` と表示。

## 2) hotkey_smoke.ahk (手動スモーク用ホットキー)
- 実行中だけ、以下の臨時ホットキーを登録します。
  - Win+Alt+Home : アクティブウィンドウを左半分へ
  - Win+Alt+End  : アクティブウィンドウを右半分へ
  - Win+Alt+PageUp : アクティブウィンドウを次のモニタへ
  - Win+Alt+PageDown : アクティブウィンドウを前のモニタへ
- 本番用ホットキーと被らないように Home/End/PageUp/PageDown を使用。
- 挙動確認が終わったらスクリプトを終了してください（タスクトレイの緑アイコン右クリック→Exit）。

> 補足: ここでのホットキー設定は `src/main.ahk` には影響しません。
