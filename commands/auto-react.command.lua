-------------------------------------------
-- Services/Modules 
local Discordia = require('discordia')
local DS_Client = Discordia.Client()

-------------------------------------------
-- Other Values
local ModeratedChannels = {
    '565283005313056788'; 
    '701290428791521371';
}

-------------------------------------------
-- Connections & Functions
local function ModerateMessage(message)
    if message.embed then 
        message:AddReaction('⭐')
    end 
end

DS_Client:On('messageCreate', function(message)
    if message.channel.id == ModeratedChannels[message.channel.id] then 
        ModerateMessage(message)
    end 
end)