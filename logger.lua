local http = require 'coro-http'
local json = require 'json'

local comrade = require 'Comrade'

local Embed, Template = comrade.Embed, comrade.Template

local webhook = process.env.WEBHOOK

local plate = Template {
  title = 'Roblox Developers Status',
  description = '{{status}}'
}

local events = {}

local function send(embed)
  local data = {
    embeds = {
      embed:toJSON()
    }
  }

  local toSend = json.encode(data)

  local res, req = http.request('POST', webhook, {
    {'Content-Length', #toSend},
    {'Content-Type', 'application/json'}
  }, toSend)

  return res, req
end

function events.error(msg)
  send(plate:render {
    status = 'Error: \n' .. msg
  })
end

function events.info(msg)
  send(plate:render {
    status = 'Info: \n' .. msg
  })
end

return events