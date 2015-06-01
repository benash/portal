User = Backbone.Model.extend({})

UserRegistration = Backbone.Model.extend
  url: '/users'
  paramRoot: 'user'

  defaults:
    'email': ''
    'password': ''
    'password_confirmation': ''

  toJSON: ->
    user: @attributes

RootView = Mn.LayoutView.extend
  el: 'body'
  template: HandlebarsTemplates['root']

  events:
    'submit form': 'signup'

  initialize: ->
    @model = new UserRegistration()
    @modelBinder = new Backbone.ModelBinder()

  onRender: ->
    @modelBinder.bind(@model, @el)

  signup: (e) ->

    self = this
    el = $(@el)

    e.preventDefault()

    @model.save @model.attributes,
      success: (userSession, response) ->
        self.currentUser = new User(response)
#        BD.vent.trigger("authentication:logged_in")

#      error: (userSession, response) ->
#        result = $.parseJSON(response.responseText)
#        el.find('form').prepend(BD.Helpers.Notifications.error("Unable to complete signup."))
#        _(result.errors).each (errors,field) ->
#          $('#'+field+'_group').addClass('error')
#          _(errors).each (error, i) ->
#            $('#'+field+'_group .controls').append(BD.Helpers.FormHelpers.fieldHelp(error))
#        el.find('input.btn-primary').button('reset')

ready = ->

  window.app = new Mn.Application()

  app.on 'start', ->
    Backbone.history.start()

  app.start()

  app.rootView = new RootView()
  app.rootView.render()

$(document).ready(ready)
$(document).on('page:load', ready)
