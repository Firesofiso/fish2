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

-- Strips basic color control codes often found at the start of FFXI chat lines.
local function normalize_message(msg)
    -- Removes \30x and \31x color codes (two-byte control sequences) to simplify comparisons.
    return (msg or ''):gsub(string.char(0x1E) .. '.', ''):gsub(string.char(0x1F) .. '.', '')
end

ashita.events.register('text_in', 'fish2_text_in', function(e)
    local normalized = normalize_message(e.message)

    for phrase in pairs(trigger_map) do
        if normalized:find(phrase, 1, true) then
            AshitaCore:GetChatManager():QueueCommand(1, '/echo true')
            break
        end
    end

    return false
end)
