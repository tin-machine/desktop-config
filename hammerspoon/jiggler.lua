local M = {}

local INTERVAL = 4 * 60 + 45
local timer = nil
local menubar = hs.menubar.new()

local function jiggle()
  local pos = hs.mouse.absolutePosition()
  hs.mouse.absolutePosition({ x = pos.x + 1, y = pos.y })
  hs.timer.doAfter(0.1, function()
    hs.mouse.absolutePosition(pos)
  end)
end

local function updateMenu()
  if timer then
    menubar:setTitle("🐭")
    menubar:setMenu({
      { title = "Jiggler: ON", disabled = true },
      { title = "-" },
      { title = "Stop", fn = function() M.stop() end },
    })
  else
    menubar:setTitle("🐭💤")
    menubar:setMenu({
      { title = "Jiggler: OFF", disabled = true },
      { title = "-" },
      { title = "Start", fn = function() M.start() end },
    })
  end
end

function M.start()
  if timer then return end
  timer = hs.timer.doEvery(INTERVAL, jiggle)
  updateMenu()
end

function M.stop()
  if timer then
    timer:stop()
    timer = nil
  end
  updateMenu()
end

function M.toggle()
  if timer then M.stop() else M.start() end
end

updateMenu()

return M
