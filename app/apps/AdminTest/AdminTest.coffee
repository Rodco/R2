RSpine = require("rspine")
App = require("app/AdminTest/app")

class AdminTest extends RSpine.Controller
  className: "app-canvas"
    
  constructor: ->
    super    
    @bind()
    @render()
  
  render: ->
    @html require("app/AdminTest/layout")() 

  bind: ->
  
  shutdown: ->
    @release()

module.exports = AdminTest