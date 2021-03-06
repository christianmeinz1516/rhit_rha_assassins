Meteor.subscribe 'Players'
Meteor.subscribe 'Game'

getTitlePrefix = ->
  if Meteor.settings?.public?.titlePrefix?
    unsanitize(Meteor.settings.public.titlePrefix) + ' '
  else
    ''

Meteor.startup ->
  document.title = getTitlePrefix() + 'Assassins'


Template.layout.helpers
  username: ->
    Meteor.user()?.services?.google?.name || Meteor.user()?.username

  isAdmin: ->
    Meteor.user()?.isAdmin

  loggedIn: ->
    Meteor.user()?

  prefix: ->
    getTitlePrefix()

Template.adminContent.helpers
  gameStarted: ->
    Game.find().count() > 0

  livingUsers: ->
    Meteor.users.find({alive: true}, {sort: {index: 'asc'}}).fetch()

  print_kills: ->
    kills = Meteor.user()?.kills
    if kills?
      return if Number(kills) is 1 then '1 kill' else "#{kills} kills"
    else
      return 'undefined'

Template.userContent.helpers
  gameStarted: ->
    Game.find().count() > 0

  target: ->
    Meteor.user()?.targetName

  username: ->
    Meteor.user()?.services?.google?.name || Meteor.user()?.username

  dead: ->
    Meteor.user()?.alive == false

  print_kills: ->
    kills = Meteor.user()?.kills
    if kills?
      return if Number(kills) is 1 then '1 kill' else "#{kills} kills"
    else
      return 'undefined'

  phrase: ->
    Meteor.user()?.secretPhrase

  lastOneStanding: ->
    Meteor.user()? && ((Meteor.user().profile?.name == Meteor.user().targetName) ||
                       (Meteor.user().username == Meteor.user().targetName))

Template.gameStartButton.events
  click: (event) ->
    Meteor.call 'startGame'

Template.assassinateButton.events
  click: (event) ->
    phrase = prompt("If you have assassinated " + Meteor.user().targetName + ", then enter their secret phrase to prove it.")
    Meteor.call 'assassinate', phrase

Accounts.ui.config passwordSignupFields: 'USERNAME_AND_EMAIL'

Meteor.users.allow
update: (userId, doc) ->
  Meteor.users.findOne(userId).isAdmin

Meteor.users.deny
update: (userId, doc) ->
  not Meteor.users.findOne(userId).isAdmin
