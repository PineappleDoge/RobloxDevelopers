local comrade = require 'Comrade'
local uv = require 'uv'
local cp = require 'childprocess'

local command, template, util, color = comrade.LuaCommand, comrade.Template, comrade.util, comrade.color

local comm = command 'neofetch'

local plate = template({
  title = "Neofetch",
  description = [[
  ```
{{info}}
  ```
  ]],
  color = color.LIGHT_GREEN
})

local info

cp.exec([[neofetch --stdout]], function(_, name)
  info = name
end)

function comm:execute(msg)
  plate:render({
    info = info
    --[[
    passwd = uv.os_get_passwd(),
    sys = uv.os_uname(),
    host = host,
    hostname = uv.os_gethostname(),
    uptime = util.formatLong(uv.uptime() * 1000),
    free = bytesToMb(uv.get_free_memory()),
    total = bytesToMb(uv.get_total_memory()),
    cpu_info = uv.cpu_info()[1].model
    --]]
  }):send(msg.channel)
end

return comm:make()