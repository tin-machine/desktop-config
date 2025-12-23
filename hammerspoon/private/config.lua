--[[ インストール
* hammerspoon
  brew cask install hammerspoon
]]

--[[ キーコードを取得する
  Karabiner 使えない対策: Hammerspoon で macOS の修飾キーつきホットキーのキーリマップを実現する
  http://qiita.com/naoya@github/items/81027083aeb70b309c14
  keyCode('return')と渡すとキーコードを返してくれるような関数っぽい
]]
local function keyCode(key, modifiers)
   modifiers = modifiers or {}
   return function()
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
      hs.timer.usleep(1000)
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()      
   end
end

--[[ セミコロンとエンターを入れ替える処理
* ここが参考になった
  https://memo.sugyan.com/entry/2017/05/09/223704
  hs.eventtap.keyStrokes(';')
  を使っている。 keyStroke()ではなく、 keyStrokes()と複数形な所がポイント
  hs.hotkey.bind(mods, key, message, pressedfn, releasedfn, repeatfn)
  https://www.hammerspoon.org/docs/hs.hotkey.html#bind
  自作キーボードにして不要になった。
  '"
]]
-- hs.hotkey.bind({''}, ';', keyCode('return'), nil, keyCode('return'))
-- local function pushSemiColon()
--    return function()
--       hs.eventtap.keyStrokes(';')
--    end
-- end
-- hs.hotkey.bind({'ctrl'}, ';', pushSemiColon(), nil, pushSemiColon())

-- デスクトップのスペースの移動はmacデフォルト機能に移動した
-- [システム環境設定]->[キーボード]->[ショートカット]->[Mission Control]

-- mac の Finder を新しく開く
hs.hotkey.bind({'alt'}, 'e', function()
  hs.application.launchOrFocus("Finder")
  spoon.WinWin:moveAndResize("maximize")
end)

-- Slack にフォーカス
hs.hotkey.bind({'alt'}, 'g', function()
  hs.application.launchOrFocus("Slack")
  spoon.WinWin:moveAndResize("maximize")
end)

-- Firefox にフォーカス
hs.hotkey.bind({'alt'}, 'm', function()
  hs.application.launchOrFocus("Firefox")
  spoon.WinWin:moveAndResize("maximize")
end)

-- Asanaにフォーカス
hs.hotkey.bind({'alt'}, '/', function()
  hs.application.launchOrFocus("Asana")
  spoon.WinWin:moveAndResize("maximize")
end)

-- -- Meetをアクティブにする
-- hs.hotkey.bind({'cmd'}, '/', function()
--     -- 「Meet」で始まるウィンドウタイトルにマッチするフィルタを作成
--     local meetFilter = hs.window.filter.new(function(win)
--         return string.sub(win:title(), 1, 4) == "Meet"
--     end)
-- 
--     -- フィルタにマッチする最初のウィンドウを取得
--     local meetWindow = meetFilter:getWindows()[1]
-- 
--     if meetWindow then
--         -- ウィンドウが見つかった場合、フォーカスを移動
--         meetWindow:focus()
--     else
--         hs.alert.show("「Meet」で始まるウィンドウが見つかりません")
--     end
-- end)

-- Wezterm にフォーカス
hs.hotkey.bind({'alt'}, 'n', function()
  hs.application.launchOrFocus("Wezterm")
  spoon.WinWin:moveAndResize("maximize")
end)

-- Obsibian にフォーカス
hs.hotkey.bind({'alt'}, ',', function()
  hs.application.launchOrFocus("Obsidian")
  spoon.WinWin:moveAndResize("maximize")
end)

-- Chrome にフォーカス
hs.hotkey.bind({'alt'}, '.', function()
  hs.application.launchOrFocus("Google Chrome")
  spoon.WinWin:moveAndResize("maximize")
end)

-- ウィンドウを左へ
hs.hotkey.bind({'alt', 'shift'}, 'h', function()
  spoon.WinWin:moveToScreen("left")
  spoon.WinWin:moveAndResize("maximize")
end)

-- ウィンドウを下へ
hs.hotkey.bind({'alt', 'shift'}, 'j', function()
  spoon.WinWin:moveToScreen("down")
  spoon.WinWin:moveAndResize("maximize")
end)

-- ウィンドウを上へ
hs.hotkey.bind({'alt', 'shift'}, 'k', function()
  spoon.WinWin:moveToScreen("up")
  spoon.WinWin:moveAndResize("maximize")
end)

-- ウィンドウを右へ
hs.hotkey.bind({'alt', 'shift'}, 'l', function()
  spoon.WinWin:moveToScreen("right")
  spoon.WinWin:moveAndResize("maximize")
end)

-- ウィンドウを左半分
hs.hotkey.bind({'alt', 'ctrl'}, 'h', function()
  spoon.WinWin:moveAndResize("halfleft")
end)

-- ウィンドウを下半分
hs.hotkey.bind({'alt', 'ctrl'}, 'j', function()
  spoon.WinWin:moveAndResize("halfdown")
end)

-- ウィンドウを上半分
hs.hotkey.bind({'alt', 'ctrl'}, 'k', function()
  spoon.WinWin:moveAndResize("halfup")
end)

-- ウィンドウを右半分
hs.hotkey.bind({'alt', 'ctrl'}, 'l', function()
  spoon.WinWin:moveAndResize("halfright")
end)

-- タスクスイッチャー alt + t
function switchToNextWindow()
    local app = hs.application.frontmostApplication()
    local windows = app:visibleWindows() -- 現在のアプリのすべての可視ウィンドウを取得
    -- ウィンドウタイトルでソートする(app:visibleWindows()は都度、変わる配列を返すので
    -- 「次のウィンドウ」に行きたい場合、都度、変わる配列ではなくソート済みである必要がある。
    table.sort(windows, function(a, b) return a:title() < b:title() end)
    local currentWindow = app:focusedWindow() -- 現在フォーカスされているウィンドウを取得
    local nextWindowIndex = nil

    for i, window in ipairs(windows) do
        if window == currentWindow then
            nextWindowIndex = i + 1
            break
        end
    end

    -- ウィンドウリストの末尾に達した場合、最初のウィンドウに戻る
    if not nextWindowIndex or nextWindowIndex > #windows then
        nextWindowIndex = 1
    end

    windows[nextWindowIndex]:focus() -- 次のウィンドウにフォーカスを移動
end

-- キーボードショートカットを設定（例: Alt + t）
hs.hotkey.bind({"alt"}, "t", function()
  switchToNextWindow()
end)



-- --[[
-- キーコード入力を表示する関数
-- http://kitak.hatenablog.jp/entry/2016/11/28/104038
-- ]]
-- local function showKeyPress(tapEvent)
--     local charactor = hs.keycodes.map[tapEvent:getKeyCode()]
--     hs.alert.show(charactor, 1.5)
-- end
-- 
-- --[[
-- 下のキーコード表示のショートカットで呼び出す
-- ]]
-- local keyTap = hs.eventtap.new(
--   {hs.eventtap.event.types.keyDown},
--   showKeyPress
-- )
-- 
-- -- --[[
-- -- command + shift + ctrl + p で
-- -- キーコードを表示
-- -- ]]
-- hs.hotkey.bind({'cmd', "shift", "ctrl"}, 'y', function()
--   hs.alert.show("Enabling Keypress Show Mode", 1.5)
--   keyTap:start()
-- end)
-- 
-- -- --[[
-- -- command + shift + ctrl + p で
-- -- キーコードを表示を止める
-- -- ]]
-- hs.hotkey.bind({'cmd', "shift", "ctrl"}, 'y', function()
--   hs.alert.show("Disabling Keypress Show Mode", 1.5)
--   keyTap:stop()
-- end)

-- 
-- -- spaceを移動
-- -- https://gist.github.com/TwoLeaves/a9d226ac98be5109a226
-- -- apiの使い方 https://github.com/asmagill/hs._asm.undocumented.spaces
-- -- spaces = require("hs._asm.undocumented.spaces")
-- -- screen = require("hs.screen")
-- 
function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- -- カーソル移動
-- hs.hotkey.bind({'shift', 'cmd'}, 'l', keyCode('right'))
-- hs.hotkey.bind({'shift', 'cmd'}, 'h', keyCode('left'))
-- hs.hotkey.bind({'shift', 'cmd'}, 'j', keyCode('down'))
-- hs.hotkey.bind({'shift', 'cmd'}, 'k', keyCode('up'))
-- 
-- --- アプリケーション・スイッチャ
-- --- http://www.hammerspoon.org/docs/hs.window.switcher.html#nextWindow
hs.hotkey.bind({'ctrl', 'alt'}, 'f', function()
  hs.window.switcher.nextWindow()
end)

-- 
-- -- -- Windowを移動 この関数は動かない
-- -- local function moveWindow()
-- --   -- spaces.moveWindowToSpace(windowID, spaceID) -> spaceID
-- --   currentSpace = spaces.activeSpace()
-- --   activeWindow =  hs.window.focusedWindow():id()
-- --   activeSpace = spaces.raw.activeSpace()
-- --   spaces.moveWindowToSpace(activeWindow, 1)
-- -- end
-- 
-- --[[
--   screenUUIDのテーブルを作っている背景だが、macのスクリーンは[デスクトップ1][デスクトップ2]のspaceIDは順番になっている訳ではなく
--   デスクトップ2のspaceIDが6だったりする。
--   スペースを移動する際に使用する関数 spaces.changeToSpace()の引数はspaceIDを受け取る。
--   なので『現在のactiveSpaceから隣のスペースに移動したい』というケースでは
--   『spaceIDからスペースの順番』が分かるテーブルがあった方が便利
-- ]]
-- -- local function getScreenUuid()
-- --   screenUUID = {}
-- --   screenlayout = spaces.layout()[spaces.mainScreenUUID()]
-- --   for i = 1, #screenlayout do
-- --     screenUUID[screenlayout[i]] = i
-- --   end
-- --   return screenUUID
-- -- end
-- 
-- -- --[[
-- --   ワークスペースの変更、他から呼ばれる
-- -- ]]
-- local function spaceChange(targetSpace)
-- -- 
-- --   --[[ デバック用、現在のスクリーンIDや、現状のスクリーンのレイアウトを表示したい場合
-- --   hs.alert.show(
-- --     "spaceChange()の引数、何番目のスクリーンを目指しているか: " .. targetSpace .. 
-- --     "\nレイアウト(spaces.layout()で取得): " .. dump(spaces.layout()[spaces.mainScreenUUID()]) ..  
-- --     "\nscreenUUIDテーブルの中身: " .. dump(getScreenUuid()) ..
-- --     "\n現在のspaceID(activeSpace()で取得): " .. spaces.activeSpace()
-- --   , 60)
-- --   ]]
-- --   spaces.changeToSpace(spaces.layout()[spaces.mainScreenUUID()][targetSpace])
-- --   --[[
-- --   hs.alert.show( "移動後のspaceID(activeSpace()で取得): " .. spaces.activeSpace() , 60)
-- --   ]]
-- --   hs.alert.show(getScreenUuid()[spaces.activeSpace()] .. "番目のスクリーン", 2)
-- end
-- -- 
-- -- -- アプリケーションを別のスペースに移動
-- -- function MoveWindowToSpace(targetSpace)
-- --     local win = hs.window.focusedWindow()      -- アクティブなウィンドー
-- --     sp = spaces.layout()[spaces.mainScreenUUID()][targetSpace]
-- --     spaces.moveWindowToSpace(win:id(), sp) -- 別のスペースにウィンドーを移動
-- -- end
-- -- 
-- -- -- 左側のワークスペースに移動
-- -- hs.hotkey.bind({'ctrl', 'cmd'}, 'h', function()
-- --   spaceChange(getScreenUuid()[spaces.activeSpace()] - 1)
-- -- end)
-- -- 
-- -- -- 右側のワークスペースに移動
-- -- hs.hotkey.bind({'ctrl', 'cmd'}, 'l', function()
-- --   spaceChange(getScreenUuid()[spaces.activeSpace()] + 1)
-- -- end)
-- 
-- -- Slack用のワークスペース
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'y', function()
--   spaceChange(1)
--   hs.application.launchOrFocus("Slack")
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
-- end)
-- 
-- -- ターミナル 1つめ
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'u', function()
--   spaceChange(2)
--   hs.application.launchOrFocus("terminal1") 
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
-- end)
-- 
-- -- ターミナル 2つめ
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'i', function()
--   spaceChange(2)
--   hs.application.launchOrFocus("terminal2") 
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
-- end)
-- 
-- -- アクティブなウィンドーをターミナル用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd', 'shift'}, 'i', function()
--   MoveWindowToSpace(2)
--   spaceChange(2)
-- end)
-- 
-- -- w3m 1つめ
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'o', function()
--   spaceChange(3)
--   hs.application.launchOrFocus("w3m1") 
--   os.execute("/Users/kaoru-inoue/Documents/workspace/src/github.com/tin-machine/desktop-utility/bin/search")
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
--   -- hs.application.launchOrFocus("Google Chrome") -- 新しいWindowでchromeを開きたい。 
--   -- open -na "Google Chrome" --args --new-window https://google.com というコマンドライン行だが、オプションを設定する方法が見つからない
-- end)
-- 
-- -- w3m 2つめ
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'p', function()
--   spaceChange(3)
--   hs.application.launchOrFocus("w3m2") 
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
-- end)
-- 
-- -- 総務系ブラウザ
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'n', function()
--   spaceChange(4)
--   -- hs.application.launchOrFocus("Google Chrome") -- 新しいWindowでchromeを開きたい。 
--   -- hs.application.open('Google Chrome', 15, true)
--   -- window:focus()
--   -- local forcused = hs.application.launchOrFocus("Google Chrome") 
--   -- 下記のコードは hammerspoon, space用ライブラリのアプデ後、試す
--   -- if hs.application.launchOrFocus("Google Chrome") then
--   --   hs.alert.show("既存のWindowをアクティブに", 1.5)
--   -- else
--   --   hs.execute('open -na "Google Chrome" --args -new-window https://google.com', with_user_env)
--   -- end
--   hs.application.launchOrFocus("Google Chrome") -- 新しいWindowでchromeを開きたい。 
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
--   hs.alert.show("総務系のサービス", 1.5)
-- end)
-- 
-- -- ブラウザ用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd'}, 'm', function()
--   spaceChange(5)
--   hs.alert.show("ブラウザ", 1.5)
--   window:focus()
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
-- end)
-- 
-- -- アクティブなウィンドーをブラウザ用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd', 'shift'}, 'm', function()
--   MoveWindowToSpace(5)
--   spaceChange(5)
-- end)
-- 
-- -- AWS管理画面用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd'}, ',', function()
--   spaceChange(6)
--   hs.alert.show("AWS管理画面", 1.5)
--   -- if hs.application.launchOrFocus("Google Chrome") then
--   --   hs.alert.show("既存のWindowをアクティブに", 1.5)
--   -- else
--     hs.execute('open -na "Google Chrome" --args -new-window https://google.com', with_user_env)
--   -- end
--   window:focus()
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
-- end)
-- 
-- -- アクティブなウィンドーをAWS管理画面用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd', 'shift'}, ',', function()
--   MoveWindowToSpace(6)
--   spaceChange(6)
-- end)
-- 
-- -- DB用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd'}, '[', function()
--   spaceChange(7)
--   window:focus()
--   hs.alert.show("DB用", 1.5)
-- end)
-- 
-- -- VSCode用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd'}, ']', function()
--   spaceChange(8)
--   window:focus()
--   hs.alert.show("VSCode", 1.5)
-- end)
-- 
-- -- Github、電卓用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd'}, '.', function()
--   spaceChange(9)
--   window:focus()
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
--   hs.alert.show("Github", 1.5)
-- end)
-- 
-- -- ビデオ会議用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd'}, '0', function()
--   spaceChange(10)
--   hs.application.launchOrFocus("LadioCast")
--   hs.application.launchOrFocus("Activity Monitor")
--   --[[ 『ミーティングの近くだったら』という条件ができたら自動実行したい
--   if os.date("*t")["hour"] < 19 then
--     hs.application.launchOrFocus("3teneFREE_beta")
--     hs.application.launchOrFocus("OBS")
--     hs.alert.show("ビデオ会議", 1.5)
--   end
--   ]]
--   hs.application.launchOrFocus("Google Chrome")
--   spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen")
-- end)
-- 
-- -- アクティブなウィンドーをビデオ会議用スペースに移動
-- hs.hotkey.bind({'ctrl', 'cmd', 'shift'}, '0', function()
--   MoveWindowToSpace(10)
--   spaceChange(10)
-- end)
-- 
-- --[[
-- テキストフィールドを出す
-- https://www.hammerspoon.org/docs/hs.dialog.html#textPrompt
-- これで入力を受け取って、w3mで表示させたい。
-- ターミナルで行っているように、『全面に出す』を行う
-- ]]
-- hs.hotkey.bind({'ctrl', 'cmd'}, '9', function() 
--   hs.dialog.textPrompt("Main message.", "Please enter something:", "Default Value", "OK", "Cancel")
-- end)
-- 
-- hs.hotkey.bind({"cmd", "ctrl"}, "w", function()
-- --  下記のダイヤログは作りかけ
-- --  wlist = hs.window.orderedWindows()
-- --  for i, window in ipairs(visibleWindows) do
-- --    hs.notify.new({title="Hammerspoon", informativeText=window:application():title()}):send()
-- --  end
-- end)
-- 
-- -- Step 1: Take care, that Hammerspoon is the default browser
-- if hs.urlevent.getDefaultHandler("http") ~= "org.hammerspoon.hammerspoon" then
--     hs.urlevent.setDefaultHandler("http")
-- end
-- 
-- -- Step 2: Setup the browser menu
-- local active_browser     = hs.settings.get("active_browser") or "com.apple.safari"
-- local browser_menu       = hs.menubar.new()
-- local available_browsers = {
--     ["com.apple.safari"] = {
--         name = "Safari",
--         -- icon = os.getenv("HOME") .. "/.hammerspoon/browsermenu/safari.png"
--     },
--     ["org.mozilla.firefox"] = {
--         name = "Firefox",
--         -- icon = os.getenv("HOME") .. "/.hammerspoon/browsermenu/firefox.png"
--     },
--     ["w3m"] = {
--         name = "w3m",
--         -- icon = os.getenv("HOME") .. "/.hammerspoon/browsermenu/chrome.png"
--     },
--     ["com.google.chrome"] = {
--         name = "Google Chrome",
--         -- icon = os.getenv("HOME") .. "/.hammerspoon/browsermenu/chrome.png"
--     },
-- }
-- 
-- function init_browser_menu()
--     local menu_items = {}
-- 
--     for browser_id, browser_data in pairs(available_browsers) do
--         -- local image = hs.image.imageFromPath(browser_data["icon"]):setSize({w=16, h=16})
-- 
--         if browser_id == active_browser then
--             browser_menu:setIcon(image)
--         end
-- 
--         table.insert(menu_items, {
--             title   = browser_data["name"],
--             image   = image,
--             checked = browser_id == active_browser,
--             fn      = function()
--                 active_browser = browser_id
--                 hs.settings.set("active_browser", browser_id)
--                 init_browser_menu()
--             end
--         })
--     end
-- 
--     browser_menu:setMenu(menu_items)
-- end
-- 
-- init_browser_menu()
-- 
-- -- Step 3: Register a handler for opening URLs
-- hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
--     if active_browser == 'w3m' then
--       commandString1 = 'ssh -Y inoue@home "tmux -L 2nd  new-window w3m -sixel "'
--       commandString2 = commandString1..fullURL
--       hs.execute(commandString2)
--     else 
--       hs.urlevent.openURLWithBundle(fullURL, active_browser)
--     end
-- end
-- 
-- -- Initialize
-- -- currentSpace = tostring(spaces.currentSpace())
-- for key, val in pairs(spaces) do
--    print(key, val)
-- end
-- 
-- --[[
-- 
-- -- テキスト編集
-- remapKey({'ctrl'}, 'w', keyCode('x', {'cmd'}))
-- remapKey({'ctrl'}, 'y', keyCode('v', {'cmd'}))
-- 
-- -- コマンド
-- remapKey({'ctrl'}, 's', keyCode('f', {'cmd'}))
-- remapKey({'ctrl'}, '/', keyCode('z', {'cmd'}))
-- remapKey({'ctrl'}, 'g', keyCode('escape'))
-- 
-- -- ページスクロール
-- remapKey({'ctrl'}, 'v', keyCode('pagedown'))
-- remapKey({'alt'}, 'v', keyCode('pageup'))
-- remapKey({'cmd', 'shift'}, ',', keyCode('home'))
-- remapKey({'cmd', 'shift'}, '.', keyCode('end'))
-- ]]
-- 
-- -- アプリケーションごとに挙動を変えるサンプル
-- -- iTerm2でキーボードショートカットを使わないようにする
-- --[[
-- local function handleGlobalAppEvent(name, event, app)
--    if event == hs.application.watcher.activated then
--       -- hs.alert.show(name)
--       if name ~= "iTerm2" then
--          enableAllHotkeys()
--       else
--          disableAllHotkeys()
--       end
--    end
-- end
-- appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
-- appsWatcher:start()
-- --]]
-- 
-- --[[
-- -- Get output of a bash command
-- function os.capture(cmd)
--   local f = assert(io.popen(cmd, 'r'))
--   local s = assert(f:read('*a'))
--   f:close()
--   s = string.gsub(s, '^%s+', '')
--   s = string.gsub(s, '%s+$', '')
--   s = string.gsub(s, '[\n\r]+', ' ')
--   return s
-- end
-- ]]
