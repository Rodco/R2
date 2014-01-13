RSpine = require('rspine')

class App extends RSpine.Model
  @configure "App","namespace", "name", "path", "iconColor", "iconLabel", "label", "home", "type"

  @extend RSpine.Model.Ajax
  @extend RSpine.Model.Ajax.Auto

  @appPath: "./app/apps"
  @url: "/apps?appPath=#{@appPath}"

  constructor: -> 
    super 



module.exports = App