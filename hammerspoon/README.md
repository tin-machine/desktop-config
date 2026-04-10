# awesome-hammerspoon 設定まとめ

[Hammerspoon](http://www.hammerspoon.org/) を強く Vim 的なモーダル操作で使うための設定です。デスクトップウィジェット、ウィンドウ管理、アプリランチャー、インスタント検索、aria2 フロントエンドなどを提供します。

## Kaoru の macOS 用設定（このリポジトリ）

- 設定読み込み順: `~/.config/hammerspoon/private/config.lua` があれば優先、無ければ `~/.hammerspoon/private/config.lua` を使用。リロードは `cmd` + `shift` + `ctrl` + `R`。
- Spoon 依存: 必須はなし（モーダル管理はローカル `modalmgr.lua`、ウィンドウ操作はローカル `winops.lua`）。`EmmyLua` は補完用途のため任意。
- モーダル／グローバルホットキー: モーダル起動は最小構成（`cmd+R` の `resizeM`）で、日常用のグローバルキーは `private/config.lua` に集約しています。
  - `cmd` + `R`: ウィンドウ移動・リサイズモード。`H/J/K/L` で左右上下半分、`A/D/W/S` で微移動、`Y/U/I/O` で四隅、`F` 全画面、`C` 中央寄せ、`=`/`-` で拡大・縮小、矢印や `space` でモニタ移動、`[` で undo、`` ` `` でマウスを中央へ。
- アプリ起動ショートカット（`private/config.lua`）: `alt`+`e` Finder, `alt`+`g` Slack, `alt`+`m` Firefox, `alt`+`/` Asana, `alt`+`n` Wezterm, `alt`+`,` Obsidian, `alt`+`.` Google Chrome。起動後は `winops` で最大化。
- Pomodoro: `alt+d` 開始/一時停止、`alt+shift+d` 次フェーズ、`alt+ctrl+d` リセット。実装は `pomodoro.lua`。右上に残り時間ダイアログを表示し、mac 通知は無効化しています。
- 画面・ウィンドウ配置: `alt`+`shift`+`h/j/k/l` で左右上下のモニタへ移動＆最大化。`alt`+`ctrl`+`h/j/k/l` で現在モニタの左右上下半分にスナップ。
- ウィンドウ切替: `alt`+`t` で現在アプリの可視ウィンドウをタイトル順に循環。`ctrl`+`alt`+`f` で Hammerspoon 標準のウィンドウスイッチャー（`hs.window.switcher.nextWindow()`）。
- ViMouse（`vimouse.lua`）: キーボードでマウス操作するモード。`init.lua` への例:
  ```lua
  local vimouse = require('vimouse')
  vimouse({'cmd'}, 'm') -- cmd+m でトグル
  ```
  h/j/k/l で移動（alt 低速、shift 高速）、`space` でクリック／ドラッグ（ctrl+space で右クリック）、`ctrl+y` / `ctrl+e` でスクロール、`esc` またはトグルキーで終了。

## はじめに

1. 先に [Hammerspoon](http://www.hammerspoon.org/) をインストール。
2. `git clone https://github.com/ashfinal/awesome-hammerspoon.git ~/.hammerspoon`
3. 設定をリロード。

## 更新方法

`cd ~/.hammerspoon && git pull`

## 使い方

`opt` を押しながら `A` / `C` / `R` などで開始。困ったときは `tab` でキーバインドのチートシートを表示。

`opt` + `?` でヘルプパネルを表示し、`opt` 系の全キーバインドを確認できます。

### スクリーンショット

awesome-hammerspoon の機能例。組み込み Spoons はこちら: [The built-in Spoons](https://github.com/ashfinal/awesome-hammerspoon/wiki/The-built-in-Spoons)

#### デスクトップウィジェット

<details>
<summary>詳細</summary>

![widgets](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-deskwidgets.png)

</details>

#### ウィンドウ操作 <kbd>⌥</kbd> + <kbd>R</kbd>

<details>
<summary>詳細</summary>

![winresize](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-winresize.gif)

</details>

#### 検索 <kbd>⌥</kbd> + <kbd>G</kbd>

<details>
<summary>詳細</summary>

![hsearch](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-hsearch.gif)

</details>

#### aria2 フロントエンド <kbd>⌥</kbd> + <kbd>D</kbd>

<details>
<summary>詳細</summary>

![hsearch](https://github.com/ashfinal/bindata/raw/master/screenshots/awesome-hammerspoon-aria2.png)

使う前に [RPC 有効で aria2 を起動](https://github.com/ashfinal/awesome-hammerspoon/wiki/Run-aria2-with-rpc-enabled) してください。`~/.hammerspoon/private/config.lua` にホストとトークンを設定します。

```lua
hsaria2_host = "http://localhost:6800/jsonrpc" -- デフォルト
hsaria2_secret = "token" -- 自分のシークレットに置き換え
```

</details>

## カスタマイズ

<details>

<summary>詳細</summary>

```shell
cp ~/.hammerspoon/config-example.lua ~/.hammerspoon/private/config.lua
```

その後 `~/.hammerspoon/private/config.lua` を編集:

- Spoons の追加／削除  
  `hspoon_list` に読み込む Spoon を列挙（ビルトインは 15 個。詳細は [The built-in Spoons](https://github.com/ashfinal/awesome-hammerspoon/wiki/The-built-in-Spoons)）。
  *公式リポジトリにも Spoons が多数あります: [Hammerspoon Spoons](http://www.hammerspoon.org/Spoons/)（一部は追加設定が必要）。*

- キーバインドの変更  
  詳細は `~/.hammerspoon/private/config.lua` を参照。

編集後は `cmd + ctrl + shift + r` でリロード。

</details>

## コントリビュート

<details>
<summary>詳細</summary>

- 既存 Spoons の改善  
  Spoon は単なるディレクトリです。右クリック→「パッケージの内容を表示」で編集できます。Issue / PR 歓迎。

- 新しい Spoons の作成に役立つリンク  
  [Learn Lua in Y minutes](http://learnxinyminutes.com/docs/lua/)  
  [Getting Started with Hammerspoon](http://www.hammerspoon.org/go/)  
  [Hammerspoon API Docs](http://www.hammerspoon.org/docs/index.html)  
  [hammerspoon/SPOONS.md](https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md)

</details>

## Thanks to

<details>
<summary>詳細</summary>

[https://github.com/zzamboni/oh-my-hammerspoon](https://github.com/zzamboni/oh-my-hammerspoon)  
[https://github.com/scottcs/dot_hammerspoon](https://github.com/scottcs/dot_hammerspoon)  
[https://github.com/dharmapoudel/hammerspoon-config](https://github.com/dharmapoudel/hammerspoon-config)  
[http://tracesof.net/uebersicht/](http://tracesof.net/uebersicht/)

</details>
# hammerspoonConfig
