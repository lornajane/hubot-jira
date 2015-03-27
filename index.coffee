# Description
# A hubot plugin to integrate with JIRA
#
# Author
#   lornajane

targetRoom = process.env['HUBOT_JIRA_ROOM']
webhooks = require "./webhooks"

module.exports = (robot) ->
  robot.router.post '/hubot/jira', (req,res) -> 
    msg = webhooks req, res
    robot.messageRoom targetRoom, msg
    res.send 'OK'

