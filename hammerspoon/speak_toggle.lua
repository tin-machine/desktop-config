-- Claude Code の音声読み上げをメニューバーから ON/OFF する
-- ~/.claude/hooks/speak.sh と speak-permission.sh はフラグファイルがあると読み上げない
--   speak-disabled            : 応答終了時（Stop hook）
--   speak-permission-disabled : 許可リクエスト時（PermissionRequest hook）
-- このボタンは 2 つをまとめて作成 / 削除する
local M = {}

local CLAUDE_DIR = os.getenv("HOME") .. "/.claude"
local FLAGS = {
  CLAUDE_DIR .. "/speak-disabled",
  CLAUDE_DIR .. "/speak-permission-disabled",
}

local menubar = hs.menubar.new()
local watcher = nil

local function exists(path)
  return hs.fs.attributes(path) ~= nil
end

-- 戻り値: "on"（どちらも読み上げる） / "off"（どちらも止める） / "partial"（片方だけ止まっている）
local function state()
  local disabled = 0
  for _, f in ipairs(FLAGS) do
    if exists(f) then disabled = disabled + 1 end
  end
  if disabled == 0 then return "on" end
  if disabled == #FLAGS then return "off" end
  return "partial"
end

local function updateMenu()
  local s = state()
  if s == "on" then
    menubar:setTitle("🔊")
    menubar:setTooltip("Claude 読み上げ: ON（クリックで停止）")
  elseif s == "off" then
    menubar:setTitle("🔇")
    menubar:setTooltip("Claude 読み上げ: OFF（クリックで再開）")
  else
    menubar:setTitle("🔉")
    menubar:setTooltip("Claude 読み上げ: 一部だけ停止中（クリックで全部停止）")
  end
end

function M.disable()
  for _, f in ipairs(FLAGS) do
    if not exists(f) then
      local fh = io.open(f, "w")
      if fh then fh:close() end
    end
  end
  updateMenu()
end

function M.enable()
  for _, f in ipairs(FLAGS) do
    if exists(f) then os.remove(f) end
  end
  updateMenu()
end

-- 片方でも読み上げていれば止める。両方止まっていれば再開する
function M.toggle()
  if state() == "off" then M.enable() else M.disable() end
end

menubar:setClickCallback(M.toggle)

-- ターミナルから touch / rm されたときもアイコンを追従させる
-- ~/.claude 配下は transcript などで頻繁に変わるため、フラグファイルのパスだけを見る
local isFlag = {}
for _, f in ipairs(FLAGS) do isFlag[f] = true end
watcher = hs.pathwatcher.new(CLAUDE_DIR, function(paths)
  for _, p in ipairs(paths) do
    if isFlag[p] then
      updateMenu()
      return
    end
  end
end):start()

updateMenu()

M.watcher = watcher
return M
