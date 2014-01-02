RSpine = require("rspine")

class RodcoBuyMobile extends RSpine.Controller
  className: "app-canvas"
    
  constructor: ->
    super    
    @bind()
    @render()
  
  render: ->
    @html require("app/rodcoBuyMobile/layout")() 

  bind: ->
  
  shutdown: ->
    @release()

module.exports = RodcoBuyMobile