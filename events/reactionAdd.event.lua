local comrade = require 'Comrade'
local json = require 'json'

local toml = require 'toml'
local fs = require 'fs'

local config = toml.parse(fs.readFileSync('config.toml'), {strict = true})

local hiring = config.hiring

local channels = hiring.channels

local event, lua, template = comrade.Event, comrade.lua, comrade.Template

local function check(message, hash, client, userId)
  if client.user.id == userId then return end

  if message.author.id == client.user.id then
    if not message.embeds then return end

    local embed = message.embeds[1]

    if not embed.fields or not embed.fields[1] then return end

    local metadata = embed.fields[1]

    if not metadata.name == 'Metadata' then return end

    -- This is a valid hiring form --

    if message.content == 'Closed' then return end

    metadata = metadata.value:gsub('```[json]*', '')

    message:setContent 'Closed'

    local parsed = json.parse(metadata)
    local author = client:getUser(parsed.author)

    if hash == hiring.approved then
      author:send 'Your hiring request has been accepted!'

      local toSend = template {
        title = "Hiring request",
        description = [[
        Contact: {{contact}}


        Description: {{description}}

        Paying: {{paying}}

        Other: {{other}}
        ]]
      }

      toSend = toSend:render {
        contact = author.tag,
        paying = parsed.prices,
        description = parsed.description,
        other = parsed.other
      }

      for _,v in pairs(parsed.channels) do
        local id = channels[v]

        local channel = client:getChannel(id)

        toSend:send(channel)
      end
    elseif hash == hiring.ban then
      local member = message.guild:getMember(author.id)

      if not member then
        message:reply "Can't find user"
      else
        member:addRole(hiring.banRole)
        message:reply("Banned " .. member.nickname or member.username .. " from hiring!")
        author:send 'Your hiring request has been declined and you have been banned from hiring!'
      end
    elseif hash == hiring.unapprove then
      author:send 'Your hiring request has been declined.'
    else
      message:reply 'Invalid reaction'
    end
  end
end

-- TODO; Use better practices when unloading events is fixed
return {
  name = 'reactionAdd + reactionAddUncached',
  use = function(_, client)
    lua.class('reactionAddUncached', {
      execute = function(channel, messageId, hash, userId)
        check(channel:getMessage(messageId), hash, client, userId)
      end}, event, function(self)
      self:super(self,'new')
    end):use(client)

    lua.class('reactionAdd', {
      execute = function(reaction, userId)
        check(reaction.message, reaction.emojiHash, client, userId)
      end}, event, function(self)
      self:super(self,'new')
    end):use(client)
  end
}