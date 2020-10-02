local comrade = require 'Comrade'
local fs = require 'fs'

local client, dotenv = comrade.Client, comrade.dotenv

dotenv.config()

local logger = require './logger'

if not fs.accessSync './cache' then
  fs.mkdirSync 'cache'
end

local bot = client(process.env.TOKEN, {
  owners = {
    '525840152103223338',
    '294602562819325955'
  },
  prefix = {"`", "="},
  logFile = './cache/discordia.log',
  gatewayFile = './cache/gateway.json'
})

require './watcher'(bot)

bot:on('ready', function()
  bot:addCommand(comrade.Status)

  logger.info 'Bot is online; This usually means it was restarted'
end)

bot:on('error', logger.error)

bot:login()