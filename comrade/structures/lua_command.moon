Command = require './command'

class lua_command
  new: (name) =>
    @name = name
  make: () =>
    data = @
    class extends Command
      new: () =>
        @@__name = data.name
        for i,v in pairs data
          if i != 'name'
            @[i] = v

        super!