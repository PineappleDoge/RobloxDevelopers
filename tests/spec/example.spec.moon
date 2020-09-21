describe 'example command', () ->
  it 'should reply with `Some command`', () ->
    msg = assert execute "#{bot.prefix}example"

    assert msg.content == "Some command", 'Bot did not reply with `Some command`'

    assert not tester.errored, 'Bot errored while testing'