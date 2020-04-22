if Meteor.isClient
    Template.user_food.onCreated ->
        @autorun => Meteor.subscribe 'user_food', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.user_food.helpers
        food: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'food'
                cook_user_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_food', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'food'
            _author_id: user._id
