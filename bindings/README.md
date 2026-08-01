# Keybinding contract

`actions.yaml` は、macOS / Windows / KDEで提供するウィンドウ操作の契約です。
JSON構文で記述していますが、JSONはYAMLのsubsetなので `.yaml` として扱えます。
CI側は外部dependencyを避けるためPython標準ライブラリの`json`で読み込みます。

各 `*.annotations.json` は、actionと実装コードを結び付けるsidecar annotationです。
`evidence` に指定した文字列が実装ファイルから消えた場合、CIが失敗します。
これによりLua・AutoHotkey・KWin JavaScriptの完全なparserを導入せずに、
主要なキーバインド変更と実装消失を検出します。

```bash
python scripts/check_binding_consistency.py
python scripts/generate_keybindings_doc.py --check
```

契約を変更した場合は次を実行します。

```bash
python scripts/generate_keybindings_doc.py
```
