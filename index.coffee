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

    components = '';
    first = true
    for comp in data.issue.fields.components
      if first
        components = components + comp.name
        first = false
      else
        components = components + ", " + comp.name

    if data.webhookEvent == "jira:issue_created"

      msg = 'New issue "' + data.issue.fields.summary + '"'
      msg = msg + ' created by ' + data.user.name
      msg = msg + ' (' + url + ')'

    else if data.webhookEvent == "jira:issue_updated"
      
      headline = 'Issue updated' 
      msg = ' "' + data.issue.fields.summary + '"'
      msg = msg + ' by ' + data.user.name

      # did only one field change?
      if data.changelog.items.length == 1
        change = data.changelog.items[0]
        msg = msg + " - " + change.field + " is now " + change.toString

      else
        first = true
        for change in data.changelog.items 
          # handle if the issue was closed
          if change.field == "resolution" and change.toString == "Fixed"
            headline = "Issue closed"

          # Now give field details
          if first
            msg = msg + ": " + change.field
            first = false
          else
            msg = msg + ", " + change.field
        
        msg = msg + " updated" 

      msg = headline + msg + ' (' + url + ')'

    else
      msg = "A " + data.webhookEvent + " happened on " + url

    msg = "[" + components + "] " + msg
    robot.messageRoom targetRoom, msg
    res.send 'OK'

