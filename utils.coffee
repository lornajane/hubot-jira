enableColors = process.env['HUBOT_JIRA_IRC_COLORS']
if enableColors?
  IrcColors = require "irc-colors"

formatUser = (message) ->
  if IrcColors?
    "#{IrcColors.pink(message)}"
  else
    "#{message}"

formatLink = (message) ->
  if IrcColors?
    "#{IrcColors.blue(message)}"
  else
    "#{message}"

formatProse = (message) ->
  if IrcColors?
    # handle newlines
    lines = message.split(/\r\n|\r|\n/g)
    result = ""
    for line in lines
      if line.length
        result = result + "#{IrcColors.gray(line)}" + "\n"

    result
  else
    "#{message}"

module.exports = {formatUser: formatUser, formatLink: formatLink, formatProse: formatProse}


