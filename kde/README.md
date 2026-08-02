# KDE Plasma / KWin

`desktop-config` の操作契約を Plasma 6 の KWin Script として実装します。

## インストール

```bash
bash kde/install.sh
```

手動の場合:

```bash
kpackagetool6 --type=KWin/Script --install kde/kwin-script
kwriteconfig6 --file kwinrc --group Plugins \
  --key desktop-config-window-actionsEnabled true
qdbus6 org.kde.KWin /KWin reconfigure
```

インストール後は、システム設定の **ウィンドウの管理 → KWin スクリプト** と
**キーボード → ショートカット → KWin** で有効化・変更できます。

## 設計

Hammerspoon / AutoHotkey の `Alt+Shift+H/J/K/L` と
`Alt+Ctrl+H/J/K/L` はそのまま共通化しています。

`Alt+Ctrl+H/J/K/L` は、現在の出力と `workspace.screens` のgeometryから
方向先の出力を選び、`workspace.sendClientToScreen()` で移動します。
最大化は移動要求と同時には行わず、対象windowの `outputChanged()` を受けてから
`setMaximize(true, true)` を実行します。これにより、出力移動処理が後から
最大化状態を上書きする競合を避けます。

KWin Script の `registerShortcut()` はグローバルショートカットを登録できますが、
Hammerspoon の `resizeM` のようにモード突入後の修飾なしキーを横取りする用途には
向きません。そのため、四隅・中央・最大化・Undo・次モニターは
`Meta+Alt` 付きの直接ショートカットとして提供します。この差異は
`bindings/actions.yaml` に理由付きで記録され、CIで検証されます。

## 参考

- [KWin scripting tutorial](https://develop.kde.org/docs/plasma/kwin/)
- [KWin scripting API](https://develop.kde.org/docs/plasma/kwin/api/)
