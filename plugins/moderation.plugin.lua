local comrade = require 'Comrade'

local plugin, embed, lua, util = comrade.Plugin, comrade.Embed, comrade.lua, comrade.util

local enums = require 'discordia'.enums
local permission = enums.permission

--- @param msg string
--- @param args string[]
--- @param perm string
--- @return nil
local function remove(msg, args, perm)
  if not msg.member:hasPermission(permission[perm]) then
    return msg:reply("You do not have `" .. perm .. "` permission!")
  end

  if not msg.guild.me:hasPermission(permission[perm]) then
    return msg:reply("I do not have `" .. perm .. "` permission!")
  end

  if not msg.mentionedUsers.first then
    return msg:reply("You need to mention somebody!")
  end

  local member = msg.guild:getMember(msg.mentionedUsers.first.id)

  local action = (perm == 'kickMembers' and 'kick') or (perm == 'banMembers' and 'ban') or 'do something to'

  if not util.manageable(member) then
    return msg:reply("My role needs to be higher then the person you are trying to " .. action .. "!")
  end

  if not util.compareRoles(msg.member.highestRole, member.highestRole) then
    return msg:reply("Your role needs to be higher then the person you are trying to " .. action .. "!")
  end

  local reason = table.concat(args, ' ', 2)

  member[action](member, reason)

  return msg:reply(tostring(action == 'kick' and 'Kicked' or action == 'ban' and 'Banned') .. " " .. member.user.tag .. " successfully!")
end

return lua.class('moderation', {}, plugin, function(self)
  self:super(self, 'new')

  lua.class('kick', {
    execute = function(_,msg, args)
      remove(msg,args, 'kickMembers')
    end
  }, self.command, function(self)
    self:super(self,'new')

    self.usage = self.name .. " <user> [reason]"
    self.example = self.name .. " @4 times 1 is even less then 0#3870"
    self.description = "Kick a member out of the server"
  end)

  lua.class('ban', {
    execute = function(_,msg, args)
      remove(msg,args, 'banMembers')
    end
  }, self.command, function(self)
    self:super(self,'new')

    self.usage = self.name .. " <user> [reason]"
    self.example = self.name .. " @4 times 1 is even less then 0#3870"
    self.description = "Ban a member out of the server"
  end)
end)