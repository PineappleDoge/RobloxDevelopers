local comrade = require 'Comrade'

local command = comrade.LuaCommand

local comm = command 'example'

comm.example = comm.name .. 'some example'
comm.description = 'Some description'
comm.usage = comm.name .. ' [some argument]'

function comm:execute(msg)
  --msg:reply 'Some command'
end

return comm:make()