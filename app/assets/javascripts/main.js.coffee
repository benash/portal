currentUser = null
User = Backbone.Model.extend({})

UserRegistration = Backbone.Model.extend
  url: '/users'

  defaults:
    'email': ''
    'password': ''
    'password_confirmation': ''

  toJSON: ->
    user: @attributes

vent = new Backbone.Wreqr.EventAggregator()

vent.on 'signed-in',(userJson) ->
  currentUser = new User(userJson)
  app.rootView.showChildView('main', new MainView(currentUser: currentUser))

vent.on 'signed-out', () ->
  currentUser = null
  app.rootView.showChildView('main', new UnauthenticatedView())

ErrorList = Backbone.Model.extend()

ErrorView = Mn.ItemView.extend
  tagName: 'ul'
  className: 'errors'
  template: HandlebarsTemplates['error']

SignupView = Mn.LayoutView.extend
  className: 'box'
  template: HandlebarsTemplates['signup']

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
    e.preventDefault()

    @model.save @model.attributes,
      success: (userSession, response) ->
        vent.trigger('signed-in', response)

      error: (userSession, response) =>
        result = $.parseJSON(response.responseText)
        @displayErrors(result.errors)

UserSession = Backbone.Model.extend
  url: '/users/sign_in',

  toJSON: ->
    user: @attributes

  defaults:
    'email': '',
    'password': ''

SigninView = Mn.LayoutView.extend
  tagName: 'form'
  className: 'signin app-signin'

  template: HandlebarsTemplates['signin']

  events:
    'submit': 'signin'

  regions:
    'error': '.error-region'

  initialize: ->
    @model = new UserSession()
    @modelBinder = new Backbone.ModelBinder()

  onRender: ->
    @modelBinder.bind(@model, @el)

  displayErrors: (errors) ->
    errorList = new ErrorList(errors: errors)
    errorView = new ErrorView(model: errorList)
    @showChildView('error', errorView)

  signin: (e) ->
    e.preventDefault()

    @model.save @model.attributes,
      success: (userSession, response) ->
        vent.trigger('signed-in', response)

      error: (userSession, response) =>
        result = $.parseJSON(response.responseText)
        @displayErrors(result.errors)

FooterView = Mn.LayoutView.extend

  tagName: 'footer'

  template: HandlebarsTemplates['footer']

UnauthenticatedView = Mn.LayoutView.extend
  template: HandlebarsTemplates['unauthenticated']

  regions:
    'signup': '.app-signup-region'
    'signin': '.app-signin-region'
    'footer': '.app-footer-region'

  onRender: ->
    @showChildView('signup', new SignupView())
    @showChildView('signin', new SigninView())
    @showChildView('footer', new FooterView())

RootView = Mn.LayoutView.extend
  template: HandlebarsTemplates['root']
  regions:
    'main': '.app-main-region'

MainView = Mn.LayoutView.extend
  template: HandlebarsTemplates['main']
  events:
    'submit .app-signout': 'signout'

  initialize: (opts) ->
    @currentUser = opts.currentUser

  serializeData: ->
    @currentUser.toJSON()

  signout: (e) ->
    e.preventDefault()

    $.ajax '/users/sign_out',
      method: 'DELETE'
      success: (userSession, response) ->
        vent.trigger('signed-out')

ready = ->

  window.app = new Mn.Application()

  app.on 'start', ->
    Backbone.history.start()

  app.start()

  app.rootView = new RootView(el: 'body')
  app.rootView.render()

  if currentUserJson
    vent.trigger('signed-in', currentUserJson)
  else
    vent.trigger('signed-out')

$(document).ready(ready)
$(document).on('page:load', ready)
