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

ErrorList = Backbone.Model.extend()

ErrorView = Mn.ItemView.extend
  template: HandlebarsTemplates['error']

RootView = Mn.LayoutView.extend
  el: 'body'
  template: HandlebarsTemplates['root']

  events:
    'submit form': 'signup'

  regions:
    'error': '.error-region'

  initialize: ->
    @model = new UserRegistration()
    @modelBinder = new Backbone.ModelBinder()

  onRender: ->
    @modelBinder.bind(@model, @el)

  displayErrors: (errors) ->
    errorList = new ErrorList(errors: errors)
    errorView = new ErrorView(model: errorList)
    @showChildView('error', errorView)

  signup: (e) ->

    self = this
    el = $(@el)

    e.preventDefault()

    @model.save @model.attributes,
      success: (userSession, response) ->
        self.currentUser = new User(response)
#        BD.vent.trigger("authentication:logged_in")

      error: (userSession, response) =>
        result = $.parseJSON(response.responseText)
        @displayErrors(result.errors)

ready = ->

  window.app = new Mn.Application()

  app.on 'start', ->
    Backbone.history.start()

  app.start()

  app.rootView = new RootView()
  app.rootView.render()

$(document).ready(ready)
$(document).on('page:load', ready)
