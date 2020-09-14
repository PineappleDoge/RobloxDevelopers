-- COMPILED MOONSCRIPT
-- DO NOT TOUCH

local comrade = require 'Comrade'

local command, embed, prompt, color = comrade.Command, comrade.Embed, comrade.prompt, comrade.color

local request
request = require('coro-http').request
local encode
encode = require('json').encode
local hooks = process.env--[[{
  scripting = '',
  building = '',
  modeling = '',
  animating = '',
  clothing = '',
  vfx = '',
  graphics = '',
  other = ''
}]]
local post
do
  local _class_0
  local _parent_0 = command
  local _base_0 = {
    execute = function(self, msg, _, client)
      return prompt(msg, client, {
        timeout = 60000,
        embed = true,
        tasks = {
          {
            message = embed({
              title = 'Business Category Prompt',
              description = "Hello! You're currently in a prompt! Please look below and type the following answer, or type cancel to cancel",
              fields = {
                {
                  name = 'Post Options',
                  value = "hiring = You're hiring"
                }
              }
            }),
            action = function(content, prompt, msg)
              prompt:save('_creator', msg.author.tag)
              prompt:save('_icon', msg.author.avatarURL)
              if content == 'hiring' then
                return prompt:next()
              elseif content == 'cancel' then
                msg:reply('Closed prompt.')
                return prompt:close()
              else
                return prompt:redo()
              end
            end
          },
          {
            message = embed({
              title = 'Business Category Prompt',
              description = 'Great! What channel(s) would you like to post your hiring request in',
              fields = {
                {
                  name = 'Post Options',
                  value = 'Building, Scripting, Animating, Clothing, VFX, Graphics, Other'
                }
              }
            }),
            action = function(content, prompt)
              if content == 'cancel' then
                prompt:reply('Closed prompt.')
                return prompt:close()
              end
              local option = {
                'building',
                'scripting',
                'animating',
                'clothing',
                'vfx',
                'graphics',
                'other'
              }
              content = content:lower()
              if not (table.search(option, content)) then
                return prompt:redo()
              else
                prompt:save('selection', content:lower())
                return prompt:next()
              end
            end
          },
          {
            message = embed({
              title = 'Business Category Prompt',
              description = 'How much are you going to pay (robux)'
            }),
            action = function(content, prompt)
              if content == 'cancel' then
                prompt:reply('Closed prompt.')
                return prompt:close()
              end
              if not (tonumber(content)) then
                return prompt:redo()
              else
                prompt:save('payment', tonumber(content))
                return prompt:next()
              end
            end
          },
          {
            message = embed({
              title = 'Business Category Prompt',
              description = 'Write a description of what you want'
            }),
            action = function(content, prompt)
              if content == 'cancel' then
                prompt:reply('Closed prompt.')
                return prompt:close()
              end
              prompt:save('description', content)
              return prompt:next()
            end
          },
          {
            message = 'check',
            action = 'check'
          },
          {
            message = 'now',
            action = function(_, prompt)
              embed({
                title = 'Business Category Prompt',
                description = 'Posted your offer!'
              }):send(prompt.channel)
              local content = embed({
                title = "Hiring request for " .. tostring(prompt:get('selection')),
                description = "Payment: " .. tostring(prompt:get('payment')) .. " Robux",
                fields = {
                  {
                    name = 'Description',
                    value = prompt:get('description')
                  }
                },
                color = color.LIGHT_GREEN
              }):toJSON()
              local sending = encode({
                username = prompt:get('_creator'),
                ['avatar_url'] = prompt:get('_icon'),
                embeds = {
                  content
                }
              })
              request('POST', hooks[prompt:get('selection')], {
                {
                  'Content-Length',
                  #sending
                },
                {
                  'Content-Type',
                  'application/json'
                }
              }, sending)
              return prompt:close()
            end
          }
        }
      })
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self)
      _class_0.__parent.__init(self)
      self.description = 'Post to the hiring channels'
      self.usage = tostring(self.name)
      self.example = tostring(self.name)
    end,
    __base = _base_0,
    __name = "post",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  post = _class_0
end

return post