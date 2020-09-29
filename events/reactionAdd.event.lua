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
      author:send 'Your marketplace request has been accepted!'

      local toSend = template({
        title = "<%- get('_action') == 'lfw' and 'Portfolio' or 'Marketplace request' %>",
        description = [[
        <% 
          local contacts = get('contacts') or {}
  
          local msg = ''
  
          for i,v in pairs(contacts) do
            msg = msg .. i .. ': ' .. v .. '\n'
          end
  
          msg = msg:sub(0, #msg - 1) -- Remove trailing newline
        %>
        <% if get('_action') == 'sell' then %>
          Item for sell: <%- get('item') %>
          Item description: <%- get('description') %>
          Price: <%- get('prices') %>
          Other: <%- get('other') %>
        <% elseif get('_action') == 'hire' then %>
          Skills looking for:  <%- table.concat(get('channels'), ', ') %>
          Job description: <%- get('description') %>
          Payment: <%- get('prices') %>
          Other: <%- get('prices') %>
        <% elseif get('_action') == 'lfw' then %>
          Title: <%- get('title') %>
          Description: <%- get('description') %>
          Examples of work: <%- get('work') %>
          More examples of work: <%- get('work_location') %>
        <% end %>
        Contact details:
        <%- msg %>
        ]]
      }, true)

      toSend = toSend:render {
        get = function(item)
          return parsed[item]
        end
      }
      if parsed._action == 'hire' then
        for _,v in pairs(parsed.channels) do
          local id = channels[v]

          local channel = client:getChannel(id)

          toSend:send(channel)
        end
      elseif parsed._action == 'sell' then
        local channel = client:getChannel(channels.selling)

        toSend:send(channel)
      elseif parsed._action == 'lfw' then
        local channel = client:getChannel(channels.portfolio)

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