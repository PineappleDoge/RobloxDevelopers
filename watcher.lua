local loader = require './loader'.loadDir

return function(client)
  local env = {
    client = client,
    require = require,
    __index = _G
  }

  env = setmetatable(env, env)

  -- Plugin watcher

  loader('./plugins/', '([^%/]+)%.plugin%.lua$', env, {
    onErr = function(n, err)
      client:error(n .. ' plugin has caused an error; ' .. err)
    end,
    onLoad = function(n,r,c)
      r():use(client)
    end,
    onUnload = function(n)
      client:removeCommand(n)
    end,
    onDeleted = function(n)
      client:warn(n .. ' plugin has been deleted!')
      client:unload(n)
    end,
    onReloaded = function(n)
      client:debug(n .. ' plugin has been reloaded!')
    end,
    onFirstload = function(n)
      client:debug(n .. ' plugin has been loaded!')
    end,
    onBeforeload = function() end,
  })

  -- Command watcher

  loader('./commands/', '([^%/]+)%.command%.lua$', env, {
    onErr = function(n, err)
      client:error(n .. ' command has caused an error; ' .. err)
    end,
    onLoad = function(n,r,c)
      client:addCommand(r())
    end,
    onUnload = function(n)
      client:removeCommand(n)
    end,
    onDeleted = function(n)
      client:warn(n .. ' command has been deleted!')
      client:unload(n)
    end,
    onReloaded = function(n)
      client:debug(n .. ' command has been reloaded!')
    end,
    onFirstload = function(n)
      client:debug(n .. ' command has been loaded!')
    end,
    onBeforeload = function() end,
  })
end