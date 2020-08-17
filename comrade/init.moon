helper = {
  version: '1.0.0-dev',
  name: 'Comrade'
}

mods = {}

locations = {
    'constants/', 'deps/', 'structures/',
    'helpers/'
}

get = (file) ->
  func = () ->
    modFile = nil
    for _,v in pairs locations
      succ,_ = pcall require, "./#{v}#{file}"
      modFile = require "./#{v}#{file}" if succ
    modFile
  
  mod = mods[file] or func!
  assert mod, "Module not found; #{file}"

  mods[file] = mod

  mod

helper.get = {}
helper.lua = require './lua'

setmetatable helper.get, {
  __index: (i) =>
    get i
}
--require('./deps/extenstions')!
get('extenstions')!

log = get 'logging'

location      = "\27[1;0mRunning at:    \27[4;38;5;14m#{process.cwd!}\27[1;0m"
support       = "\27[1;0mSupport:       \27[4;38;5;14mhttps://discord.gg/uCDq5mw\27[1;0m"
documentation = "\27[1;0mDocumentation: \27[4;38;5;14mhttps://comrade.soviet.solutions\27[1;0m"

version       = "#{_VERSION} | #{jit.version}\27[1;0m"

print log.render "
{{#rgb}}235, 59, 90{{/rgb}}                                                              .o8{{reset}}                {{location}}{{reset}}  
{{#rgb}}252, 92, 101{{/rgb}}                                                             \"888{{reset}}                {{support}}{{reset}}  
{{#rgb}}254, 211, 48{{/rgb}} .ooooo.   .ooooo.  ooo. .oo.  .oo.   oooo d8b  .oooo.    .oooo888   .ooooo.{{reset}}     {{documentation}}{{reset}}  
{{#rgb}}38, 222, 129{{/rgb}}d88' `\"Y8 d88' `88b `888P\"Y88bP\"Y88b  `888\"\"8P `P  )88b  d88' `888  d88' `88b{{reset}}
{{#rgb}}69, 170, 242{{/rgb}}888       888   888  888   888   888   888      .oP\"888  888   888  888ooo888{{reset}}{{bright_white}}    {{version}}{{reset}}  
{{#rgb}}75, 123, 236{{/rgb}}888   .o8 888   888  888   888   888   888     d8(  888  888   888  888    .o{{reset}}{{bright_white}}    {{os}} {{arch}}{{reset}}  
{{#rgb}}165, 94, 234{{/rgb}}`Y8bod8P' `Y8bod8P' o888o o888o o888o d888b    `Y888\"\"8o `Y8bod88P\" `Y8bod8P'{{reset}}
{{white}}▝▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▘{{reset}}    
", {
  :location,
  :support,
  :documentation,
  :version,

  os: jit.os,
  arch: jit.arch
}

helper