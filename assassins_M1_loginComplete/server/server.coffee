Accounts.onCreateUser (options, user) ->
  if options.profile
    user.profile = options.profile

  if (not user.services?.google?)
    user.isAdmin = (user.username is Meteor.settings.adminName)
  else 
    user.isAdmin = (user.profile.name is Meteor.settings.adminName)
  
  user.index = -1
  user.target = -1
  user.targetName = ''
  user.alive = false
  user.secretPhrase = ''
  return user
Meteor.publish 'Players', ->
  if Meteor.users.findOne(@userId)?.isAdmin
    return Meteor.users.find()
  else
    return Meteor.users.find({_id: @userId})
Meteor.publish 'Game', ->
  return Game.find {}, {limit: 1}

Houston.add_collection Meteor.users
Houston.add_collection Game
Houston.add_collection Houston._admins