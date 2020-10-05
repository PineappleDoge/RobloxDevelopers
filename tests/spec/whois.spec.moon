describe 'whois command', () ->
  it 'should get information on self', () ->
    msg = assert execute "#{bot.prefix}whois"

    embed = msg.embeds[1]

    fields = {}

    for _,v in pairs embed.fields
      fields[v.name] = v.value\trim!
    
    assert fields['User ID'] == tester.user.id, 'User ID not the same'

    assert not tester.errored, 'Bot errored while testing'
  it 'should get information on another user', () ->
    msg = execute "#{bot.prefix}whois #{bot.user.id}"

    embed = msg.embeds[1]

    fields = {}

    for _,v in pairs embed.fields
      fields[v.name] = v.value\trim!
    
    assert fields['User ID'] == bot.user.id, 'User ID not the same'

    assert not tester.errored, 'Bot errored while testing'