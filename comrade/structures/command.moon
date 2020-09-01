import get from require '../init'
import util, embed from get

import setTimeout from require 'timer'

import Date from require 'discordia'

concatIndex = (tbl, sep=', ') ->
  val = ''
  for i,_ in pairs tbl
    val = "#{val}#{i}#{sep}"

  val\sub(0,#val - #sep)

class command
  new: () =>
    @name = @@__name or '_temp_'

    @pre!
  pre: () =>
    intAssert @name, 'No name found'
    intAssert @execute, 'No execute command found'
    
    -- Fill in defaults

    @aliases = {}
    @permissions = {} 
    @subcommands = {}
    @cooldowns = {}

    @allowDMS = false
    @hidden = false

    @description = 'None'
    @usage = "#{@name}"
    @example = "#{@name}"

    ignore = {'pre', 'new', 'check', 'run', 'execute'}

    for i,v in pairs @@.__base
      if type(v) == 'function'
        unless table.search ignore, i
          @subcommands[i] = v

    if #@permissions > 0
      @allowDMS = false

    @preconditions! if @preconditions
  help: (channel) =>
    helpEmbed = embed!\setTitle('Help')\addFields {'Description',@description},
      {'Aliases', (table.concat(@aliases, ', ') == '' and 'None') or (table.concat(@aliases, ', ') != '' and table.concat(@aliases, ', '))},
      {'Subcommands', (concatIndex(@subcommands, ', ') == '' and 'None') or (concatIndex(@subcommands, ', ') != '' and concatIndex(@subcommands, ', '))},
      {'Usage', @usage},
      {'Example', @example}
      
    helpEmbed\send channel
  check: (command,msg,client) => 
    isValid = command\lower! == @name or table.search @aliases,command\lower!

    return false unless isValid

    isValid = not (@allowDMS and msg.channel.type == 1)

    return false unless isValid

    if @hidden
      return false unless table.search(client.owners,msg.author.id)

    unless @allowDMS
      isValid = util.checkPerm msg.member, msg.channel, @permissions

    return false unless isValid
    
    -- TODO; Cooldown

    if @cooldown
      if @cooldowns[msg.author.id]
        secondsLeft = @cooldown - (@cooldowns[msg.author.id] - Date!)\toMilliseconds!

        msg\reply "You are on cooldown, #{util.formatLong secondsLeft} left."
        return false
      else
        @cooldowns[msg.author.id] = Date!
        setTimeout @cooldown, () ->
          @cooldowns[msg.author.id] = false

    isValid
  run: (msg,args,client) =>
    -- Check for sub commands
    subcommand = args[1]

    if @subcommands[subcommand]
      args = table.slice args, 2
      @subcommands[subcommand] msg,args,client
    else
      @execute msg,args,client