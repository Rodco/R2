RSpine = require "rspine"
Profile = require("app/adminPanel/profile")
App = require("app/adminPanel/app")
AppPermission = require("app/adminPanel/appPermission")
EditApp = require("app/adminPanel/adminPanel_edit_app")

class AdminPanel extends RSpine.Controller
  className: "app-canvas adminPanel" 

  elements:
    ".profile-list" : "profileList"
    ".app-list" : "appList"
    ".app-permission-list" : "appPermissionList"

  events:
    "click .btn-create-app" : "onCreateApp"
    "click .app-item" : "onEditApp"
    "click .add-profile" : "onAddProfile"
    "click .btn-remove-app-from-permission" : "onRemoveAppFromPermission"
    "click .btn-save-profiles" : "onSaveAppPemissions"

  constructor: ->
    super
    @render()
    @bind()
    Profile.query()
    App.destroyAll()
    App.fetch()
    
    RSpine.one "platform:library-loaded-bootstrap", =>
      @profileList.find(".btn-add-profile").popover()
      
    RSpine.one "platform:library-loaded-dragdrop", =>
      @registerDragDrop()
  
  bind: ->
    @registerDragDrop()

    Profile.bind "refresh", @renderProfiles
    App.bind "refresh destroy", @renderApps
    AppPermission.bind "refresh create update destroy", @renderPermissions

  unbind: ->
    Profile.unbind "refresh", @renderProfiles
    App.unbind "refresh destroy", @renderApps
    AppPermission.bind "refresh create update destroy", @renderPermissions

  registerDragDrop: => 
    dragableElements = $(".app-item .drag-handle")
    if dragableElements.dragdrop and !@dragdropRegistered
      @dragdropRegistered = true
      console.log "registering drag drop"
      $(dragableElements).dragdrop
        makeClone: true,
        sourceHide: false,
        dragClass: "whileDragging",
        parentContainer: $("body")
        canDrop: (destination) ->
          return destination.parents(".app-permission-item").length == 1
        didDrop: (source, destination) =>
          source = source.parents(".app-item")
          appId = source.data "app"
          app = App.find appId
          destination = destination.parent() until destination.hasClass "app-permission-item"
          appPermissionId = destination.data "app-permission"
          appPermission = AppPermission.find appPermissionId
          @onAddPathToPermission(app, appPermission)

  render: ->
    @html require("app/adminPanel/layout")()

  renderApps: =>
    apps = []
    for app in App.all()
      apps.push app if !app.home
    list = require("app/adminPanel/layout_item_app")(apps)
    @appList.html list
    AppPermission.fetch()

  renderProfiles: =>
    list = require("app/adminPanel/layout_item_profile")(Profile.all())
    @profileList.html list
    @profileList.find(".btn-add-profile").popover?()

  renderPermissions: =>
    list = require("app/adminPanel/layout_item_app_permission")(AppPermission.all())
    @appPermissionList.html list

  onAddProfile: (e) ->
    target = $(e.target)
    device = target.html().toLowerCase()
    profileId = target.data "profile"
    profile = Profile.find profileId
    $(".btn-add-profile").popover("hide")
    profileName = profile.Name.split(' ').join('_').toLowerCase()
    ap = AppPermission.create type: "app", name: profileName, device: device, appPaths: []

  onCreateApp: ->
    RSpine.trigger "modal:show", EditApp , data: { isNewApp: true }

  onEditApp:  (e) ->
    target = $(e.target)
    target = target.parent() until target.hasClass "app-item"
    app = App.find target.data "app"
    RSpine.trigger "modal:show", EditApp , { data: app }

  onAddPathToPermission: (app, appPermission) ->
    appPermission.appPaths.push app.path
    appPermission.save()
    
  onRemoveAppFromPermission: (e) ->
    target = $(e.target)
    appPath = App.findByAttribute "path", target.data "app-path"
    permission = AppPermission.find target.data "app-permission"
    index = permission.appPaths.indexOf appPath
    permission.appPaths.splice(index,1)
    permission.save()
    
    permission.destroy() if permission.appPaths.length == 0

  onSaveAppPemissions: (e) ->
    AppPermission.custom( AppPermission.toJSON() , { method: "POST" })

  shutdown: (e) =>
    @release()
    @unbind()
    

module.exports = AdminPanel   