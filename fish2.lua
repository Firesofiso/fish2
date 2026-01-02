-- Basic Ashita v4 addon that prints a greeting when loaded.

addon.name = 'fish2'
addon.author = 'ChatGPT'
addon.version = '1.0.0'
addon.desc = 'Outputs Hello World when the addon loads.'

ashita.events.register('load', 'fish2_load', function()
    -- Use /echo to ensure the message appears in the FFXI chat log.
    AshitaCore:GetChatManager():QueueCommand(1, '/echo Hello World')
end)
