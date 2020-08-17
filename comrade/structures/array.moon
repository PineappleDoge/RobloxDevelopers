class array
  new: (...) =>
    @data = {...}
  -- Metamethods
  __len: () =>
    #@data

  __pairs: () =>
    func = (tbl,k) ->
      local v

      k,v = next(tbl, k)

      if v then
        k,v
    
    func, @data, nil
  -- Looping
  forEach: (func) =>
    for i,v in pairs @
      func v,i,@data
  
  filter: (func) =>
    data = {}

    for _,v in pairs @
      if func v
        table.insert data,v
    @ unpack data
  find: (func) =>
    for i,v in pairs @
      if func v
        return v, i
  map: (func) =>
    newData = {}

    for _,v in pairs @
      table.insert newData, func v
    @ unpack newData
  -- Adding
  push: (item) =>
    table.insert @data, item

  -- Removing
  slice: (start,stop,step) =>
    table.slice @data, start,stop,step

  shift: () =>
    table.remove @data, 1

  pop: (pos) =>
    table.remove @data, pos