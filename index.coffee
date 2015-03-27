# Description
# A hubot plugin to integrate with JIRA
#
# Author
#   lornajane

targetRoom = process.env['HUBOT_JIRA_ROOM']

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


module.exports = (robot) ->
  robot.router.post '/hubot/jira', (req, res) ->
    data   = if req.body.payload? then JSON.parse req.body.payload else req.body

    # this cannot be the best way to get a web link to the issue
    url = data.issue.self.replace /rest.*$/, "browse/" + data.issue.key

    components = [];
    for comp in data.issue.fields.components
        components.push(comp.name)

    if data.webhookEvent == "jira:issue_created"

      msg = 'New issue "' + data.issue.fields.summary + '"'
      msg = msg + ' created by ' + formatUser(data.user.name)
      msg = msg + ' (' + formatLink(url) + ')'

    else if data.webhookEvent == "jira:issue_updated"
      
      headline = 'Issue updated' 
      msg = ' "' + data.issue.fields.summary + '"'

      if data.changelog
        msg = msg + ' by ' + formatUser(data.user.name)
        # did only one field change?
        if data.changelog.items.length == 1
          change = data.changelog.items[0]
          msg = msg + " - " + change.field + " is now " + change.toString

        else
          fields = []
          for change in data.changelog.items 
            # handle if the issue was closed
            if change.field == "resolution" and change.toString == "Fixed"
              headline = "Issue closed"

            # Now give field details
            fields.push(change.field)

          msg = msg + ": " + fields.join(", ") + " updated" 

      else if data.comment
        # add or edit?
        if data.comment.created == data.comment.updated
          headline = "New comment on"
        else
          headline = "Comment edited on"

        msg = msg + ": " + formatProse(data.comment.body)

      msg = headline + msg + ' (' + formatLink(url) + ')'

    else
      msg = "A " + data.webhookEvent + " happened on " + url

    msg = "[" + components.join(", ") + "] " + msg
    robot.messageRoom targetRoom, msg
    res.send 'OK'

