--[[
  To-Do Addon for Windower 4
  Author: Unlce Awesome
  Version: 1.7
  Description:
    A simple to-do list addon that allows players to manage personal and shared tasks.
    Tasks can be added, removed, completed, and shared using commands.
    Personal tasks are stored in data/<character>/tasks.txt.
    Shared tasks are stored in data/shared_tasks.txt.
    Tasks are visually displayed with optional color coding.
]]

-- Addon metadata
_addon.name = 'todo'
_addon.version = '1.7'
_addon.author = 'Unlce Awesome'
_addon.commands = {'todo'}

-- Required Windower libraries
require('logger')
config = require('config')
texts = require('texts')

-- Default settings for config
local defaults = {
    pos = {
        x = 100,
        y = 100
    },
    visible_on_start = false,
    font_size = 12,
}
local settings = config.load(defaults)

-- Determine current player name for task file pathing
local player_name = windower.ffxi.get_player() and windower.ffxi.get_player().name or 'default'
local char_dir = windower.addon_path .. 'data/' .. player_name .. '/'
local char_file = char_dir .. 'tasks.txt'
local shared_path = windower.addon_path .. 'data/shared_tasks.txt'

-- Configure the text box UI using Windower's text system
local visible = false
local box_settings = {
    pos = { x = settings.pos.x, y = settings.pos.y },
    text = { font = 'Arial', size = settings.font_size, alpha = 255 },
    bg = { alpha = 150 },
    flags = { draggable = true },
}
local box = texts.new(box_settings, true)
box:hide()

-- Track box position to persist it across sessions
local last_pos = { x = settings.pos.x, y = settings.pos.y }
windower.register_event('prerender', function()
    if visible then
        local x, y = box:pos()
        if x ~= last_pos.x or y ~= last_pos.y then
            settings.pos.x = x
            settings.pos.y = y
            config.save(settings)
            last_pos.x, last_pos.y = x, y
        end
    end
end)

-- Task list in memory
local tasks = {}

-- Ensure directory exists for personal task files
local function ensure_char_dir()
    local sep = package.config:sub(1,1)
    local mkdir_command = 'mkdir "' .. char_dir .. '"'
    if sep == '\\' then
        mkdir_command = 'if not exist "' .. char_dir .. '" mkdir "' .. char_dir .. '"'
    end
    os.execute(mkdir_command)
end

-- Save personal tasks to file
local function save_personal_tasks()
    ensure_char_dir()
    local f = io.open(char_file, 'w')
    if not f then error("Could not write to " .. char_file) end
    for _, task in ipairs(tasks) do
        f:write(task .. "\n")
    end
    f:close()
end

-- Load personal tasks from file
local function load_personal_tasks()
    local f = io.open(char_file, 'r')
    if not f then return {} end
    local loaded = {}
    for line in f:lines() do
        if line and line:match("%S") then
            table.insert(loaded, line)
        end
    end
    f:close()
    return loaded
end

-- Save shared tasks to the shared file (used in special command only)
local function save_shared_tasks()
    local f = io.open(shared_path, 'w')
    if not f then error("Could not write to shared_tasks.txt") end
    for _, task in ipairs(tasks) do
        f:write(task .. "\n")
    end
    f:close()
end

-- Load shared tasks and tag them for display
local function load_shared_tasks()
    local f = io.open(shared_path, 'r')
    if not f then
        log("No shared_tasks.txt found.")
        return {}
    end
    local loaded = {}
    for line in f:lines() do
        if line and line:match("%S") then
            table.insert(loaded, "[shared]" .. line)
        end
    end
    f:close()
    return loaded
end

-- Update the UI display box with colored, indexed tasks
local function update_box()
    if not visible then return end
    local output = "To-Do List:\n"
    for i, task in ipairs(tasks) do
        local is_shared = task:sub(1, 8) == "[shared]"
        local is_completed = task:sub(1, 4) == "[X] "

        if is_shared then
            local clean_task = task:sub(9)
            output = output .. string.format("[%d] \\cs(50,205,50)%s\\cr\n", i, clean_task) -- Lime Green

        elseif is_completed then
            local clean_task = task:sub(5)
            output = output .. string.format("[%d] \\cs(70,130,180)[X] %s\\cr\n", i, clean_task) -- Steel Blue

        else
            output = output .. string.format("[%d] \\cs(135,206,235)%s\\cr\n", i, task) -- Sky Blue
        end
    end
    box:text(output)
end

-- Command handler for in-game commands
windower.register_event('addon command', function(cmd, ...)
    local args = {...}
    cmd = cmd and cmd:lower() or nil

    if cmd == 'start' then
        tasks = load_shared_tasks()
        for _, task in ipairs(load_personal_tasks()) do
            table.insert(tasks, task)
        end
        visible = true
        box:show()
        update_box()

    elseif cmd == 'stop' then
        visible = false
        box:hide()

    elseif cmd == 'add' then
        local task = table.concat(args, ' ')
        if task ~= '' then
            table.insert(tasks, task)
            save_personal_tasks()
            update_box()
            log("Added task: " .. task)
        else
            log("Usage: //todo add <task>")
        end

    elseif cmd == 'remove' then
        local index = tonumber(args[1])
        if index and tasks[index] then
            log("Removed task: " .. tasks[index])
            table.remove(tasks, index)
            save_personal_tasks()
            update_box()
        else
            log("Usage: //todo remove <index>")
        end

    elseif cmd == 'complete' then
        local index = tonumber(args[1])
        if index and tasks[index] then
            tasks[index] = "[X] " .. tasks[index]
            save_personal_tasks()
            update_box()
            log("Completed task: " .. tasks[index])
        else
            log("Usage: //todo complete <index>")
        end

    elseif cmd == 'uncomplete' then
        local index = tonumber(args[1])
        if index and tasks[index] then
            tasks[index] = tasks[index]:gsub("^%[X%] ", "")
            save_personal_tasks()
            update_box()
            log("Uncompleted task: " .. tasks[index])
        else
            log("Usage: //todo uncomplete <index>")
        end

    elseif cmd == 'fontsize' then
        local size = tonumber(args[1])
        if size and size >= 6 and size <= 48 then
            settings.font_size = size
            config.save(settings)
            box:size(size)
            update_box()
            log("Font size set to " .. size)
        else
            log("Usage: //todo fontsize <6-48>")
        end

    elseif cmd == 'share' then
        local index = tonumber(args[1])
        if index and tasks[index] then
            local f = io.open(shared_path, 'a')
            if not f then error("Could not write to shared_tasks.txt") end
            local task = tasks[index]
            if task:sub(1, 8) ~= "[shared]" then
                task = task:gsub("^%[X%] ", "")
                f:write(task .. "\n")
                f:close()
                log("Shared task [" .. index .. "]: " .. task)
            else
                f:close()
                log("Task [" .. index .. "] is already shared.")
            end
        else
            log("Usage: //todo share <index>")
        end

    elseif cmd == 'setautostart' then
        local val = args[1]
        if val == 'true' then
            settings.visible_on_start = true
            config.save(settings)
            log("To-do list will now show on load.")
        elseif val == 'false' then
            settings.visible_on_start = false
            config.save(settings)
            log("To-do list will now be hidden on load.")
        else
            log("Usage: //todo setautostart true|false")
        end

    else
        -- Help text
        log("Commands:")
        log("//todo start - show list")
        log("//todo stop - hide list")
        log("//todo add <task>")
        log("//todo complete <index>")
        log("//todo remove <index>")
        log("//todo share <index> - share specific task")
        log("//todo fontsize <6-48> - set font size")
        log("//todo uncomplete <index>")
        log("//todo setautostart true|false")
    end
end)

-- Automatically start the list if enabled
if settings.visible_on_start then
    tasks = load_shared_tasks()
    for _, task in ipairs(load_personal_tasks()) do
        table.insert(tasks, task)
    end
    visible = true
    box:show()
    update_box()
end
