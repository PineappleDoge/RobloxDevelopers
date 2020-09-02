import setTimeout,clearTimeout from require 'timer'

embed = require '../structures/embed'

prompts = {}

globalActions = {
  check: (content,prompt) ->
    if content == 'n' or content == 'no'
      prompt\reply 'Closing prompt, open again to correct'
      prompt\close!
    elseif content == 'y' or content == 'yes'
      prompt\next!
    else
      prompt\redo! 
}

class prompt
  new: (msg,client,config) =>
    return msg\reply 'Finish the currently open prompt' if prompts[msg.author.id]

    prompts[msg.author.id] = true

    @id = msg.author.id

    @stage = 0
    @data = {}

    @message = nil

    @channel = msg.channel
    @client = client

    @tasks = config.tasks
    @timeout = config.timeout or 30000

    @embed = config.embed or false

    @closed = false

    @co = coroutine.create () ->
      loop = () ->
        called, msg = client\waitFor 'messageCreate', @timeout, (recieved) ->
          recieved.author.id == msg.author.id and not @closed
        unless called
          @channel\send 'Closing prompt!' unless @closed
          @close! unless @closed
        else
          @handle msg
          loop!
      loop!

    @next!

    coroutine.resume @co

  -- Progression

  next: () =>
    @stage += 1
    @update!
  back: () =>
    @stage -= 1
    @update!
  redo: () =>
    @update!
  close: () =>
    @closed = true

    prompts[@id] = false
  handle: (msg = {}) =>
    if globalActions[@tasks[@stage].action]
      globalActions[@tasks[@stage].action] msg.content, @, msg
    else
      @tasks[@stage].action msg.content or nil, @, msg

  -- Sending

  update: () =>
    message = @tasks[@stage].message
    unless @message
      return @channel\send 'Error: No tasks found' unless @tasks[@stage]
      if @embed
        @message = message\send @channel
      else 
        @message = @channel\send message
    else
      return @channel\send 'Error: Prompt out of tasks' unless @tasks[@stage]
      if message == 'check'
        desc = ""
        for i,v in pairs @data
          desc = "#{desc}\n#{i}: #{v}" unless i\sub(0,1) == '_'

        if @embed
          correct = embed!
          correct\setTitle 'Is this correct? [y/yes | n/no]'
          correct\setDescription desc
          correct\setColor 0xee5253

          correct\send @channel
        else
          @message\reply "Is this correct? [y/yes | n/no]\n\n#{desc}"
      elseif message == 'now'
        @handle!
      elseif message ~= 'none'
        message\send @channel if @embed else @message\reply message
  reply: (content) =>
    @channel\send content

  -- Data management
  save: (key,value) =>
    @data[key] = value
  get: (key) =>
    @data[key]