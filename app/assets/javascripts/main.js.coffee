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

window.UserSession = Backbone.Model.extend
  url: '/users/sign_in'

  toJSON: ->
    user: @attributes

  defaults:
    'email': ''
    'password': ''

window.DesktopView = Mn.LayoutView.extend
  template: HandlebarsTemplates['desktop']
  className: 'app-desktop-container desktop-container'

  events:
    'submit .app-signin': 'signin'
    'submit .app-signup': 'signup'

  regions:
    'signin-error': '.app-signin .app-error-region'
    'signup-error': '.app-signup .app-error-region'

  initialize: ->
    window.signupModel = @signupModel = new UserRegistration()
    window.signupBinder = @signupBinder = new Backbone.ModelBinder()

    @signinModel = new UserSession()
    @signinBinder = new Backbone.ModelBinder()

  onRender: ->
    @signupBinder.bind(@signupModel, @$('.app-signup'))
    @signinBinder.bind(@signinModel, @$('.app-signin'))

  displaySigninErrors: (errors) ->
    errorList = new ErrorList(errors: errors)
    errorView = new ErrorView(model: errorList)
    @showChildView('signin-error', errorView)

  signin: (e) ->
    e.preventDefault()

    @signinModel.save @signinModel.attributes,
      success: (userSession, response) ->
        vent.trigger('signed-in', response)

      error: (userSession, response) =>
        result = $.parseJSON(response.responseText)
        @displaySigninErrors(result.errors)

  displaySignupErrors: (errors) ->
    errorList = new ErrorList(errors: errors)
    errorView = new ErrorView(model: errorList)
    @showChildView('signup-error', errorView)

  signup: (e) ->
    e.preventDefault()

    @signupModel.save @signupModel.attributes,
      success: (userSession, response) ->
        vent.trigger('signed-in', response)

      error: (userSession, response) =>
        result = $.parseJSON(response.responseText)
        @displaySignupErrors(result.errors)

MobileView = Mn.ItemView.extend
  template: HandlebarsTemplates['mobile']
  className: 'app-mobile-container mobile-container'

  onAttach: ->
    @$('.menu .item').tab()

UnauthenticatedView = Mn.LayoutView.extend
  template: HandlebarsTemplates['unauthenticated']
  className: 'app-unauthenticated-container'

  regions:
    desktop: '.app-desktop-region'
    mobile: '.app-mobile-region'

  onRender: ->
    @showChildView('desktop', new DesktopView())
    @showChildView('mobile', new MobileView())

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
