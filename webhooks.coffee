utils = require "./utils"

issueCreated = (data, url) ->
  msg = 'New issue "' + data.issue.fields.summary + '"'
  msg = msg + ' created by ' + utils.formatUser(data.user.name)
  msg = msg + ' (' + utils.formatLink(url) + ')'

issueUpdated = (data, url) ->
  headline = 'Issue updated' 
  msg = ' "' + data.issue.fields.summary + '"'

  if data.changelog
    msg = msg + ' by ' + utils.formatUser(data.user.name)
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

    msg = msg + ' by ' + utils.formatUser(data.comment.author.name)
    msg = msg + ": " + utils.formatProse(data.comment.body)

  msg = headline + msg + ' (' + utils.formatLink(url) + ')'

module.exports = (req, res) ->
  data   = if req.body.payload? then JSON.parse req.body.payload else req.body

  # this cannot be the best way to get a web link to the issue
  url = data.issue.self.replace /rest.*$/, "browse/" + data.issue.key

  components = [];
  for comp in data.issue.fields.components
      components.push(comp.name)

  if data.webhookEvent == "jira:issue_created"
    msg = issueCreated data, url

  else if data.webhookEvent == "jira:issue_updated"
    msg = issueUpdated data, url

  else
    msg = "A " + data.webhookEvent + " happened on " + url

  msg = "[" + components.join(", ") + "] " + msg

