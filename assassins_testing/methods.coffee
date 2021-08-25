Meteor.methods
  startGame: ->
    phrases = _.shuffle Meteor.settings.phrases
    if Meteor.users.findOne(@userId)?.isAdmin and Game.find().count() == 0
      Game.insert {started: true, isFirstKill: true}
      shuffled = _.shuffle Meteor.users.find({isAdmin: {$ne: true}}).fetch()
      _.each shuffled, (user, index) ->
        target = (index + 1) % shuffled.length
        phrase = phrases[index % phrases.length]
        Meteor.users.update {_id: user._id}, {$set: {firstBlood: false, showLeader: false, kills: 0, index: index, target: target, alive: true, secretPhrase: phrase, dead: false}}
      _.each Meteor.users.find({isAdmin: {$ne: true}}).fetch(), (user) ->
        targetUser = Meteor.users.findOne {index: user.target}
        Meteor.users.update user._id,
          $set:
            targetName: targetUser.username

  assassinate: (phrase) ->
    user = Meteor.users.findOne @userId
    if not user.alive
      return
    targetUser = Meteor.users.findOne {index: user.target}
    if phrase != targetUser.secretPhrase
      return

    if Game.find().fetch().isFirstKill
      Meteor.users.update @userId,
        $set:
          firstBlood: true
      Game.update @gameID,
        $set:
          isFirstKill: false

    Meteor.users.update @userId,
      $set:
        target: targetUser.target
        targetName: targetUser.targetName
        showLeader: true
      $inc: {kills: 1}
    Meteor.users.update targetUser._id,
      $set:
        alive: false
        dead: true
        assassinatedBy: user.username
