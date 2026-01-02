-- Basic Ashita v4 addon that echoes true when a specific catch message is seen.

addon.name = 'fish2'
addon.author = 'ChatGPT'
addon.version = '1.2.1'
addon.desc = 'Echoes true when configured fishing phrases are seen.'

local trigger_map = {
    ['Plinx caught an Elshimo frog!'] = true,
    ["You didn't catch anything."] = true,
    ['You give up.'] = true,
}

local debug_echo_enabled = false

-- Strips basic color control codes often found at the start of FFXI chat lines.
local function normalize_message(msg)
    -- Removes \30x and \31x color codes (two-byte control sequences) to simplify comparisons.
    return (msg or ''):gsub(string.char(0x1E) .. '.', ''):gsub(string.char(0x1F) .. '.', '')
end

-- Queues a chat echo of the raw and normalized incoming message for debugging.
local function echo_input_message(raw_message)
    if not debug_echo_enabled then
        return
    end

    local normalized = normalize_message(raw_message)
    local chat_manager = AshitaCore:GetChatManager()

    chat_manager:QueueCommand(1, string.format('/echo [fish2] raw: %s', raw_message or '<nil>'))
    chat_manager:QueueCommand(1, string.format('/echo [fish2] normalized: %s', normalized))
end

ashita.events.register('text_in', 'fish2_text_in', function(e)
    local normalized = normalize_message(e.message)

    echo_input_message(e.message)

    for phrase in pairs(trigger_map) do
        if normalized:find(phrase, 1, true) then
            AshitaCore:GetChatManager():QueueCommand(1, '/echo true')
            break
        end
    end

    return false
end)

ashita.events.register('command', 'fish2_command', function(e)
    local args = {}
    for arg in string.gmatch(e.command or '', '%S+') do
        table.insert(args, arg)
    end

    if args[1] == nil or args[1]:lower() ~= '/fish2' then
        return false
    end

    local action = args[2] and args[2]:lower() or ''
    if action == 'debug' then
        local state = args[3] and args[3]:lower() or ''
        if state == 'on' or state == 'true' then
            debug_echo_enabled = true
        elseif state == 'off' or state == 'false' then
            debug_echo_enabled = false
        else
            debug_echo_enabled = not debug_echo_enabled
        end

        AshitaCore:GetChatManager():QueueCommand(1,
            string.format('/echo [fish2] debug echo %s', debug_echo_enabled and 'enabled' or 'disabled'))
        e.blocked = true
        return true
    end

    return false
end)
