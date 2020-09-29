local comrade = require 'Comrade'
local toml = require 'toml'
local json = require 'json'
local fs = require 'fs'

local Date = require 'discordia'.Date
local pp = require 'pretty-print'

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

local function format(tbl)
  return pp.strip(pp.dump(tbl))
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
          Great! Please attach an image containing a picture(s) about the product you wish to sell. The image will need to be in link form or uploaded directly to discord. If you'll like to skip this step, type next.
        <% elseif get('_action') == 'lfw' then %>
          Awesome, you're looking to post your work and show off your stuff. Do you perhaps have a website or a place that you have all your work in? If not, type next to skip this portion. [EX: Devforums Portfolio, Artstation Portfolio, Custom Website]
        <% end %>
        ]]}, true),
        action = function(content, prompt)
          content = content:lower()
          if content == 'cancel' then return exit(self, msg, prompt) end

          local action = prompt:get('_action')

          if action == 'hire' then

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
          elseif action == 'lfw' then
            prompt:save('work_location', content)
            prompt:next()
          elseif action == 'sell' then
            prompt:save('item', content)
            prompt:next()
          end
        end
      }, {
        message = plate:construct({description = [[
        <% if get('_action') == 'sell' then %>
          Write a short description about the product. This should list basic details about the product itself, who it's meant for, what it can/can't do, if it's going to be resold or not.
        <% elseif get('_action') == 'hire' then %>
          Great! Please type a description of the job you're looking for people to do. Be informative as possible, listing the workplace, stylistic visions, people on the team, ETC.
        <% elseif get('_action') == 'lfw' then %>
          Alright, can you give a short title for your portfolio post? [EX: UsernameHere | Builder, Scripter, Animator]
        <% end %>
        ]]}, true),
        action = function(content, prompt)
          if content == 'cancel' then return exit(self, msg, prompt) end
          local action = prompt:get('_action')

          if action == 'hire' or action == 'sell' then
            prompt:save('description', content)
          elseif action =='lfw' then
            prompt:save('title', content)
          end

          prompt:next()
        end
      }, {
        message = plate:construct({ description = [[
        <% if get('_action') == 'sell' then %>
          Please list a desired payment amount. Payment should be listed in a range from minimum accepted price to maximum accepted price. Payment numbers should end with the R$ Symbol (Robux), or another indicator of currency.
        <% elseif get('_action') == 'hire' then %>
          Great! Please list payment. If payment is negotiable, please list a price range in which you are willing to pay and **can** pay. If payment is percentage based (%), please state that.
        <% elseif get('_action') == 'lfw' then %>
          Great! Can you give a short description about yourself and what you do?
        <% end %>
        ]]}, true),
        action = function(content, prompt)
          if content == 'cancel' then return exit(self, msg, prompt) end
          local action = prompt:get('_action')

          if action == 'hire' or action == 'sell' then
            prompt:save('prices', content)
          elseif action == 'lfw' then
            prompt:save('description', content)
          end

          prompt:next()
        end
      }, {
        message = plate:construct({ description = [[
        <% if get('_action') == 'sell' then %>
          Anything else you would like to add?
        <% elseif get('_action') == 'hire' then %>
          Anything else? For example current studio work?
        <% elseif get('_action') == 'lfw' then %>
          Please send examples of your work, they'll need to be in link format or uploaded to Discord directly. Once you finish uploading your examples, type next to continue. Note: Only your first link will embed, and we have a mix limit of 3.
        <% end %>
        ]]}, true),
        action = function(content, prompt)
          if content == 'cancel' then return exit(self, msg, prompt) end
          local action = prompt:get('_action')

          if action == 'hire' or action == 'sell' then
            prompt:save('other', content)
          elseif action == 'lfw' then
            prompt:save('work', content)
          end

          prompt:next()
        end
      }, {
        message = plate:construct({ description = [[
        Final step, list your preferred contacts. Currently supported contact info is listed below:
        Please specify them in the format `method contact`. For example `Discord 4 times 1 is even less than 0#3870`. To remove a contact say `remove Discord`
        You can only have 1 of each contact so if you have 2 emails you can seperate them with a `,` (comma).
        <% 
        local contacts = get('contacts') or {}

        local msg = ''

        for i,v in pairs(contacts) do
          msg = msg .. i .. ': ' .. v .. '\n'
        end

        msg = msg:sub(0, #msg - 1) -- Remove trailing newline
        %>

        Currently choosen contacts: <%- #msg == '' and '`none`' or '```\n' .. msg .. '\n```' %>

        Say `next` to continue

        <:Emoji_Discord:722980358685065248> - `Discord`
        <:Emoji_Twitter:722981837278019635> - `Twitter`
        <:Emoji_Email:722982452208992269> - `Email`
        ]]}, true),
        action = function(content, prompt)
          if content == 'cancel' then return exit(self, msg, prompt) end

          local contacts = prompt:get('contacts') or {}
          local valid = {'email', 'twitter', 'discord'}

          local action, data = content:match '(%a+)%s+(.+)'

          if content:lower() == 'next' then
            if table.count(contacts) == 0 then
              prompt:reply 'You must select a contact!'
              return prompt:redo()
            else
              return prompt:next()
            end
          end

          if not action or not data then
            prompt:reply 'You did not supply the data or the action'

            return prompt:redo()
          end

          action = action:lower()

          if table.search(valid, action) then
            if contacts[action] then
              prompt:reply 'That contact already exists!'
              return prompt:redo()
            else
              contacts[action] = data

              prompt:save('contacts', contacts)

              return prompt:redo()
            end
          elseif action == 'delete' then
            if contacts[action] then
              contacts[action] = nil

              prompt:save('contacts', contacts)

              prompt:reply 'Removed contact from list'
              return prompt:redo()
            else
              prompt:reply 'That contact does not exist or you do not have it selected'
              return prompt:redo()
            end
          else
            prompt:reply 'That action does not exist!'
            return prompt:redo()
          end
        end

      }, {
        message = plate:construct({ description = [[
          Is this ok? (y/n)
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
        ]]}, true),
        action = 'check' -- We can use the check action as we want a yes or no
      }, {
        message = 'now',
        action = function(_, prompt)
          -- No changes needed as it just displays metadata
          local message = prompt:get '_message'
          local author = message.author

          local desc = ''
          local metadata = {}

          for i,v in pairs(prompt.data) do
            if i:sub(0, 1) ~= '_' or i == '_action' then
              desc = desc .. "**" .. i .. "** - " .. tostring((type(v) == 'table' and format(v)) or v) .. '\n'
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
            },
            footer = {
              text = 'Metadata used to allow database-less marketplaces'
            }
          }):send(logs)

          sent:addReaction(hiring.approved)
          sent:addReaction(hiring.unapprove)
          sent:addReaction(hiring.ban)

          prompt:reply 'Sent for approval!'

          msg:reply 'Prompt has finished'
          self.cooldowns[msg.author.id] = Date()

          prompt:close()
        end
      }
    }
  })
end

return comm:make()