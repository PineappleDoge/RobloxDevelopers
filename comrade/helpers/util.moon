import permission from require('discordia').enums
enums = permission
util = {}

roles = {
  administrator: {
    'administrator'
  },
  moderator: {
    'kickMembers',
    'banMembers',
    'manageMessages',
    'manageNicknames',
    'mentionEveryone'
  },
  ['bot manager']: {
    'manageGuild',
    'manageRoles'
  }
}

-- Time

s = 1000
m = s * 60
h = m * 60
d = h * 24
w = d * 7
y = d * 365.25

util.years = (time) ->
  time * y
util.weeks = (time) ->
  time * w
util.days = (time) ->
  time * d
util.hours = (time) ->
  time * h
util.minutes = (time) ->
  time * m
util.seconds = (time) ->
  time * s

util.formatLong = (ms) ->
  msAbs = math.abs ms

  if msAbs >= d
    return util.plural ms, msAbs, d, 'day'
  if msAbs >= h
    return util.plural ms, msAbs, h, 'hour'
  if msAbs >= m
    return util.plural ms, msAbs, m, 'minute'
  if msAbs >= s
    return util.plural ms, msAbs, s, 'second'
  
  return "#{ms} ms"

util.plural = (ms,msAbs, n, name) ->
  isPlural = (msAbs >= n * 1.5)

  return "#{math.floor (ms / n) + 0.5} #{name}#{(isPlural and 's') or ''}"

util.bulkDelete = (msg,messages) ->
  if (type(messages) == 'table') then
    messageIDs = {}

    for _,m in pairs messages
      table.insert(messageIDs, m.id or m)

    if #messageIDs == 0 
      return {}
    if #messageIDs == 1
      msg.channel\getMessage(messageIDs[1])\delete()
      return {messageIDs[1]}

    msg.channel\bulkDelete(messageIDs)

    messageIDs
  elseif type(messages) == 'number'
    msg.channel\bulkDelete msg.channel\getMessages(messages)

util.compareRoles = (role1,role2) ->
  if role1.position == role2.position 
    return role2.id - role1.id
  role1.position - role2.position

util.manageable = (member) ->
  if member.user.id == member.guild.ownerId
    return false
  if member.user.id == member.client.user.id
    return false
  if member.client.user.id == member.guild.ownerId
    return true
  util.compareRoles(member.guild.me.highestRole, member.highestRole) > 0

util.checkPerm = (member,channel,permissions) ->
  unless type(permissions) == 'table'
    permissions = {permissions}
  if #permissions == 0
    return true
  
  hasRole = (member,role) ->
    has = nil
    member.roles\forEach (role) ->
      if role.name\lower! == role\lower!
        has = true
    has

  -- If no member then they can't have perms
  
  return false unless member

  perms = member\getPermissions channel

  permCodes = {}

  for _,perm in pairs permissions
    table.insert permCodes, enums[perm]

  if perms\has unpack permCodes
    return true
  else
    if hasRole member, 'administrator'
      return true
    else
      needed = {}

      for roleName, perms in pairs roles
        for _, perm in pairs perms
          if table.search perm, permissions
            table.insert needed, roleName
      
      has = true
      
      if #needed > 0
        for _,role in pairs needed
          unless hasRole member, role
            has = false
        
        return has
      else
        return false

util