-- Basic Ashita v4 addon that echoes true when a specific catch message is seen.

addon.name = 'fish2'
addon.author = 'ChatGPT'
addon.version = '1.3.0'
addon.desc = 'Echoes true when configured fishing phrases are seen.'

local trigger_map = {
    ['Plinx caught an Elshimo frog!'] = true,
    ["You didn't catch anything."] = true,
    ['You give up.'] = true,
}

local ffi = require('ffi')

local debug_echo_enabled = false
local packet_echo_enabled = false
local last_message = {
    raw = nil,
    normalized = nil,
}
local last_outgoing_packet = {
    id = nil,
    size = nil,
    data = nil,
}
local VK_ESCAPE = 0x1B

-- Strips basic color control codes often found at the start of FFXI chat lines.
local function normalize_message(msg)
    -- Removes \30x and \31x color codes (two-byte control sequences) to simplify comparisons.
    return (msg or ''):gsub(string.char(0x1E) .. '.', ''):gsub(string.char(0x1F) .. '.', '')
end

-- Formats a packet payload into a space-delimited hex string for easy inspection.
local function bytes_to_hex(data_ptr, size)
    if data_ptr == nil or size == nil or size <= 0 then
        return nil
    end

    local raw = ffi.string(data_ptr, size)
    local out = {}
    for i = 1, #raw do
        out[#out + 1] = string.format('%02X', raw:byte(i))
    end

    return table.concat(out, ' ')
end

-- Tracks the most recent incoming message (raw and normalized) so it can be echoed on demand.
local function record_message(raw_message)
    last_message.raw = raw_message
    last_message.normalized = normalize_message(raw_message)
end

-- Tracks the most recent outgoing packet for debugging.
local function record_outgoing_packet(e)
    last_outgoing_packet.id = e.id
    last_outgoing_packet.size = e.size

    local data_ptr = e.data_modified or e.data
    local hex_data = bytes_to_hex(data_ptr, e.size)
    last_outgoing_packet.data = hex_data or '<no data>'
end

-- Queues a chat echo of the cached raw and normalized incoming message for debugging.
local function echo_cached_message()
    if not debug_echo_enabled or (last_message.raw == nil and last_message.normalized == nil) then
        return
    end

    local chat_manager = AshitaCore:GetChatManager()
    chat_manager:QueueCommand(1, string.format('/echo [fish2] raw: %s', last_message.raw or '<nil>'))
    chat_manager:QueueCommand(1, string.format('/echo [fish2] normalized: %s', last_message.normalized or '<nil>'))
end

-- Queues a chat echo of the cached outgoing packet for debugging.
local function echo_cached_packet()
    if not packet_echo_enabled or (last_outgoing_packet.id == nil and last_outgoing_packet.data == nil) then
        return
    end

    local chat_manager = AshitaCore:GetChatManager()
    chat_manager:QueueCommand(1,
        string.format('/echo [fish2] last out packet 0x%03X (%d bytes)',
            last_outgoing_packet.id or 0,
            last_outgoing_packet.size or 0))
    chat_manager:QueueCommand(1,
        string.format('/echo [fish2] data: %s', last_outgoing_packet.data or '<nil>'))
end

ashita.events.register('text_in', 'fish2_text_in', function(e)
    record_message(e.message)
    local normalized = last_message.normalized

    for phrase in pairs(trigger_map) do
        if normalized:find(phrase, 1, true) then
            AshitaCore:GetChatManager():QueueCommand(1, '/echo true')
            break
        end
    end

    return false
end)

ashita.events.register('packet_out', 'fish2_packet_out', function(e)
    record_outgoing_packet(e)

    if packet_echo_enabled then
        echo_cached_packet()
    end

    return false
end)

ashita.events.register('keyboard', 'fish2_keyboard', function(e)
    if e.down and e.key == VK_ESCAPE then
        echo_cached_message()
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
    elseif action == 'packets' then
        local state = args[3] and args[3]:lower() or ''
        if state == 'on' or state == 'true' then
            packet_echo_enabled = true
        elseif state == 'off' or state == 'false' then
            packet_echo_enabled = false
        else
            packet_echo_enabled = not packet_echo_enabled
        end

        AshitaCore:GetChatManager():QueueCommand(1,
            string.format('/echo [fish2] outgoing packet echo %s',
                packet_echo_enabled and 'enabled' or 'disabled'))
        e.blocked = true
        return true
    end

    return false
end)
