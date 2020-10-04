require 'luacov'

import Client, faker, dotenv from require 'Comrade'

unless process.env.TOKEN -- If they are already added we don't need to check for an env
  dotenv.config!

prefix = '='

bot = Client process.env.TO_TEST, {
  :prefix
  testing: true
  botid: '753093872959094854'
}

tester = faker.Client process.env.TESTER, {
  testbot: true
  channel: '738682646653173822'
  mainbot: bot
  waitTime: 2500
}

-- Load commands --

bot\addCommand require('../commands/post.command')!
bot\addCommand require('../commands/example.command')!

require('../plugins/information.plugin')\use bot

bot\login!
tester\login!

tester\on 'ready', () ->
  -- All tests should be ran from here
  unless bot.ready
    bot\waitFor 'ready', 10000

  tester\load './spec'

  tester\executeTests!

  tester\stop!
  bot\stop!

  if faker.logger.fails > 0
    process\exit 1
  else
    process\exit 0
