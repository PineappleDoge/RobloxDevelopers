import get from require '../init'
import command,event from get

class plguinCommand extends command
  @commands = {}
  @__inherited: (klass) =>
    table.insert @@commands, klass!
  @clear: () =>
    @@commands = {}

class pluginEvent extends event
  @events = {}
  @__inherited: (klass) =>
    table.insert @@events, klass!
  @clear: () =>
    @@events = {}

class plugin
  new: () =>
    @command = plguinCommand
    @event = pluginEvent
  addCommand: (command) => 
    table.insert @commands, command
  addEvent: (event, listener) =>
    table.insert @events, {
      :event,
      :listener
    }
  use: (client) =>
    --for _,v in pairs @events
      --client\on v.event, v.listener
    for _,v in pairs plguinCommand.commands
      v.parent = @@__name
      client\addCommand v

    for _,v in pairs pluginEvent.events
      v.parent = @@__name
      client\addEvent v

    plguinCommand\clear!
    pluginEvent\clear!