<div align="center">
  <img width="80" src="https://cdn.discordapp.com/avatars/717480384417366196/419a02865ccbafe9f6bc17ce1157cea2.png?size=2048">
  <h1>Roblox Developers Discord Bot</h1>

  <h3 align="center">
    Created by <a href="https://discord.gg/uCDq5mw">Soviet Studios</a>
  </h3>

  <a href="https://discord.gg/6wEYYGZ"> 
    <img src="https://img.shields.io/discord/460572114932465664?logo=discord&style=for-the-badge">
  </a>

  <a href="https://github.com/comrade-project/Comrade/">
    <img src="https://img.shields.io/badge/Powered%20by-Comrade-red?style=for-the-badge&color=success">
  </a>

  <img src="https://img.shields.io/github/contributors/Roblox-Developers-CodeSkids/RobloxDevelopers?style=for-the-badge">

  <img src="https://img.shields.io/travis/Roblox-Developers-CodeSkids/robloxdevelopers?style=for-the-badge">
</div>

Roblox Developers is a multi-purpose bot centered around management of Roblox Developers, a Roblox-Based development community focused on giving developers a place to collaborate, learn, and teach others!

## Contributing/Using

First clone the repository

```sh
git clone --recursive https://github.com/Roblox-Developers-CodeSkids/RobloxDevelopers.git
```

Next have a .env
```env
TOKEN=Your Token
```
Make sure to fill in the field with your token

If you want post to work you need to have a `config.toml` file which should be included.

You should replace the ids with ones in your servers

```toml
[hiring]
allowed = [ # If you don't have one of these roles you can't hire
  "462035726440202240",
  "462035713043464203",
  "462035700079001600",
  "462035687563067392",
  "462035652767252480",
  "462035643351040012"
]
notAllowed = [ # Over powers allowed
  "743926676693712977"
]
logs = "758187045754503169"

[hiring.channels]
portfolio = "690008198718947341"
builder = "689969106144985100"
modeler = "689969180384296981"
scripter = "689969158527778965"
animator = "689976433229168766"
clothing = "689969301582512177"
vfx = "689969644307611736"
graphics = "689969249376141395"
other = "689969604268654686"
selling = "690008026513801225"
```

Now once they are all filled in you should be able to run
```sh
luvit main.lua
```

### Contributors

If you are planning to make a large change make sure to send an issue before starting work on it.

Its best to do something from the todo as its whats most needed.

## TODO

- [x] Control over what roles have access to hiring and what don't
- [ ] Use comrade-boiler when it is released
- [ ] Portfolio and selling rewrites
- [ ] Auto moderator
- [ ] Tag command
- [ ] Database?

## Scrapped

- Configuration over webhooks; Webhooks are no longer used in favor of channel ids