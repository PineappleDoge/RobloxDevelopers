describe 'post command', () ->
  it 'be able to cancel', () ->
    assert execute "#{bot.prefix}post"

    msg = assert execute  'cancel'

    assert msg.content == "Closed prompt.", 'Bot did not reply with `Closed prompt.`'

    assert not tester.errored, 'Bot errored while testing'