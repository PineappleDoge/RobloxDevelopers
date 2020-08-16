local Bot = {}
Bot.__index = Bot

function Bot:new(obj)
  return setmetatable(obj or {},self)
end    

function Bot:GiveSettings()
  local settings = {}
  settings["Token"] = require("../../protected/BotToken")()
  settings["Prefix"] = ":"
  return settings
end   

function Bot:Commands()
   local Commands = { 
     help = require("./Commands/help");
     meme = require("./Commands/Meme");
     say = require("./Commands/Say")
   }
   return Commands
end

function Bot:CheckMemberRole(member)
  for i,RoleId in pairs(self.StuffRoles) do 
    if member:hasRole(RoleId) then 
      return true
    else
      return false
    end   
  end  
end  

function Bot:OutPutSay(msg)
  return string.sub(msg.content,5,string.len(msg.content))
end    

function Bot:CommandOutput(debounce,message,command,msgauthor)
   if command == BotCommands.say then 
     local chan = message.channel
     message:delete()
     chan:send(self:OutPutSay(message))
   else 
     message.channel:send(command.output)
     self.timer.sleep(5000)
     message:delete()
  end 
end


return Bot