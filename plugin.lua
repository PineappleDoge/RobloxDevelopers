local loader = require './loader'.loadDir

local filePattern = '([^%/]+)%.plugin%.lua$'

return function(client)
  local env = {
    client = client,
    require = require,
    __index = _G
  }

  env = setmetatable(env, env)

  local function onBeforeload() end

  local function onLoad(n, r, c)
    r():use(client)
  end

  local function onFirstload(n)
    client:debug(n .. ' has been loaded!')
  end
  local function onReloaded(n)
    client:debug(n .. ' has been reloaded!')
  end
  local function onUnload(n)
    client:removeCommand(n)
  end
  local function onDeleted(n)
    client:warn(n .. ' has been deleted!')
    client:unload(n)
  end
  local function onErr(n, err)
    client:error(n .. ' has caused an error; ', err)
  end

  loader('./plugins/', filePattern, env, {
    onErr = onErr,
    onLoad = onLoad,
    onUnload = onUnload,
    onDeleted = onDeleted,
    onReloaded = onReloaded,
    onFirstload = onFirstload,
    onBeforeload = onBeforeload,
  })
end