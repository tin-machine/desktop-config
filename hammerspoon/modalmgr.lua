local M = {
    modal_list = {},
    active_list = {},
}

local function create_modal_tray()
    local tray = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
    tray:level(hs.canvas.windowLevels.tornOffMenu)
    tray[1] = {
        type = "circle",
        action = "fill",
        fillColor = { hex = "#FFFFFF", alpha = 0.7 },
    }
    return tray
end

local function show_modal_tray(tray, color)
    local cscreen = hs.screen.mainScreen()
    local frame = cscreen:fullFrame()
    local size = math.ceil(frame.w / 64)
    tray:frame({
        x = frame.w - size * 2,
        y = frame.h - size * 2,
        w = size,
        h = size,
    })
    tray[1].fillColor = { hex = color, alpha = 0.7 }
    tray:show()
end

M.modal_tray = create_modal_tray()

hsupervisor_keys = hsupervisor_keys or { { "cmd", "shift", "ctrl" }, "Q" }
M.supervisor = hs.hotkey.modal.new(hsupervisor_keys[1], hsupervisor_keys[2], "Initialize Modal Environment")
M.supervisor:bind(hsupervisor_keys[1], hsupervisor_keys[2], "Reset Modal Environment", function()
    M.supervisor:exit()
end)

function M:new(id)
    self.modal_list[id] = hs.hotkey.modal.new()
end

function M:toggleCheatsheet(_, _)
    -- Intentionally no-op: this config does not use cheatsheet UI anymore.
end

function M:activate(id_list, tray_color, show_keys)
    for _, id in ipairs(id_list or {}) do
        local modal = self.modal_list[id]
        if modal then
            modal:enter()
            self.active_list[id] = modal
        end
    end

    if tray_color then
        show_modal_tray(self.modal_tray, tray_color)
    end

    if show_keys then
        self:toggleCheatsheet(id_list, true)
    end
end

function M:deactivate(id_list)
    for _, id in ipairs(id_list or {}) do
        local modal = self.modal_list[id]
        if modal then
            modal:exit()
        end
        self.active_list[id] = nil
    end
    self.modal_tray:hide()
end

function M:deactivateAll()
    local ids = {}
    for id, _ in pairs(self.active_list) do
        table.insert(ids, id)
    end
    self:deactivate(ids)
end

return M
