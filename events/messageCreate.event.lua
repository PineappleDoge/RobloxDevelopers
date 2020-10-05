local comrade = require 'Comrade'
local lru = require 'lru'

local toml = require 'toml'
local fs = require 'fs'
local timer = require 'timer'

local config = toml.parse(fs.readFileSync('config.toml'), {strict = true})
local event, lua, util = comrade.Event, comrade.lua, comrade.util

local showcase = config.showcase
local channels = showcase.channels

local msgs = {}

timer.setInterval(util.minutes(0.5), function()
  msgs = {}
end)

return lua.class('messageCreate', {
  execute = function(msg)
    if msg.embed and table.search(channels, msg.channel.id) then
      msg:addReaction '⭐'
    end

    msgs[msg.author.id] = (msgs[msg.author.id] and msgs[msg.author.id] + 1) or 1

    if msgs[msg.author.id]  > 6 then
      msg.member:addRole(config.muted)
    end
  end}, event, function(self)
  self:super(self,'new')
end)