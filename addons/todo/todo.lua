--[[
  To-Do Addon for Windower 4
  Author: YourName
  Version: 1.7
  Description:
    A simple to-do list addon that allows players to manage personal and shared tasks.
    Personal tasks are stored in data/<character>/tasks.txt and shared tasks in data/shared_tasks.txt.
    Tasks can be added, removed, completed, and shared using simple commands.
    Supports saving window position and optional auto-display on login per character.
]]

_addon.name = 'todo'
_addon.version = '1.7'
_addon.author = 'YourName'
_addon.commands = {'todo'}

-- Required Windower libraries
require('logger')
config = require('config')
texts = require('texts')

-- Load and persist addon settings (like window position and visibility)
local defaults = {
    pos = {
        x = 100,
        y = 100
    },
    visible_on_start = false, -- New setting: show window automatically on load
}
local settings = config.load(defaults)

-- Determine player name for per-character storage
local player_name = windower.ffxi.get_player() and windower.ffxi.get_player().name or 'default'
local char_dir = windower.addon_path .. 'data/' .. player_name .. '/'
local char_file = char_dir .. 'tasks.txt'
local shared_path = windower.addon_path .. 'data/shared_tasks.txt'

-- UI element setup using Windower text library
local visible = false
local box_settings = {
    pos = { x = settings.pos.x, y = settings.pos.y },
    text = { font = 'Arial', size = 12, alpha = 255 },
    bg = { alpha = 150 },
    flags = { draggable = true },
}
local box = texts.new(box_settings, true)
box:hide()

-- Periodically check for position changes (texts objects do not support 'pos change' event)
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

-- Ensure the personal character directory exists
local function ensure_char_dir()
    -- Use platform-independent way if possible, fallback:
    local sep = package.config:sub(1,1)
    local mkdir_command = 'mkdir "' .. char_dir .. '"'
    if sep == '\\' then
        -- Windows
        mkdir_command = 'if not exist "' .. char_dir .. '" mkdir "' .. char_dir .. '"'
    end
    os.execute(mkdir_command)
end

-- Save personal tasks to the character's task file
local function save_personal_tasks()
    ensure_char_dir()
    local f = io.open(char_file, 'w')
    if not f then
        error("Could not write to " .. char_file)
    end
    for _, task in ipairs(tasks) do
        f:write(task .. "\n")
    end
    f:close()
end

-- Load personal tasks from the character's task file
local function load_personal_tasks()
    local f = io.open(char_file, 'r')
    if not f then
        return {}
    end
    local loaded = {}
    for line in f:lines() do
        if line and line:match("%S") then
            table.insert(loaded, line)
        end
    end
    f:close()
    return loaded
end

-- Save the current task list to the global shared file
local function save_shared_tasks()
    local f = io.open(shared_path, 'w')
    if not f then
        error("Could not write to shared_tasks.txt")
    end
    for _, task in ipairs(tasks) do
        f:write(task .. "\n")
    end
    f:close()
end

-- Load shared tasks from the global shared file and tag them
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

-- Update the display box with current tasks, using green color for shared tasks
local function update_box()
    if not visible then return end
    local output = "To-Do List:\n"
    for i, task in ipairs(tasks) do
        local is_shared = task:sub(1, 8) == "[shared]"
        if is_shared then
            local clean_task = task:sub(9)
            output = output .. string.format("[%d] \\cs(0,255,0)%s\\cr\n", i, clean_task)
        else
            output = output .. string.format("[%d] %s\n", i, task)
        end
    end
    box:text(output)
end

-- Handle addon commands entered by the user
windower.register_event('addon command', function(cmd, ...)
    local args = {...}
    cmd = cmd and cmd:lower() or nil

    if cmd == 'start' then
        tasks = load_personal_tasks()
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
            tasks[index] = tasks[index] .. " ✓"
            save_personal_tasks()
            update_box()
            log("Completed task: " .. tasks[index])
        else
            log("Usage: //todo complete <index>")
        end

    elseif cmd == 'share' then
        save_shared_tasks()
        log("Shared tasks saved to shared_tasks.txt")

    elseif cmd == 'loadshared' then
        tasks = load_shared_tasks()
        save_personal_tasks()
        update_box()
        log("Loaded shared tasks into local list.")

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
        -- Help menu for available commands
        log("Commands:")
        log("//todo start - show list")
        log("//todo stop - hide list")
        log("//todo add <task>")
        log("//todo complete <index>")
        log("//todo remove <index>")
        log("//todo share - save list to shared file")
        log("//todo loadshared - load shared file into current list")
        log("//todo setautostart true|false - toggle auto-display of task list on login")
    end
end)

-- Auto-show if configured on addon load
if settings.visible_on_start then
    tasks = load_personal_tasks()
    visible = true
    box:show()
    update_box()
end
