local comrade = require 'Comrade'
local fs = require 'fs'

local net = require 'coro-net'
local json = require 'json'

local timer = require 'timer'

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

-- Update metrics --

local function updateStats(write, bot)
  write(json.encode {
    method = 'set',
    id = 'users',
    name = 'Users',
    auth = process.env.METRICS_AUTH,
    value = #bot.users
  })

  write(json.encode {
    method = 'set',
    id = 'guilds',
    name = 'Guilds',
    auth = process.env.METRICS_AUTH,
    value = #bot.guilds
  })

  write(json.encode {
    method = 'set',
    id = 'dms',
    name = 'Private channels',
    auth = process.env.METRICS_AUTH,
    value = #bot.privateChannels
  })
end

require './watcher'(bot)

local function write()
  -- To prevent errors if not loaded
end

bot:on('ready', function()
  bot:addCommand(comrade.Status)

  logger.info 'Bot is online; This usually means it was restarted'

  -- Connect to metrics --
  local port = tonumber(process.argv[2])

  if port then
    local succ, realWrite = net.connect({
      port = port
    })

    if not succ then
      logger.error 'Unable to connect to metrics; exiting...'
      process:exit(1)
    end

    write = function(str)
      realWrite(str .. '|')
    end

    updateStats(write, bot)
  end
end)

bot:on('error', logger.error)

-- Update metrics every minute --

timer.setInterval(60000, function()
  coroutine.wrap(updateStats)(write, bot)
end)

bot:login()