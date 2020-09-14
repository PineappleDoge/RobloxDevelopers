local comrade = require 'Comrade'

local plugin, embed, lua = comrade.Plugin, comrade.Embed, comrade.lua

local Date = require 'discordia'.Date

local function timeDiff(t2, t1)
  local d1, d2, carry, diff = os.date('*t', t1), os.date('*t', t2), false, { }
  local colMax = {60, 60, 24, os.date('*t', os.time({
      year = d1.year,
      month = d1.month + 1,
      day = 0
    })).day, 12
  }
  d2.hour = d2.hour - (d2.isdst and 1 or 0) + (d1.isdst and 1 or 0)
  for i, v in ipairs({'sec', 'min', 'hour', 'day', 'month', 'year' }) do
    diff[v] = d2[v] - d1[v] + (carry and -1 or 0)
    carry = diff[v] < 0
    if carry then
      diff[v] = diff[v] + colMax[i]
    end
  end
  return diff
end

return lua.class('information', {}, plugin, function(self)
  self:super(self, 'new')

  lua.class('whois', {
    execute = function(_,msg, args)
      local member = msg.guild:getMember(msg.mentionedUsers.first.id) or (tonumber(args[1]) and msg.guild:getMember(args[1])) or (args[1] and msg.guild.members:find(function(member)
        return member.name:lower():match(table.concat(args, ' '):lower())
      end)) or (not args[1] and msg.member)

      if not member then return msg:reply "We couldn't find them" end

      local roles = ""

      member.roles:forEach(function(role)
        roles = tostring(roles) .. ", <@&" .. tostring(role.id) .. ">"
      end)

      roles = tostring(string.sub(roles, 2, #roles))

      local whoisInfo = embed({
        author = {
          name = member.tag,
          ['icon_url'] = member.user.avatarURL
        },
        thumbnail = {
          url = member.user.avatarURL
        },
        description = "<@" .. member.user.id .. ">"
      })

      whoisInfo:addField('User ID', member.user.id)
      whoisInfo:addField('Account Created', tostring(member.user:getDate():toString('%d %b %y')) .. " (" .. tostring(os.date('%d day(s) %m month(s) %Y year(s)', os.time(timeDiff(os.time(), os.time(member.user:getDate():toTableUTC()))))) .. " ago)")
      whoisInfo:addField('Joined Server', tostring(Date.fromISO(member.joinedAt):toString('%d %b %y')) .. " (" .. tostring(os.date('%d day(s) %m month(s) %Y year(s)', os.time(timeDiff(os.time(), os.time(Date.fromISO(member.joinedAt):toTableUTC()))))) .. " ago)")
      whoisInfo:addField('Highest Role', "<@&" .. tostring(member.highestRole.id) .. ">")
      whoisInfo:addField('Roles', (roles == '' and 'None') or roles)
      return whoisInfo:send(msg.channel)
    end
  }, self.command, function(self)
    self:super(self,'new')

    self.usage = self.name .. " [user]"
    self.example = self.name .. " @4 times 1 is even less then 0#3870"
    self.description = "Get some information on somebody"
  end)
end)