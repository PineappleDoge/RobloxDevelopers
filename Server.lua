--Packages 
local discordia = require('discordia')
local BotPackage = require('BotSettings')
local timer = require('timer')
--Packages

--objects
local client = discordia.Client()
local Bot = BotPackage:new()
--objects

local BotSettings = Bot:GiveSettings()
local BotCommands = Bot:Commands()
local debounce = true
local Users = {}

local StaffIds = { 
  "744289153197539339";
  "744289711060942921" ;
  "744289883320877139";
  "744289804736397373"
}

p(Bot)

BotSettings.StuffRoles = StaffIds
BotSettings.timer = timer

client:on('messageCreate', function(message)
  if string.lower(string.sub(message.content,1,5)) == BotSettings.Prefix..BotCommands.help.cmd then    
     BotSettings:CommandOutput(debounce,message,BotCommands.help)
  elseif string.lower(string.sub(message.content,1,5)) == BotSettings.Prefix..BotCommands.meme.cmd then  
     BotSettings:CommandOutput(debounce,message,BotCommands.meme)
  elseif string.lower(string.sub(message.content,1,4)) == BotSettings.Prefix..BotCommands.say.cmd and BotSettings:CheckMemberRole(message.member) == true then  
     BotSettings:CommandOutput(debounce,message,BotCommands.say)
  end
end)



client:run(BotSettings.Token) 