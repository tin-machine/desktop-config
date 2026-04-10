local M = {}

local config = {
    work_seconds = 25 * 60,
    short_break_seconds = 5 * 60,
    long_break_seconds = 15 * 60,
    long_break_every = 4,
    auto_start_next = true,
    enable_notifications = false,
}

local state = {
    phase = "work",
    remaining = config.work_seconds,
    completed_work_sessions = 0,
    running = false,
    ticker = nil,
    menu = nil,
    dialog = nil,
}

local function phase_label(phase)
    if phase == "work" then
        return "WORK"
    end
    if phase == "short_break" then
        return "BREAK"
    end
    return "LONG"
end

local function phase_seconds(phase)
    if phase == "work" then
        return config.work_seconds
    end
    if phase == "short_break" then
        return config.short_break_seconds
    end
    return config.long_break_seconds
end

local function format_time(total_seconds)
    local minutes = math.floor(total_seconds / 60)
    local seconds = total_seconds % 60
    return string.format("%02d:%02d", minutes, seconds)
end

local function notify(message)
    if not config.enable_notifications then
        return
    end
    hs.notify.new({
        title = "Pomodoro",
        informativeText = message,
    }):send()
end

local function update_menu_title()
    if not state.menu then
        return
    end
    local flag = state.running and ">" or "||"
    local title = string.format("POMO %s %s %s", flag, phase_label(state.phase), format_time(state.remaining))
    state.menu:setTitle(title)
end

local function ensure_dialog()
    if state.dialog then
        return
    end
    local screen = hs.screen.mainScreen()
    local frame = screen:frame()
    local width = 220
    local height = 68
    local x = frame.x + frame.w - width - 20
    local y = frame.y + 20

    state.dialog = hs.canvas.new({ x = x, y = y, w = width, h = height })
    state.dialog:level(hs.canvas.windowLevels.floating)
    state.dialog:behavior({ "canJoinAllSpaces" })
    state.dialog[1] = {
        type = "rectangle",
        action = "fill",
        roundedRectRadii = { xRadius = 8, yRadius = 8 },
        fillColor = { hex = "#1F2937", alpha = 0.92 },
    }
    state.dialog[2] = {
        type = "text",
        text = "",
        textSize = 16,
        textColor = { hex = "#A3E635", alpha = 1 },
        textAlignment = "center",
        frame = { x = "5%", y = "8%", w = "90%", h = "40%" },
    }
    state.dialog[3] = {
        type = "text",
        text = "",
        textSize = 24,
        textColor = { hex = "#A3E635", alpha = 1 },
        textAlignment = "center",
        frame = { x = "5%", y = "45%", w = "90%", h = "45%" },
    }
end

local function update_dialog()
    ensure_dialog()
    if not state.dialog then
        return
    end
    local run_label = state.running and "RUNNING" or "PAUSED"
    state.dialog[2].text = string.format("%s  %s", phase_label(state.phase), run_label)
    state.dialog[3].text = format_time(state.remaining)
    state.dialog:show()
end

local function hide_dialog()
    if state.dialog then
        state.dialog:hide()
    end
end

local function ensure_menu()
    if state.menu then
        return
    end
    state.menu = hs.menubar.new()
    if state.menu then
        state.menu:setClickCallback(function()
            M.toggle()
        end)
    end
end

local function stop_ticker()
    if state.ticker then
        state.ticker:stop()
        state.ticker = nil
    end
end

local function begin_phase(phase, should_run, message)
    state.phase = phase
    state.remaining = phase_seconds(phase)
    state.running = should_run
    if message then
        notify(message)
    end
    update_menu_title()
    update_dialog()
end

local function next_phase()
    if state.phase == "work" then
        state.completed_work_sessions = state.completed_work_sessions + 1
        if state.completed_work_sessions % config.long_break_every == 0 then
            begin_phase("long_break", config.auto_start_next, "Start long break")
            return
        end
        begin_phase("short_break", config.auto_start_next, "Start short break")
        return
    end
    begin_phase("work", config.auto_start_next, "Start work session")
end

local function tick()
    if not state.running then
        return
    end
    state.remaining = state.remaining - 1
    if state.remaining <= 0 then
        hs.sound.getByName("Glass"):play()
        next_phase()
    end
    update_menu_title()
    update_dialog()
end

local function ensure_ticker()
    if state.ticker then
        return
    end
    state.ticker = hs.timer.doEvery(1, tick)
end

function M.toggle()
    ensure_menu()
    ensure_ticker()
    state.running = not state.running
    if state.running then
        notify("Pomodoro started")
    else
        notify("Pomodoro paused")
    end
    update_menu_title()
    update_dialog()
end

function M.skip()
    ensure_menu()
    ensure_ticker()
    next_phase()
    update_menu_title()
    update_dialog()
end

function M.reset()
    stop_ticker()
    begin_phase("work", false, "Pomodoro reset")
    hide_dialog()
end

function M.status()
    return {
        phase = state.phase,
        remaining = state.remaining,
        completed_work_sessions = state.completed_work_sessions,
        running = state.running,
    }
end

ensure_menu()
update_menu_title()
update_dialog()

return M
