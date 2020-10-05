-------------------------------------------
-- Services/Modules 
local Discordia = require('discordia')
local DS_Client = Discordia.Client()
local LV_Timer = require('timer')

-- DS = Discordia Related
-- LV = Luvit Related
-------------------------------------------
-- Tables & Other Values
local CurrentLoggedClients = {}

-------------------------------------------
-- Functions
local function GetClientTable(newClientId) 
    if CurrentLoggedClients[newClientId] == nil then 
        CurrentLoggedClients[newClientId] = 0 
        return CurrentLoggedClients[newClientId]
    else 
        return CurrentLoggedClients[newClientId]
    end 
end

-------------------------------------------
-- Connections 
DS_Client:on('messageCreate', function(message) -- Manages updating user message count
    local user = message.author 

    if CurrentLoggedClients[user.Id] == nil then 
        -- Set up a new table, add +1 to their message count
        local ClientMessage = GetClientTable(user.Id)
        ClientMessage[user.Id] = ClientMessage[user.Id] + 1 
    else
        -- Just add +1 to their message count
        CurrentLoggedClients[user.Id].messageCount = CurrentLoggedClients[user.Id].messageCount + 1 
    end

    if CurrentLoggedClients[user.Id].messageCount >= 6 then 
        -- AFTER adding a message to their message count, then you add the muted role if 
        -- it's over 6 messages in 30 seconds
        user:addRole('484337500333277214')
    end
end)

DS_Client:on('ready', function()
    LV_Timer.setInterval(30000, function() 
        for i, member in ipairs (CurrentLoggedClients) do 
            if member.messageCount > 0 then 
                member.messageCount = 0 
            end
        end
    end)
end)