# desktop-config

macOS、Windows、KDE Plasmaでウィンドウ操作と主要キーバインドを統一するための設定repositoryです。

## 実装

- `hammerspoon/`: macOS / Hammerspoon
- `AutoHotkey/`: Windows / AutoHotkey v2
- `kde/`: KDE Plasma 6 / KWin Script
- `bindings/`: cross-platform action contractとsidecar annotation

現在の対応表は [`KEYBINDINGS.md`](KEYBINDINGS.md) を参照してください。
このファイルは `bindings/actions.yaml` から生成されます。

## 検証

```bash
python scripts/check_binding_consistency.py
python scripts/generate_keybindings_doc.py --check
node --check kde/kwin-script/contents/code/main.js
```

GitHub Actionsの `keybinding-consistency` workflowでも同じ検査を実行します。

## KDE Plasma

```bash
bash kde/install.sh
```

詳細は [`kde/README.md`](kde/README.md) を参照してください。
