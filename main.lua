local comrade = require 'Comrade'
local fs = require 'fs'

local client, dotenv = comrade.Client, comrade.dotenv

dotenv.config()

if not fs.accessSync './cache' then
  fs.mkdirSync 'cache'
end

local bot = client(process.env.TOKEN, {
  owners = {
    '525840152103223338',
    '294602562819325955'
  },
  prefix = "`",
  logFile = './cache/discordia.log',
  gatewayFile = './cache/gateway.json'
})

require './watcher'(bot)

bot:on('ready', function()
  -- Connect to metrics --
  bot:addCommand(comrade.Status)
end)

bot:login()