import Date, enums from require 'discordia'

class embed
  new: (starting = {}) =>
    @embed = starting
  addField: (name,value,inline = false) =>
    @embed.fields = {} unless @embed.fields
    table.insert @embed.fields, {
      :name,
      :value,
      :inline
    }

    @
  addFields: (...) =>
    fields = {...}

    for _,v in pairs fields
      @addField unpack v

    @
  setAuthor: (name, iconURL, url) =>
    @embed.author = {
      :name,
      'icon_url': iconURL,
      :url
    }

    @
  setColor: (color) =>
    @embed.color = color

    @
  setDescription: (description) =>
    @embed.description = description

    @
  setFooter: (text, iconURL) =>
    @embed.footer = {
      :text,
      'icon_url': iconURL
    }

    @
  setImage: (url) =>
    @embed.image = {
      :url
    }

    @
  setThumbnail: (url) =>
    @embed.thumbnail = {
      :url
    }

    @
  setTimestamp: (timestamp = Date().toISO()) =>
    @embed.timestamp = timestamp

    @
  setTitle: (title) =>
    @embed.title = title

    @
  setURL: (url) =>
    @embed.url = url

    @
  toJSON: () =>
    @embed
  send: (channel) =>
    -- Check if we can send

    if channel.type == enums.channelType.private
      return channel\send {
        embed: @toJSON
      }
    else
      perms = channel.guild.me\getPermissions channel

      unless perms\has enums.permission.embedLinks -- Can't send embeds
        return channel\send 'I don\'t have the permissions to send embeds.'
      else
        return channel\send {
          embed: @toJSON!
        }
