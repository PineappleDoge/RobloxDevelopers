import get, version, name from require '../init'
import internalError, array,logging  from get

discordia = require 'discordia'

import enums from discordia

Class,Client = discordia.class,discordia.Client

helper,get = Class 'Helper Client', Client

options = {
	'routeDelay'
	'maxRetries'
	'shardCount'
	'firstShard'
	'lastShard'
	'largeThreshold'
	'cacheAllMembers'
	'autoReconnect'
	'compress'
	'bitrate'
	'logFile'
	'logLevel'
	'gatewayFile'
	'dateTime'
	'syncGuilds'
}

helper.__init = (token,config={}) =>
  clientConfig = {}

  for i,v in pairs config
    if table.search options, i
      clientConfig[i] = v

  Client.__init(@, clientConfig)

  assert token, 'A token is required!'
  @_token = token
  @_prefix = config.prefix or '!'

  @_defaultHelp = config.defaultHelp or true
  @_owners = config.owners or {}

  @_start = os.time!

  @_commands = array!
  @_plugins = array!

  @_events = array!

  _G.intAssert = (condition, message='Condition is false') ->
    unless condition
      internalError(message, @)\send!
  _G.intError = (message) ->
    internalError(message, @)\send!

  @\on 'ready', () ->
    @\info "Ready as #{@user.tag}"

    if @_defaultHelp
      @addCommand require './help'

  @\on 'messageCreate', (msg) ->
    unless string.startswith(msg.content,@_prefix)
      return nil

    perms = msg.guild.me\getPermissions msg.channel
    
    unless perms\has enums.permission.sendMessages -- If we can't send messages then just reject
      @\debug "Comrade : No send messages"
      return nil

    command = string.split msg.content, ' '

    command = string.gsub command[1],@_prefix, ''

    args = table.slice(string.split(msg.content, ' '), 2)

    command = command\lower!

    found = @_commands\find (val) ->
      val\check command,msg, @

    if found
      @\debug "Comrade : Ran #{command}"
      succ,err = pcall () -> 
        found\run msg,args, @
      if not succ
        @\debug "Comrade : Error #{err}"
        intError err

helper.login = (status) =>
  @run "Bot #{@_token}"
  if status
    @setGame status

helper.addCommand = (command) =>
  @\debug "Comrade: New command #{command.name}"
  @_commands\push command

helper.removeCommand = (name) =>
  @_commands\forEach (command, pos) ->
    if command.parent == name or command.name == name
      @_commands\pop pos

helper.addEvent = (event) =>
  @\debug "Comrade: New listener #{event.name}"
  event\use @
  @_events\push event

get.start = () =>
  @_start
get.commands = () =>
  @_commands
get.version = () ->
  version
get.owners = () =>
  @_owners

helper