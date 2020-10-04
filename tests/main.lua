require('luacov')
local Client, faker, dotenv
do
  local _obj_0 = require('Comrade')
  Client, faker, dotenv = _obj_0.Client, _obj_0.faker, _obj_0.dotenv
end
if not (process.env.TOKEN) then
  dotenv.config()
end
local prefix = '='
local bot = Client(process.env.TO_TEST, {
  prefix = prefix,
  testing = true,
  botid = '753093872959094854'
})
local tester = faker.Client(process.env.TESTER, {
  testbot = true,
  channel = '738682646653173822',
  mainbot = bot,
  waitTime = 2500
})
bot:addCommand(require('../commands/post.command')())
bot:addCommand(require('../commands/example.command')())
require('../plugins/information.plugin'):use(bot)
bot:login()
tester:login()
return tester:on('ready', function()
  if not (bot.ready) then
    bot:waitFor('ready', 10000)
  end
  tester:load('./spec')
  tester:executeTests()
  tester:stop()
  bot:stop()
  if faker.logger.fails > 0 then
    return process:exit(1)
  else
    return process:exit(0)
  end
end)
