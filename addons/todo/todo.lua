--[[
  To-Do Addon for Windower 4
  Author: Uncle Awesome
  Version: 1.9
  Description:
    A to-do list addon that displays personal and shared tasks in separate windows.
    Supports adding, removing, completing, uncompleting, and sharing tasks.
    Task lists persist between sessions and can be customized per character.
]]

_addon.name = "todo"
_addon.version = "1.9"
_addon.author = "Uncle Awesome"
_addon.commands = {"td"}

require("logger")
local config = require("config")
local texts = require("texts")
local windower = _G.windower

local function split(str, delim)
    local result = {}
    for match in (str .. delim):gmatch("(.-)" .. delim) do
        table.insert(result, match)
    end
    return result
end

local function parse_csv_line(line)
    local res = {}
    local field = ""
    local in_quotes = false
    local i = 1

    while i <= #line do
        local c = line:sub(i, i)

        if c == '"' then
            if in_quotes and line:sub(i + 1, i + 1) == '"' then
                field = field .. '"'
                i = i + 1
            else
                in_quotes = not in_quotes
            end
        elseif c == "," and not in_quotes then
            table.insert(res, field)
            field = ""
        else
            field = field .. c
        end

        i = i + 1
    end

    table.insert(res, field)
    return res
end

local function trim(str)
    return (str and str:match("^%s*(.-)%s*$")) or ""
end

local defaults = {
    pos_personal = { x = 100, y = 100 },
    pos_shared = { x = 400, y = 100 },
    pos_roe = { x = 700, y = 100 },
    visible_on_start = false,
    title_roe = "RoE Checklist",
    font_size_personal = 12,
    font_size_shared = 12,
    font_size_roe = 12,
    title_personal = "Personal Tasks",
    title_shared = "Shared Tasks",
}
local settings = config.load(defaults)

local roe_data = {}

local function get_roe_name(id)
    if roe_data[id] and roe_data[id].name then
        return roe_data[id].name
    end
    return "ID: " .. tostring(id)
end

local function load_roe_data()
    local path = windower.addon_path .. 'data/RoE.csv'
    local f = io.open(path, "r")
    if not f then
        windower.add_to_chat(207, "[TODO] Error: Could not open RoE data file at " .. path)
        return
    end

    -- Read and skip header line
    f:read("*l")

    for line in f:lines() do
        local parts = parse_csv_line(line)
        if #parts >= 2 then
            local id = tonumber(parts[1])
            if id then
                local parsed_flags = {}
                local raw_flags = parts[8] or ""
                if raw_flags ~= "" then
                    for _, flag in ipairs(split(raw_flags, "|")) do
                        local normalized_flag = trim(flag):lower()
                        if normalized_flag ~= "" then
                            table.insert(parsed_flags, normalized_flag)
                        end
                    end
                end

                roe_data[id] = {
                    name = parts[2],
                    trigger = parts[3],
                    quest_log = parts[4],
                    quest_id = parts[5],
                    sparks = tonumber(parts[6]),
                    xp = tonumber(parts[7]),
                    flags = parsed_flags
                }
            end
        end
    end
    f:close()
    windower.add_to_chat(207, "[TODO] Loaded RoE entries: " .. tostring(table.length(roe_data)))
end

local last_personal = { x = settings.pos_personal.x, y = settings.pos_personal.y }
local last_shared   = { x = settings.pos_shared.x,   y = settings.pos_shared.y   }
local last_roe      = { x = settings.pos_roe.x,      y = settings.pos_roe.y      }

local player_name = windower.ffxi.get_player() and windower.ffxi.get_player().name or "default"
local char_dir = windower.addon_path .. "data/" .. player_name .. "/"
local char_file = char_dir .. "tasks.txt"
local shared_path = windower.addon_path .. "data/shared_tasks.txt"

local visible = false
local packets = require("packets") -- Added for packet handling related to RoE

local personal_tasks = {}
local shared_tasks = {}
local _roe_active = {}
local _roe_complete = {}

local box_personal = texts.new({
    pos = settings.pos_personal,
    text = { font = "Arial", size = settings.font_size_personal, alpha = 255 },
    bg = { alpha = 150 },
    flags = { draggable = true },
}, true)
local box_shared = texts.new({
    pos = settings.pos_shared,
    text = { font = "Arial", size = settings.font_size_shared, alpha = 255 },
    bg = { alpha = 150 },
    flags = { draggable = true },
}, true)
local box_roe = texts.new({
    pos = settings.pos_roe,
    text = { font = "Arial", size = settings.font_size_roe, alpha = 255, color = 0xFF0000 }, -- Red text
    bg = { alpha = 150 },
    flags = { draggable = true },
}, true)
box_personal:hide()
box_shared:hide()
box_roe:hide()

windower.register_event("prerender", function()
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

    local rx, ry = box_roe:pos()
    if rx ~= last_roe.x or ry ~= last_roe.y then
        settings.pos_roe.x, settings.pos_roe.y = rx, ry
        last_roe.x,         last_roe.y         = rx, ry
        config.save(settings)
    end
end)

local function ensure_char_dir()
    local sep = package.config:sub(1,1)
    local mkdir_command = "mkdir \"" .. char_dir .. "\""
    if sep == "\\" then
        mkdir_command = "if not exist \"" .. char_dir .. "\" mkdir \"" .. char_dir .. "\""
    end
    os.execute(mkdir_command)
end

local function save_tasks(path, task_list)
    local f = io.open(path, "w")
    if not f then error("Could not write to " .. path) end
    for _, task in ipairs(task_list) do
        f:write(task .. "\n")
    end
    f:close()

end

local function load_tasks(path)
    local f = io.open(path, "r")
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

    local function has_flag(roe_id, flag)
        if roe_data[roe_id] and roe_data[roe_id].flags then
            for _, f in ipairs(roe_data[roe_id].flags) do
                if f == flag then
                    return true
                end
            end
        end
        return false
    end

    local function sort_roe_objectives(objectives_table)
        local sorted_objectives = {}
        for id, progress in pairs(objectives_table) do
            table.insert(sorted_objectives, {id = id, progress = progress, name = get_roe_name(id)})
        end

        table.sort(sorted_objectives, function(a, b)
            return a.name < b.name
        end)
        return sorted_objectives
    end

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

    local roe_output = settings.title_roe .. ":\n"

    local active_repeat = {}
    local active_unity = {}
    local active_daily = {}
    local active_timed = {}
    local active_retro = {}
    local active_other = {}

    for id, progress in pairs(_roe_active) do
        if has_flag(id, "repeat") then
            active_repeat[id] = progress
        elseif has_flag(id, "unity") then
            active_unity[id] = progress
        elseif has_flag(id, "daily") then
            active_daily[id] = progress
        elseif has_flag(id, "timed") then
            active_timed[id] = progress
        elseif has_flag(id, "retro") then
            active_retro[id] = progress
        else
            active_other[id] = progress
        end
    end

    local function append_section(title, objectives_table, color)
        local section_output = ""
        if next(objectives_table) then
            section_output = section_output .. string.format("\n\\cs%s--- %s ---\\cr\n", color, title)
            local sorted_objectives = sort_roe_objectives(objectives_table)
            for _, obj in ipairs(sorted_objectives) do
                section_output = section_output .. string.format("  -> \\cs(255,255,255)%s - Progress: %s\\cr\n", obj.name, tostring(obj.progress))
            end
        end
        return section_output
    end

    roe_output = roe_output .. append_section("Active Repeatable Objectives", active_repeat, "(173,216,230)") -- Light Blue
    roe_output = roe_output .. append_section("Active Unity Objectives", active_unity, "(144,238,144)") -- Light Green
    roe_output = roe_output .. append_section("Active Daily Objectives", active_daily, "(255,255,0)") -- Yellow
    roe_output = roe_output .. append_section("Active Timed Objectives", active_timed, "(255,192,203)") -- Pink
    roe_output = roe_output .. append_section("Active Retroactive Objectives", active_retro, "(255,99,71)") -- Tomato
    roe_output = roe_output .. append_section("Active Other Objectives", active_other, "(255,165,0)") -- Orange

    if not next(_roe_active) then
        roe_output = roe_output .. "\n\\cs(255,255,255)No active RoE objectives.\\cr\n"
    end

    local complete_repeatable = {}
    local complete_unity = {}
    local complete_daily = {}
    local complete_timed = {}
    local complete_retro = {}
    local complete_other = {}

    for id, _ in pairs(_roe_complete) do
        if has_flag(id, "repeat") then
            complete_repeatable[id] = true
        elseif has_flag(id, "unity") then
            complete_unity[id] = true
        elseif has_flag(id, "daily") then
            complete_daily[id] = true
        elseif has_flag(id, "timed") then
            complete_timed[id] = true
        elseif has_flag(id, "retro") then
            complete_retro[id] = true
        else
            complete_other[id] = true
        end
    end

    local function append_complete_section(title, objectives_table, color)
        local section_output = ""
        if next(objectives_table) then
            section_output = section_output .. string.format("\n\\cs%s--- %s ---\\cr\n", color, title)
            local sorted_objectives = sort_roe_objectives(objectives_table)
            for _, obj in ipairs(sorted_objectives) do
                section_output = section_output .. string.format("  ✓ \\cs(255,255,255)%s\\cr\n", obj.name)
            end
        end
        return section_output
    end

    roe_output = roe_output .. append_complete_section("Completed Repeatable Objectives", complete_repeatable, "(173,216,230)")
    roe_output = roe_output .. append_complete_section("Completed Unity Objectives", complete_unity, "(144,238,144)")
    roe_output = roe_output .. append_complete_section("Completed Daily Objectives", complete_daily, "(255,255,0)")
    roe_output = roe_output .. append_complete_section("Completed Timed Objectives", complete_timed, "(255,192,203)")
    roe_output = roe_output .. append_complete_section("Completed Retroactive Objectives", complete_retro, "(255,99,71)")
    roe_output = roe_output .. append_complete_section("Completed Other Objectives", complete_other, "(255,165,0)")

    if not next(_roe_complete) then
        roe_output = roe_output .. "\n\\cs(255,255,255)No completed RoE objectives.\\cr\n"
    end
    box_roe:text(roe_output)
end

windower.register_event("addon command", function(cmd, ...)
    local args = {...}
    cmd = cmd and cmd:lower() or nil

    if cmd == "start" then
        personal_tasks = load_tasks(char_file)
        shared_tasks = load_tasks(shared_path)
        visible = true
        box_personal:show()
        box_shared:show()
        box_roe:show()
        update_boxes()

    elseif cmd == "stop" then
        visible = false
        box_personal:hide()
        box_shared:hide()
        box_roe:hide()

    elseif cmd == "add" or cmd == "a" then
        local task = table.concat(args, " ")
        if task ~= "" then
            table.insert(personal_tasks, task)
            ensure_char_dir()
            save_tasks(char_file, personal_tasks)
            update_boxes()
            log("Added task: " .. task)
        else
            log("Usage: //td add <task>")
        end

    elseif cmd == "addshared" or cmd == "as" then
        local task = table.concat(args, " ")
        if task ~= "" then
            table.insert(shared_tasks, task)
            save_tasks(shared_path, shared_tasks)
            update_boxes()
            log("Added shared task: " .. task)
        else
            log("Usage: //td addshared <task>")
        end

    elseif cmd == "remove" or cmd == "r" then
        local index = tonumber(args[1])
        if index and personal_tasks[index] then
            table.remove(personal_tasks, index)
            save_tasks(char_file, personal_tasks)
            update_boxes()
            log("Removed task: " .. personal_tasks[index])
        else
            log("Usage: //td remove <index>")
        end

    elseif cmd == "removeshared" or cmd == "rs" then
        local index = tonumber(args[1])
        if index and shared_tasks[index] then
            table.remove(shared_tasks, index)
            save_tasks(shared_path, shared_tasks)
            update_boxes()
            log("Removed shared task: " .. shared_tasks[index])
        else
            log("Usage: //td removeshared <index>")
        end

    elseif cmd == "complete" or cmd == "c" then
        local index = tonumber(args[1])
        if index and personal_tasks[index] and not personal_tasks[index]:match("^%[X%] ") then
            personal_tasks[index] = "[X] " .. personal_tasks[index]
            save_tasks(char_file, personal_tasks)
            update_boxes()
            log("Completed task: " .. personal_tasks[index])
        else
            log("Usage: //td complete <index>")
        end

    elseif cmd == "completeshared" or cmd == "cs" then
        local index = tonumber(args[1])
        if index and shared_tasks[index] and not shared_tasks[index]:match("^%[X%] ") then
            shared_tasks[index] = "[X] " .. shared_tasks[index]
            save_tasks(shared_path, shared_tasks)
            update_boxes()
            log("Completed shared task: " .. shared_tasks[index])
        else
            log("Usage: //td completeshared <index>")
        end

    elseif cmd == "uncomplete" or cmd == "uc" then
        local index = tonumber(args[1])
        if index and personal_tasks[index] and personal_tasks[index]:match("^%[X%] ") then
            personal_tasks[index] = personal_tasks[index]:sub(5)
            save_tasks(char_file, personal_tasks)
            update_boxes()
            log("Uncompleted task: " .. personal_tasks[index])
        else
            log("Usage: //td uncomplete <index>")
        end

    elseif cmd == "uncompleteshared" or cmd == "ucs" then
        local index = tonumber(args[1])
        if index and shared_tasks[index] and shared_tasks[index]:match("^%[X%] ") then
            shared_tasks[index] = shared_tasks[index]:sub(5)
            save_tasks(shared_path, shared_tasks)
            update_boxes()
            log("Uncompleted shared task: " .. shared_tasks[index])
        else
            log("Usage: //td uncompleteshared <index>")
        end

    elseif cmd == "fontsize" or cmd == "fs" then
        local target_window = args[1]
        local size_str = args[2]

        if not target_window then -- No arguments, display current settings
            log(string.format("Current Font Sizes: Personal: %d, Shared: %d, RoE: %d",
                settings.font_size_personal, settings.font_size_shared, settings.font_size_roe))
            return
        end

        local size = tonumber(target_window) -- Check if the first argument is a size for global change
        if size and #args == 1 then
            if size >= 6 and size <= 15 then
                settings.font_size_personal = size
                settings.font_size_shared = size
                settings.font_size_roe = size
                config.save(settings)
                box_personal:size(size)
                box_shared:size(size)
                box_roe:size(size)
                update_boxes()
                log("Font size for all windows set to " .. size)
            else
                log("Usage: //td fontsize <6-15> or //td fontsize <personal|shared|roe> <6-15>")
            end
            return
        end

        -- Handle window-specific font size
        size = tonumber(size_str)
        if size and size >= 6 and size <= 15 then
            if target_window == "personal" or target_window == "p" then
                settings.font_size_personal = size
                box_personal:size(size)
                log("Personal font size set to " .. size)
            elseif target_window == "shared" or target_window == "s" then
                settings.font_size_shared = size
                box_shared:size(size)
                log("Shared font size set to " .. size)
            elseif target_window == "roe" or target_window == "r" then
                settings.font_size_roe = size
                box_roe:size(size)
                log("RoE font size set to " .. size)
            else
                log("Usage: //td fontsize <personal|shared|roe> <6-15>")
            end
            config.save(settings)
            update_boxes()
        else
            log("Usage: //td fontsize <6-15> or //td fontsize <personal|shared|roe> <6-15>")
        end

    elseif cmd == "share" then
        local index = tonumber(args[1])
        if index and personal_tasks[index] then
            local task = personal_tasks[index]:gsub("^%[X%] ", "")
            table.insert(shared_tasks, task)
            save_tasks(shared_path, shared_tasks)
            update_boxes()
        else
            log("Usage: //td share <index>")
        end

    elseif cmd == "setautostart" or cmd == "sas" then
        local val = args[1]
        if val == "true" then
            settings.visible_on_start = true
            config.save(settings)
            log("To-do windows will now show on login.")
        elseif val == "false" then
            settings.visible_on_start = false
            config.save(settings)
            log("To-do windows will now be hidden on login.")
        else
            log("Usage: //td setautostart true|false")
        end

    elseif cmd == "title" or cmd == "t" then
        local which = args[1]
        local title = table.concat(args, " ", 2)
        if which == "personal" or which == "p" then
            settings.title_personal = title
            config.save(settings)
            update_boxes()
            log("Personal title set to: " .. title)
        elseif which == "shared" or which == "s" then
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
        log("//td [fontsize]|[fs] - display current font sizes")
        log("//td [fontsize]|[fs] <6-15> - change font size for all windows")
        log("//td [fontsize]|[fs] <personal|shared|roe> <6-15> - change font size for a specific window")
        log("//td [setautostart]|[sas] true|false - toggle window on login")
        log("//td [title]|[t] <personal|shared> \"New Title\" - rename window")
    end
end)

-- Max count for RoE objectives, consistent with the roe addon
local roe_max_count = 30

local function inc_chunk_handler(id, data)
    if id == 0x111 then
        _roe_active = {}
        for i = 1, roe_max_count do
            local offset = 5 + ((i - 1) * 4)
            local roe_id, progress = data:unpack("b12b20", offset)
            if roe_id > 0 then
                _roe_active[roe_id] = progress
            end
        end
        update_boxes()
    elseif id == 0x112 then
        -- Clear existing complete data before updating
        _roe_complete = {}
        local complete_bytes = {}
        -- Unpack 1024 bytes starting from offset 4
        for i = 0, 1023 do
            complete_bytes[i] = data:unpack("b1", 4 + i)
        end

        local current_page = data:unpack("H", 133) -- This seems to be an offset/page number

        for k, v in ipairs(complete_bytes) do
            if v == 1 then
                -- Adjusting key based on roe addon\\\'s logic: (k-1) for 0-indexed + 1024 * current_page
                local roe_id = (k - 1) + (1024 * current_page)
                _roe_complete[roe_id] = true
            end
        end
        update_boxes()
    end
end

local function load_handler()
    if not next(roe_data) then
        load_roe_data()
    end
    local last_roe_active_packet = windower.packets.last_incoming(0x111)
    if last_roe_active_packet then
        inc_chunk_handler(0x111, last_roe_active_packet)
    end
end

windower.register_event("incoming chunk", inc_chunk_handler)
windower.register_event("load", load_handler)

if settings.visible_on_start then
    personal_tasks = load_tasks(char_file)
    shared_tasks = load_tasks(shared_path)
    visible = true
    box_personal:show()
    box_shared:show()
    box_roe:show()
    update_boxes()
end