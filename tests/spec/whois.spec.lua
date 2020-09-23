return describe('whois command', function()
  it('get information on self', function()
    local msg = assert(execute(tostring(bot.prefix) .. "whois"))
    local embed = msg.embeds[1]
    local fields = { }
    for _, v in pairs(embed.fields) do
      fields[v.name] = v.value:trim()
    end
    assert(fields['User ID'] == tester.user.id, 'User ID not the same')
    return assert(not tester.errored, 'Bot errored while testing')
  end)
  return it('should get information on another user', function()
    local msg = execute(tostring(bot.prefix) .. "whois " .. tostring(bot.user.id))
    local embed = msg.embeds[1]
    local fields = { }
    for _, v in pairs(embed.fields) do
      fields[v.name] = v.value:trim()
    end
    assert(fields['User ID'] == bot.user.id, 'User ID not the same')
    return assert(not tester.errored, 'Bot errored while testing')
  end)
end)
