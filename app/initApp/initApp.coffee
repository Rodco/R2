RSpine = require("rspine")     
require("lib/initSetup")
require("lib/utils")
  
Session = require("models/session")
User = require("models/user")
DataManager = require "managers/dataManager"
LoadManager = require "managers/loadManager"
 
class InitApp extends RSpine.Controller
 
  # Variables
  #  appsMetadata: Metadata of all Apps
  #  appsByPath: Dictionary of path with values of App Metadata
  #  Live Apps Paths: Array of Paths of instantiate Apps
  #  LiveAppsByPath: Dictionary of Paths with values of instantiate Apps
  #  liveAppPositionByPath: Dictionary of Paths with positions 
  # 
   
  constructor: ->
    super
    RSpine.appsMetadata = [];
    RSpine.appsByPath =  {}
    
    RSpine.liveAppPaths = []
    RSpine.liveAppsByPath = {}
    RSpine.liveAppPositionByPath = {}
    
    RSpine.libraries = {}
    
    LayoutManager = require "managers/#{RSpine.device}Manager"

    RSpine.bind "platform-app-launch-complete" , (app) ->
      panelsInApp = app.el.find(".panel-stretch")
      height = $(window).height();
      for panel in panelsInApp
        panel = $(panel)
        offset = panel.data("offset") or 0
        $(panel).css "height" , height - offset


    RSpine.resizeColumns= (selector, offset = 0) ->

    new LayoutManager(el: @el)
    new LoadManager(el: @el)
    new DataManager()


module.exports = InitApp   

# Variables:
# RSpine.device = Current device(desktop|table|mobile)

# Events:
#  platform:login_invalid
#  platform:app-launch
#  platform:app-shutdown
#  platform:apps_loaded
#  platform-app-launch-complete   
#  platform:app-current-changed
#  platform:app-shutdown-complete
#  platform:ajax-idle
#  platform:library-loaded-keyboard
#  platform:library-loaded-touch