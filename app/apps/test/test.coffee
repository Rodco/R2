RSpine = require("rspine")

class Test extends RSpine.Controller
  className: "app-canvas"
    
  constructor: ->
    super    
    @bind()
    @render()
  
  render: ->
    @html require("app/test/layout")() 

  bind: ->
  
  shutdown: ->
    @release()

module.exports = Test