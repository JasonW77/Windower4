--[[
  To-Do Addon for Windower 4
  Author: Uncle Awesome
  Version: 1.9
  Description:
    A to-do list addon that displays personal and shared tasks in separate windows.
    Supports adding, removing, completing, uncompleting, and sharing tasks.
    Task lists persist between sessions and can be customized per character.
]]

_addon.name = 'todo'
_addon.version = '1.9'
_addon.author = 'Uncle Awesome'
_addon.commands = {'td'}

require('logger')
config = require('config')
texts = require('texts')

local defaults = {
    pos_personal = { x = 100, y = 100 },
    pos_shared = { x = 400, y = 100 },
    visible_on_start = false,
    font_size = 12,
    title_personal = "Personal Tasks",
    title_shared = "Shared Tasks",
}
local settings = config.load(defaults)

local last_personal = { x = settings.pos_personal.x, y = settings.pos_personal.y }
local last_shared   = { x = settings.pos_shared.x,   y = settings.pos_shared.y   }

local player_name = windower.ffxi.get_player() and windower.ffxi.get_player().name or 'default'
local char_dir = windower.addon_path .. 'data/' .. player_name .. '/'
local char_file = char_dir .. 'tasks.txt'
local shared_path = windower.addon_path .. 'data/shared_tasks.txt'

local visible = false
local personal_tasks = {}
local shared_tasks = {}

local box_personal = texts.new({
    pos = settings.pos_personal,
    text = { font = 'Arial', size = settings.font_size, alpha = 255 },
    bg = { alpha = 150 },
    flags = { draggable = true },
}, true)
local box_shared = texts.new({
    pos = settings.pos_shared,
    text = { font = 'Arial', size = settings.font_size, alpha = 255 },
    bg = { alpha = 150 },
    flags = { draggable = true },
}, true)
box_personal:hide()
box_shared:hide()

windower.register_event('prerender', function()
    if not visible then return end

    local px, py = box_personal:pos()
    if px ~= last_personal.x or py ~= last_personal.y then
        settings.pos_personal.x, settings.pos_personal.y = px, py
        last_personal.x,          last_personal.y        = px, py
        config.save(settings)
    end

    local sx, sy = box_shared:pos()
    if sx ~= last_shared.x or sy ~= last_shared.y then
        settings.pos_shared.x, settings.pos_shared.y = sx, sy
        last_shared.x,         last_shared.y         = sx, sy
        config.save(settings)
    end
end)

local function ensure_char_dir()
    local sep = package.config:sub(1,1)
    local mkdir_command = 'mkdir "' .. char_dir .. '"'
    if sep == '\\' then
        mkdir_command = 'if not exist "' .. char_dir .. '" mkdir "' .. char_dir .. '"'
    end
    os.execute(mkdir_command)
end

local function save_tasks(path, task_list)
    local f = io.open(path, 'w')
    if not f then error("Could not write to " .. path) end
    for _, task in ipairs(task_list) do
        f:write(task .. "\n")
    end
    f:close()
end

local function load_tasks(path)
    local f = io.open(path, 'r')
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

local function update_boxes()
    if not visible then return end

    local personal_output = settings.title_personal .. ":\n"
    for i, task in ipairs(personal_tasks) do
        local is_completed = task:sub(1, 4) == "[X] "
        local clean_task = is_completed and task:sub(5) or task
        local color = is_completed and "\\cs(70,130,180)[X] " or "\\cs(135,206,235)"
        personal_output = personal_output .. string.format("[%d] %s%s\\cr\n", i, color, clean_task)
    end
    box_personal:text(personal_output)

    local shared_output = settings.title_shared .. ":\n"
    for i, task in ipairs(shared_tasks) do
        local is_completed = task:sub(1, 4) == "[X] "
        local clean_task = is_completed and task:sub(5) or task
        local color = is_completed and "\\cs(70,130,180)[X] " or "\\cs(50,205,50)"
        shared_output = shared_output .. string.format("[%d] %s%s\\cr\n", i, color, clean_task)
    end
    box_shared:text(shared_output)
end

windower.register_event('addon command', function(cmd, ...)
    local args = {...}
    cmd = cmd and cmd:lower() or nil

    if cmd == 'start' then
        personal_tasks = load_tasks(char_file)
        shared_tasks = load_tasks(shared_path)
        visible = true
        box_personal:show()
        box_shared:show()
        update_boxes()

    elseif cmd == 'stop' then
        visible = false
        box_personal:hide()
        box_shared:hide()

    elseif cmd == 'add' or cmd == 'a' then
        local task = table.concat(args, ' ')
        if task ~= '' then
            table.insert(personal_tasks, task)
            ensure_char_dir()
            save_tasks(char_file, personal_tasks)
            update_boxes()
            log("Added task: " .. task)
        else
            log("Usage: //td add <task>")
        end

    elseif cmd == 'addshared' or cmd == 'as' then
        local task = table.concat(args, ' ')
        if task ~= '' then
            table.insert(shared_tasks, task)
            save_tasks(shared_path, shared_tasks)
            update_boxes()
            log("Added shared task: " .. task)
        else
            log("Usage: //td addshared <task>")
        end

    elseif cmd == 'remove' or cmd == 'r' then
        local index = tonumber(args[1])
        if index and personal_tasks[index] then
            table.remove(personal_tasks, index)
            save_tasks(char_file, personal_tasks)
            update_boxes()
        else
            log("Usage: //td remove <index>")
        end

    elseif cmd == 'removeshared' or cmd == 'rs' then
        local index = tonumber(args[1])
        if index and shared_tasks[index] then
            table.remove(shared_tasks, index)
            save_tasks(shared_path, shared_tasks)
            update_boxes()
        else
            log("Usage: //td removeshared <index>")
        end

    elseif cmd == 'complete' or cmd == 'c' then
        local index = tonumber(args[1])
        if index and personal_tasks[index] and not personal_tasks[index]:match("^%[X%] ") then
            personal_tasks[index] = "[X] " .. personal_tasks[index]
            save_tasks(char_file, personal_tasks)
            update_boxes()
            log("Completed task: " .. personal_tasks[index])
        else
            log("Usage: //td complete <index>")
        end

    elseif cmd == 'completeshared' or cmd == 'cs' then
        local index = tonumber(args[1])
        if index and shared_tasks[index] and not shared_tasks[index]:match("^%[X%] ") then
            shared_tasks[index] = "[X] " .. shared_tasks[index]
            save_tasks(shared_path, shared_tasks)
            update_boxes()
            log("Completed shared task: " .. shared_tasks[index])
        else
            log("Usage: //td completeshared <index>")
        end

    elseif cmd == 'uncomplete' or cmd == 'uc' then
        local index = tonumber(args[1])
        if index and personal_tasks[index] and personal_tasks[index]:match("^%[X%] ") then
            personal_tasks[index] = personal_tasks[index]:sub(5)
            save_tasks(char_file, personal_tasks)
            update_boxes()
            log("Uncompleted task: " .. personal_tasks[index])
        else
            log("Usage: //td uncomplete <index>")
        end

    elseif cmd == 'uncompleteshared' or cmd == 'ucs' then
        local index = tonumber(args[1])
        if index and shared_tasks[index] and shared_tasks[index]:match("^%[X%] ") then
            shared_tasks[index] = shared_tasks[index]:sub(5)
            save_tasks(shared_path, shared_tasks)
            update_boxes()
            log("Uncompleted shared task: " .. shared_tasks[index])
        else
            log("Usage: //td uncompleteshared <index>")
        end

    elseif cmd == 'fontsize' or cmd == 'fs' then
        local size = tonumber(args[1])
        if size and size >= 6 and size <= 48 then
            settings.font_size = size
            config.save(settings)
            box_personal:size(size)
            box_shared:size(size)
            update_boxes()
            log("Font size set to " .. size)
        else
            log("Usage: //td fontsize <6-48>")
        end

    elseif cmd == 'share' then
        local index = tonumber(args[1])
        if index and personal_tasks[index] then
            local task = personal_tasks[index]:gsub("^%[X%] ", "")
            table.insert(shared_tasks, task)
            save_tasks(shared_path, shared_tasks)
            update_boxes()
        else
            log("Usage: //td share <index>")
        end

    elseif cmd == 'setautostart' or cmd == 'sas' then
        local val = args[1]
        if val == 'true' then
            settings.visible_on_start = true
            config.save(settings)
            log("To-do windows will now show on login.")
        elseif val == 'false' then
            settings.visible_on_start = false
            config.save(settings)
            log("To-do windows will now be hidden on login.")
        else
            log("Usage: //td setautostart true|false")
        end

    elseif cmd == 'title' or cmd == 't' then
        local which = args[1]
        local title = table.concat(args, ' ', 2)
        if which == 'personal' or which == 'p' then
            settings.title_personal = title
            config.save(settings)
            update_boxes()
            log("Personal title set to: " .. title)
        elseif which == 'shared' or which == 's' then
            settings.title_shared = title
            config.save(settings)
            update_boxes()
            log("Shared title set to: " .. title)
        else
            log("Usage: //td title <personal|shared> \"New Title\"")
        end

    else
        log("Commands:")
        log("//td [start] - show list")
        log("//td [stop] - hide list")
        log("//td [add]|[a] <task> - add new task")
        log("//td [remove]|[r] <index> - remove task at index")
        log("//td [complete]|[c] <index> - mark task complete")
        log("//td [uncomplete]|[uc] <index> - mark task incomplete")
        log("//td [share] <index> - share task with all characters")
        log("//td [addshared]|[as] <task> - add shared task")
        log("//td [removeshared]|[rs] <index> - remove shared task at index")
        log("//td [completeshared]|[cs] <index> - mark shared task complete")
        log("//td [uncompleteshared]|[ucs] <index> - mark shared task incomplete")
        log("//td [fontsize]|[fs] <6-48> - change font size")
        log("//td [setautostart]|[sas] true|false - toggle window on login")
        log("//td [title]|[t] <personal|shared> \"New Title\" - rename window")
    end
end)

if settings.visible_on_start then
    personal_tasks = load_tasks(char_file)
    shared_tasks = load_tasks(shared_path)
    visible = true
    box_personal:show()
    box_shared:show()
    update_boxes()
end
