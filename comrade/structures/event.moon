class event
  new: () =>
    intAssert @execute, 'No execution for event was found'

    @name = @@__name
  use: (client) =>
    client\on @name, @execute