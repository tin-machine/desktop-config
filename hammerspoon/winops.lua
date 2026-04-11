local M = {}

M.gridparts = 30
M.history = {}

local function focused_window()
  local win = hs.window.focusedWindow()
  if not win then
    hs.alert.show("No focused window!")
    return nil
  end
  return win
end

local function stash_window(window)
  local winid = window:id()
  if not winid then
    return
  end
  local frame = window:frame()
  table.insert(M.history, 1, { id = winid, frame = frame })
  if #M.history > 50 then
    table.remove(M.history)
  end
end

function M.stepMove(direction)
  local win = focused_window()
  if not win then
    return
  end

  local screen_frame = win:screen():frame()
  local stepw = screen_frame.w / M.gridparts
  local steph = screen_frame.h / M.gridparts
  local top_left = win:topLeft()

  if direction == "left" then
    win:setTopLeft({ x = top_left.x - stepw, y = top_left.y })
  elseif direction == "right" then
    win:setTopLeft({ x = top_left.x + stepw, y = top_left.y })
  elseif direction == "up" then
    win:setTopLeft({ x = top_left.x, y = top_left.y - steph })
  elseif direction == "down" then
    win:setTopLeft({ x = top_left.x, y = top_left.y + steph })
  else
    hs.alert.show("Unknown direction: " .. tostring(direction))
  end
end

function M.stepResize(direction)
  local win = focused_window()
  if not win then
    return
  end

  local screen_frame = win:screen():frame()
  local stepw = screen_frame.w / M.gridparts
  local steph = screen_frame.h / M.gridparts
  local size = win:size()

  if direction == "left" then
    win:setSize({ w = size.w - stepw, h = size.h })
  elseif direction == "right" then
    win:setSize({ w = size.w + stepw, h = size.h })
  elseif direction == "up" then
    win:setSize({ w = size.w, h = size.h - steph })
  elseif direction == "down" then
    win:setSize({ w = size.w, h = size.h + steph })
  else
    hs.alert.show("Unknown direction: " .. tostring(direction))
  end
end

function M.moveAndResize(option)
  local win = focused_window()
  if not win then
    return
  end

  local screen_frame = win:screen():frame()
  local stepw = screen_frame.w / M.gridparts
  local steph = screen_frame.h / M.gridparts
  local frame = win:frame()

  local options = {
    halfleft = function() win:setFrame({ x = screen_frame.x, y = screen_frame.y, w = screen_frame.w / 2, h = screen_frame.h }) end,
    halfright = function() win:setFrame({ x = screen_frame.x + screen_frame.w / 2, y = screen_frame.y, w = screen_frame.w / 2, h = screen_frame.h }) end,
    halfup = function() win:setFrame({ x = screen_frame.x, y = screen_frame.y, w = screen_frame.w, h = screen_frame.h / 2 }) end,
    halfdown = function() win:setFrame({ x = screen_frame.x, y = screen_frame.y + screen_frame.h / 2, w = screen_frame.w, h = screen_frame.h / 2 }) end,
    cornerNW = function() win:setFrame({ x = screen_frame.x, y = screen_frame.y, w = screen_frame.w / 2, h = screen_frame.h / 2 }) end,
    cornerNE = function() win:setFrame({ x = screen_frame.x + screen_frame.w / 2, y = screen_frame.y, w = screen_frame.w / 2, h = screen_frame.h / 2 }) end,
    cornerSW = function() win:setFrame({ x = screen_frame.x, y = screen_frame.y + screen_frame.h / 2, w = screen_frame.w / 2, h = screen_frame.h / 2 }) end,
    cornerSE = function() win:setFrame({ x = screen_frame.x + screen_frame.w / 2, y = screen_frame.y + screen_frame.h / 2, w = screen_frame.w / 2, h = screen_frame.h / 2 }) end,
    fullscreen = function() win:setFullScreen(true) end,
    maximize = function() win:maximize() end,
    center = function() win:centerOnScreen() end,
    expand = function() win:setFrame({ x = frame.x - stepw, y = frame.y - steph, w = frame.w + (stepw * 2), h = frame.h + (steph * 2) }) end,
    shrink = function() win:setFrame({ x = frame.x + stepw, y = frame.y + steph, w = frame.w - (stepw * 2), h = frame.h - (steph * 2) }) end,
  }

  local action = options[option]
  if not action then
    hs.alert.show("Unknown option: " .. tostring(option))
    return
  end

  if option ~= "fullscreen" and win:isFullScreen() then
    win:setFullScreen(false)
    hs.timer.usleep(999999)
  end

  stash_window(win)
  action()
end

function M.moveToScreen(direction)
  local win = focused_window()
  if not win then
    return
  end

  local screen = win:screen()
  if direction == "up" then
    win:moveOneScreenNorth()
  elseif direction == "down" then
    win:moveOneScreenSouth()
  elseif direction == "left" then
    win:moveOneScreenWest()
  elseif direction == "right" then
    win:moveOneScreenEast()
  elseif direction == "next" then
    win:moveToScreen(screen:next())
  else
    hs.alert.show("Unknown direction: " .. tostring(direction))
  end
end

function M.undo()
  local win = focused_window()
  if not win then
    return
  end

  local winid = win:id()
  if not winid then
    return
  end

  for _, item in ipairs(M.history) do
    if item.id == winid then
      win:setFrame(item.frame)
      return
    end
  end
end

function M.centerCursor()
  local win = hs.window.focusedWindow()
  if win then
    local frame = win:frame()
    hs.mouse.setAbsolutePosition({ x = frame.x + frame.w / 2, y = frame.y + frame.h / 2 })
    return
  end

  local screen = hs.screen.mainScreen()
  if not screen then
    return
  end
  local frame = screen:frame()
  hs.mouse.setAbsolutePosition({ x = frame.x + frame.w / 2, y = frame.y + frame.h / 2 })
end

return M
