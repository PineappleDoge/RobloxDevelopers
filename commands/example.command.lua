local comrade = require './comradeC'
local get = comrade.get

local command = get.lua_command

local comm = command('example')

comm.example = comm.name .. 'some example'
comm.description = 'Some description'
comm.usage = comm.name .. ' [some argument]'

function comm:execute(msg)
  msg:reply 'Some command'
end

return comm:make()