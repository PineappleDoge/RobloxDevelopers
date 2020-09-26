local comrade = require 'Comrade'
local fs = require 'fs'

local net = require 'coro-net'
local json = require 'json'

local timer = require 'timer'

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

  -- Connect to metrics --
  local port = tonumber(process.argv[2])

  if port then
    local _, realWrite = assert(net.connect({
      port = port
    }))

    write = function(str)
      realWrite(str .. '|')
    end

    updateStats(write, bot)
  end
end)

-- Update metrics every minute --

timer.setInterval(60000, function()
  coroutine.wrap(updateStats)(write, bot)
end)

bot:login()