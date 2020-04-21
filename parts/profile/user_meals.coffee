if Meteor.isClient
    Template.user_meals.onCreated ->
        @autorun => Meteor.subscribe 'user_meals', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'meal'
    Template.user_meals.helpers
        meals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'meal'
                cook_user_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_meals', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'meal'
            _author_id: user._id
