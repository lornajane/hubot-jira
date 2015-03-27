# Description
# A hubot plugin to integrate with JIRA
#
# Author
#   lornajane

targetRoom = process.env['HUBOT_JIRA_ROOM']

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
      msg = msg + ' created by ' + data.user.name
      msg = msg + ' (' + url + ')'

    else if data.webhookEvent == "jira:issue_updated"
      
      headline = 'Issue updated' 
      msg = ' "' + data.issue.fields.summary + '"'

      if data.changelog
        msg = msg + ' by ' + data.user.name
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
        headline = "New comment on"
        msg = msg + ": " + data.comment.body

      msg = headline + msg + ' (' + url + ')'

    else
      msg = "A " + data.webhookEvent + " happened on " + url

    msg = "[" + components.join(", ") + "] " + msg
    robot.messageRoom targetRoom, msg
    res.send 'OK'

