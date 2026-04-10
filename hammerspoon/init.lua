hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0
local winops = require("winops")
local modalmgr = require("modalmgr")
spoon = spoon or {}
spoon.ModalMgr = modalmgr

-- -- Use the standardized config location, if present
custom_config = hs.fs.pathToAbsolute(os.getenv("HOME") .. '/.config/hammerspoon/private/config.lua')

if custom_config then
    print("Loading custom config")
    dofile( os.getenv("HOME") .. "/.config/hammerspoon/private/config.lua")
    privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privatepath then
        hs.alert("You have config in both .config/hammerspoon and .hammerspoon/private.\nThe .config/hammerspoon one will be used.")
    end
else
    -- otherwise fallback to 'classic' location.
    if not privatepath then
        privatepath = hs.fs.pathToAbsolute(hs.configdir .. '/private')
        -- Create `~/.hammerspoon/private` directory if not exists.
        hs.fs.mkdir(hs.configdir .. '/private')
    end
    privateconf = hs.fs.pathToAbsolute(hs.configdir .. '/private/config.lua')
    if privateconf then
        -- Load awesomeconfig file if exists
        require('private/config')
    end
end

hsreload_keys = hsreload_keys or {{"cmd", "shift", "ctrl"}, "R"}
if string.len(hsreload_keys[2]) > 0 then
    hs.hotkey.bind(hsreload_keys[1], hsreload_keys[2], "Reload Configuration", function() hs.reload() end)
end

-- Define default Spoons which will be loaded later
        -- "BingDaily",
if not hspoon_list then
    hspoon_list = {
    }
end

-- Load those Spoons
for _, v in pairs(hspoon_list) do
    local ok = pcall(hs.loadSpoon, v)
    if not ok then
        hs.printf("Skip loading Spoon: %s", v)
    end
end

----------------------------------------------------------------------------------------------------
-- Then we create/register all kinds of modal keybindings environments.
-- Register Hammerspoon API manual: Open Hammerspoon manual in default browser
-- hsman_keys = hsman_keys or {"alt", "H"}
-- if string.len(hsman_keys[2]) > 0 then
--     spoon.ModalMgr.supervisor:bind(hsman_keys[1], hsman_keys[2], "Read Hammerspoon Manual", function()
--         hs.doc.hsdocs.forceExternalBrowser(true)
--         hs.doc.hsdocs.moduleEntitiesInSidebar(true)
--         hs.doc.hsdocs.help()
--     end)
-- end

-- Register lock screen
-- hslock_keys = hslock_keys or {"alt", "L"}
-- if string.len(hslock_keys[2]) > 0 then
--     spoon.ModalMgr.supervisor:bind(hslock_keys[1], hslock_keys[2], "Lock Screen", function()
--         hs.caffeinate.lockScreen()
--     end)
-- end

----------------------------------------------------------------------------------------------------
-- resizeM modal environment
if winops then
    spoon.ModalMgr:new("resizeM")
    local cmodal = spoon.ModalMgr.modal_list["resizeM"]
    cmodal:bind('', 'escape', 'Deactivate resizeM', function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    cmodal:bind('', 'Q', 'Deactivate resizeM', function() spoon.ModalMgr:deactivate({"resizeM"}) end)
    cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
    cmodal:bind('', 'A', 'Move Leftward', function() winops.stepMove("left") end, nil, function() winops.stepMove("left") end)
    cmodal:bind('', 'D', 'Move Rightward', function() winops.stepMove("right") end, nil, function() winops.stepMove("right") end)
    cmodal:bind('', 'W', 'Move Upward', function() winops.stepMove("up") end, nil, function() winops.stepMove("up") end)
    cmodal:bind('', 'S', 'Move Downward', function() winops.stepMove("down") end, nil, function() winops.stepMove("down") end)
    cmodal:bind('', 'H', 'Lefthalf of Screen', function() winops.moveAndResize("halfleft") end)
    cmodal:bind('', 'L', 'Righthalf of Screen', function() winops.moveAndResize("halfright") end)
    cmodal:bind('', 'K', 'Uphalf of Screen', function() winops.moveAndResize("halfup") end)
    cmodal:bind('', 'J', 'Downhalf of Screen', function() winops.moveAndResize("halfdown") end)
    cmodal:bind('', 'Y', 'NorthWest Corner', function() winops.moveAndResize("cornerNW") end)
    cmodal:bind('', 'O', 'NorthEast Corner', function() winops.moveAndResize("cornerNE") end)
    cmodal:bind('', 'U', 'SouthWest Corner', function() winops.moveAndResize("cornerSW") end)
    cmodal:bind('', 'I', 'SouthEast Corner', function() winops.moveAndResize("cornerSE") end)
    cmodal:bind('', 'F', 'Fullscreen', function() winops.moveAndResize("fullscreen") end)
    cmodal:bind('', 'C', 'Center Window', function() winops.moveAndResize("center") end)
    cmodal:bind('', '=', 'Stretch Outward', function() winops.moveAndResize("expand") end, nil, function() winops.moveAndResize("expand") end)
    cmodal:bind('', '-', 'Shrink Inward', function() winops.moveAndResize("shrink") end, nil, function() winops.moveAndResize("shrink") end)
    cmodal:bind('shift', 'H', 'Move Leftward', function() winops.stepResize("left") end, nil, function() winops.stepResize("left") end)
    cmodal:bind('shift', 'L', 'Move Rightward', function() winops.stepResize("right") end, nil, function() winops.stepResize("right") end)
    cmodal:bind('shift', 'K', 'Move Upward', function() winops.stepResize("up") end, nil, function() winops.stepResize("up") end)
    cmodal:bind('shift', 'J', 'Move Downward', function() winops.stepResize("down") end, nil, function() winops.stepResize("down") end)
    cmodal:bind('', 'left', 'Move to Left Monitor', function() winops.moveToScreen("left") end)
    cmodal:bind('', 'right', 'Move to Right Monitor', function() winops.moveToScreen("right") end)
    cmodal:bind('', 'up', 'Move to Above Monitor', function() winops.moveToScreen("up") end)
    cmodal:bind('', 'down', 'Move to Below Monitor', function() winops.moveToScreen("down") end)
    cmodal:bind('', 'space', 'Move to Next Monitor', function() winops.moveToScreen("next") end)
    cmodal:bind('', '[', 'Undo Window Manipulation', function() winops.undo() end)
    cmodal:bind('', '`', 'Center Cursor', function() winops.centerCursor() end)

    -- Register resizeM with modal supervisor
    hsresizeM_keys = hsresizeM_keys or {"cmd", "R"}
    if string.len(hsresizeM_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hsresizeM_keys[1], hsresizeM_keys[2], "Enter resizeM Environment", function()
            -- Deactivate some modal environments or not before activating a new one
            spoon.ModalMgr:deactivateAll()
            -- Show an status indicator so we know we're in some modal environment now
            spoon.ModalMgr:activate({"resizeM"}, "#B22222")
        end)
    end
end

----------------------------------------------------------------------------------------------------
-- cheatsheetM modal environment (Because KSheet Spoon is NOT loaded, cheatsheetM will NOT be activated)
if spoon.KSheet then
    spoon.ModalMgr:new("cheatsheetM")
    local cmodal = spoon.ModalMgr.modal_list["cheatsheetM"]
    cmodal:bind('', 'escape', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)
    cmodal:bind('', 'Q', 'Deactivate cheatsheetM', function()
        spoon.KSheet:hide()
        spoon.ModalMgr:deactivate({"cheatsheetM"})
    end)

    -- Register cheatsheetM with modal supervisor
    hscheats_keys = hscheats_keys or {"alt", "S"}
    if string.len(hscheats_keys[2]) > 0 then
        spoon.ModalMgr.supervisor:bind(hscheats_keys[1], hscheats_keys[2], "Enter cheatsheetM Environment", function()
            spoon.KSheet:show()
            spoon.ModalMgr:deactivateAll()
            spoon.ModalMgr:activate({"cheatsheetM"})
        end)
    end
end

-- Finally we initialize ModalMgr supervisor
spoon.ModalMgr.supervisor:enter()
