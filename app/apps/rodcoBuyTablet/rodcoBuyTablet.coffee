RSpine = require("rspine")

class RodcoBuyTablet extends RSpine.Controller
  className: "app-canvas"
    
  constructor: ->
    super    
    @bind()
    @render()
  
  render: ->
    @html require("app/rodcoBuyTablet/layout")() 

  bind: ->
  
  shutdown: ->
    @release()

module.exports = RodcoBuyTablet