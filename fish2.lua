-- Basic Ashita v4 addon that echoes true when a specific catch message is seen.

addon.name = 'fish2'
addon.author = 'ChatGPT'
addon.version = '1.1.0'
addon.desc = 'Echoes true when Plinx catches an Elshimo frog.'

-- Strips basic color control codes often found at the start of FFXI chat lines.
local function normalize_message(msg)
    -- Removes \30x and \31x color codes (two-byte control sequences) to simplify comparisons.
    return (msg or ''):gsub(string.char(0x1E) .. '.', ''):gsub(string.char(0x1F) .. '.', '')
end

ashita.events.register('text_in', 'fish2_text_in', function(e)
    local normalized = normalize_message(e.message)

    if normalized:find('Plinx caught an Elshimo frog!', 1, true) then
        AshitaCore:GetChatManager():QueueCommand(1, '/echo true')
    end

    return false
end)
