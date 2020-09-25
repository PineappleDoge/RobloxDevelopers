local comrade = require 'Comrade'
local toml = require 'toml'
local json = require 'json'
local fs = require 'fs'

local config = toml.parse(fs.readFileSync('config.toml'), {strict = true})

local command, prompt, template, embed, util = comrade.LuaCommand, comrade.prompt, comrade.Template, comrade.Embed, comrade.util

local comm = command 'post'

local plate = template {
  title = "Roblox Developers Marketplace Prompt",
  description = "{{description}}",
  footer = {
    text = "Say cancel to cancel"
  }
}

local function exit(_, msg, prompt)
  prompt:reply 'Canceled!'
  msg:reply 'Canceled!'
  prompt:close()
end

local hiring = config.hiring

comm.cooldown = util.hours(6)

function comm:execute(msg, _, client)
  self.cooldowns[msg.author.id] = nil

  local member = msg.member

  if member.roles:find(function(role) return table.search(hiring.notAllowed, role.id) end) then
    return msg:reply 'You are restricted from this channel'
  elseif not member.roles:find(function(role) return table.search(hiring.allowed, role.id) end) then
    local roles = ""

    member.roles:forEach(function(role)
      roles = tostring(roles) .. ", `" .. tostring(role.name) .. "`"
    end)

    return msg:reply('You do not have Copper+, you have ' .. tostring(roles))
  end

  msg:reply 'Check your dms'

  prompt({
    channel = msg.author:getPrivateChannel(),
    author = msg.author
  }, client, {
    embed = true,
    timeout = util.minutes(2),
    tasks = {
      {
        message = plate:render {description = [[
        Hello! You've successfully opted into the opting process. Please follow the prompt and answer appropriately and I'll post your hiring prompt to a secret moderation channel where『 M 』Moderators will review and either accept/decline your prompt. What are you looking to create a prompt for?

        `Hiring` - Post a hiring request in the channels excluding <#690008026513801225> and <#690008198718947341>
        `Selling` - Post a selling request in <#690008026513801225>
        `Looking For Work` - Post your portfolio in <#690008198718947341>
        ]]},
        action = function(content, prompt, recieved)
          content = content:lower()
          if content == 'cancel' then return exit(self, msg, prompt) end

          prompt:save('_message', recieved)

          if content == 'looking for work' then
            prompt:save('_action', 'lfw')
            prompt:next()
          elseif content == 'selling' then
            prompt:save('_action', 'sell')
            prompt:next()
          elseif content == 'hiring' then
            prompt:save('_action', 'hire')
            prompt:next()
          else
            prompt:redo()
          end

        end
      }, {
        message = plate:construct({ description = [[
        <% if get('_action') == 'hire' then %>
          Hello! You've successfully opted into the hiring process. To start, what channel(s) would you like to post your hiring ad in? After you have selected at least 1 channel you want to post in, press Y to continue the prompt. To remove a channel from the currently selected channels table, type "remove channel-name"
        
          Current Selected Channel(s): <%- table.concat((get('channels') or {'None'}), ', ') %>

          Say `next` to continue

          `builder`, `modeler`, `scripter`, `animator`, `clothing`, `vfx`, `graphics`, `other`
        <% elseif get('_action') == 'sell' then %>
          What would you like to sell
        <% elseif get('_action') == 'lfw' then %>
          What skills do you have
        <% end %>
        ]]}, true),
        action = function(content, prompt)
          content = content:lower()
          if content == 'cancel' then return exit(self, msg, prompt) end

          local valid = {'builder', 'modeler', 'scripter', 'animator', 'clothing', 'vfx', 'graphics', 'other'}
          local current = prompt:get('channels') or {}

          if content:sub(0,7) == 'remove ' then
            local toRemove = content:sub(8, #content)

            if not table.search(valid, toRemove) then
              prompt:reply "That channel does not exist."
            elseif table.search(current, toRemove) then
              local _, pos = table.search(current, toRemove)

              table.remove(current, pos)
              prompt:save('channels', current)

              prompt:reply("Removed " .. toRemove .. " from your channels.")
              prompt:redo()
            else
              prompt:reply "That channel isn't in your Current Select Channel(s) table. Remember, proper typing of the channel name is needed."
              prompt:redo()
            end
          elseif content == 'next' then
            if #current == 0 then
              prompt:reply 'Please specify 1 channel.'
              prompt:redo()
            else
              prompt:next()
            end
          elseif table.search(valid, content) and not table.search(current, content) then
            table.insert(current, content)
            prompt:save('channels', current)
            prompt:redo()
          elseif table.search(current, content) then
            prompt:reply 'That channel is already in your list!'
            prompt:redo()
          else
            prompt:reply "Sorry, but that's not a channel we support hiring request in. Please take a look above at what channels we support."
            prompt:redo()
          end
        end
      }, {
        message = plate:construct({description = [[
        <% if get('_action') == 'sell' then %>
          How much would you like to sell for
        <% elseif get('_action') == 'hire' then %>
          Great! Please type a description of the job you're looking for people to do. Be informative as possible, listing the workplace, stylistic visions, people on the team, ETC.
        <% elseif get('_action') == 'lfw' then %>
          What are your prices
        <% end %>
        ]]}, true),
        action = function(content, prompt)
          if content == 'cancel' then return exit(self, msg, prompt) end

          prompt:save('description', content)

          prompt:next()
        end
      }, {
        message = plate:construct({ description = [[
        <% if get('_action') == 'sell' then %>
          Can you put images of what your selling
        <% elseif get('_action') == 'hire' then %>
          Great! Please list payment. If payment is negotiable, please list a price range in which you are willing to pay and **can** pay. If payment is percentage based (%), please state that.
        <% elseif get('_action') == 'lfw' then %>
          Post examples of your work
        <% end %>
        ]]}, true),
        action = function(content, prompt)
          if content == 'cancel' then return exit(self, msg, prompt) end

          prompt:save('prices', content)

          prompt:next()
        end
      }, {
        message = plate:construct({ description = [[
          Anything else? For example current studio work?
        ]], true}),
        action = function(content, prompt)
          if content == 'cancel' then return exit(self, msg, prompt) end

          prompt:save('other', content)

          prompt:next()
        end
      },  {
        message = 'check',
        action = 'check'
      },
      {
        message = 'now',
        action = function(_, prompt)
          local message = prompt:get '_message'
          local author = message.author

          local desc = ''
          local metadata = {}

          for i,v in pairs(prompt.data) do
            if i:sub(0, 1) ~= '_' or i == '_action' then
              desc = desc .. "**" .. i .. "** - " .. tostring((type(v) == 'table' and table.concat(v, ', ')) or v) .. '\n'
              metadata[i] = v
            end
          end

          metadata.author = author.id

          local logs = client:getChannel(hiring.logs)

          local sent = embed({
            title = "Marketplace request for " .. author.tag .. " (" .. author.id .. ")",
            description = desc,
            fields = {
              {name = 'Metadata', value = "```json\n" .. json.encode(metadata) .. "```"}
            }
          }):send(logs)

          sent:addReaction(hiring.approved)
          sent:addReaction(hiring.unapprove)
          sent:addReaction(hiring.ban)

          prompt:reply 'Sent for approval!'

          msg:reply 'Prompt has finished'
          self.cooldowns[msg.author.id] = true

          prompt:close()
        end
      }
    }
  })
end

return comm:make()