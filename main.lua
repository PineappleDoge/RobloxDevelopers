local comrade = require './comradeC'
local fs = require 'fs'

local get = comrade.get

local client, dotenv = get.client, get.dotenv

dotenv.config()

if not fs.accessSync './cache' then
  fs.mkdirSync 'cache'
end

local bot = client(process.env.TOKEN, {
  owners = {
    '525840152103223338',
    '294602562819325955'
  },
  prefix = "rd;",
  logFile = './cache/discordia.log',
  gatewayFile = './cache/gateway.json'
})

require './watcher'(bot)

bot:login()