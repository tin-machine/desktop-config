--# selene: allow(unused_variable)
---@diagnostic disable: unused-local

-- Windows manipulation
--
-- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/WinWin.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/WinWin.spoon.zip)
---@class spoon.WinWin
local M = {}
spoon.WinWin = M

-- Center the cursor on the focused window.
-- 
function M:centerCursor() end

-- An integer specifying how many gridparts the screen should be divided into. Defaults to 30.
M.gridparts = nil

-- Move and resize the focused window.
--
-- Parameters:
--  * option - A string specifying the option, valid strings are: `halfleft`, `halfright`, `halfup`, `halfdown`, `cornerNW`, `cornerSW`, `cornerNE`, `cornerSE`, `center`, `fullscreen`, `maximize`, `minimize`, `expand`, `shrink`.
function M:moveAndResize(option, ...) end

-- Move the focused window between all of the screens in the `direction`.
--
-- Parameters:
--  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`, `next`.
function M:moveToScreen(direction, ...) end

-- Move the focused window in the `direction` by on step. The step scale equals to the width/height of one gridpart.
--
-- Parameters:
--  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.
function M:stepMove(direction, ...) end

-- Resize the focused window in the `direction` by on step.
--
-- Parameters:
--  * direction - A string specifying the direction, valid strings are: `left`, `right`, `up`, `down`.
function M:stepResize(direction, ...) end

-- Undo the last window manipulation. Only those "moveAndResize" manipulations can be undone.
-- 
function M:undo() end

