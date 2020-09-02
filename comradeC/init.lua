local scandirSync
scandirSync = require('fs').scandirSync
local helper = {
  version = '1.0.0-dev',
  name = 'Comrade'
}
local get
get = function(toload)
  local locations = {
    array = require('./structures/array'),
    client = require('./structures/client'),
    command = require('./structures/command'),
    embed = require('./structures/embed'),
    event = require('./structures/event'),
    help = require('./structures/help'),
    internalError = require('./structures/internalError'),
    lua_command = require('./structures/lua_command'),
    plugin = require('./structures/plugin'),
    logging = require('./helpers/logging'),
    prompt = require('./helpers/prompt'),
    util = require('./helpers/util'),
    argparser = require('./deps/argparser'),
    dotenv = require('./deps/dotenv'),
    extenstions = require('./deps/extenstions'),
    sandbox = require('./deps/sandbox'),
    color = require('./constants/color')
  }
  assert(locations[toload], 'Module not found')
  return locations[toload]
end
helper.get = { }
helper.lua = require('./lua')
setmetatable(helper.get, {
  __index = function(self, i)
    return get(i)
  end
})
get('extenstions')()
local log = get('logging')
local location = "\27[1;0mRunning at:    \27[4;38;5;14m" .. tostring(process.cwd()) .. "\27[1;0m"
local support = "\27[1;0mSupport:       \27[4;38;5;14mhttps://discord.gg/uCDq5mw\27[1;0m"
local documentation = "\27[1;0mDocumentation: \27[4;38;5;14mhttps://comrade.soviet.solutions\27[1;0m"
local version = tostring(_VERSION) .. " | " .. tostring(jit.version) .. "\27[1;0m"
print(log.render("\n{{#rgb}}235, 59, 90{{/rgb}}                                                              .o8{{reset}}                {{location}}{{reset}}  \n{{#rgb}}252, 92, 101{{/rgb}}                                                             \"888{{reset}}                {{support}}{{reset}}  \n{{#rgb}}254, 211, 48{{/rgb}} .ooooo.   .ooooo.  ooo. .oo.  .oo.   oooo d8b  .oooo.    .oooo888   .ooooo.{{reset}}     {{documentation}}{{reset}}  \n{{#rgb}}38, 222, 129{{/rgb}}d88' `\"Y8 d88' `88b `888P\"Y88bP\"Y88b  `888\"\"8P `P  )88b  d88' `888  d88' `88b{{reset}}\n{{#rgb}}69, 170, 242{{/rgb}}888       888   888  888   888   888   888      .oP\"888  888   888  888ooo888{{reset}}{{bright_white}}    {{version}}{{reset}}  \n{{#rgb}}75, 123, 236{{/rgb}}888   .o8 888   888  888   888   888   888     d8(  888  888   888  888    .o{{reset}}{{bright_white}}    {{os}} {{arch}}{{reset}}  \n{{#rgb}}165, 94, 234{{/rgb}}`Y8bod8P' `Y8bod8P' o888o o888o o888o d888b    `Y888\"\"8o `Y8bod88P\" `Y8bod8P'{{reset}}\n{{white}}▝▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▘{{reset}}    \n", {
  location = location,
  support = support,
  documentation = documentation,
  version = version,
  os = jit.os,
  arch = jit.arch
}))
return helper
