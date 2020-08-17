class Error 
  new: (message, client) =>
    @message = message
    @traceback = debug.traceback!
    @client = client
  send: () =>
    unless @client
      print "Unhandled Error; \n#{@message}\n#{@traceback}"
      process\exit!
    else
      @client\debug @message
      if @client\getListenerCount('error') > 0
        @client\error @message
      else
        print "Unhandled Error; #{@message}\n#{@traceback}"
        process\exit!