describe 'post command', () ->
  it 'should be able to cancel', () ->
    assert execute "#{bot.prefix}post"

    msg = assert execute 'cancel'

    assert msg.content == "Closed prompt.", 'Bot did not reply with `Closed prompt.`'

    assert not tester.errored, 'Bot errored while testing'
  it 'should be able to send a dm', () ->
    assert execute "#{bot.prefix}post"