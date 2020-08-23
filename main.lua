local comrade = require './comradeC'
local fs = require 'fs'

local get, lua = comrade.get, comrade.lua

local client, dotenv, command = get.client, get.dotenv, get.command

dotenv.config()

if not fs.accessSync './cache' then
  fs.mkdirSync 'cache'
end

local bot = client(process.env.TOKEN, {
  owners = {'525840152103223338'},
  prefix = "rd;",
  logFile = './cache/discordia.log',
  gatewayFile = './cache/gateway.json'
})

require './watcher'(bot)

bot:login()