if Meteor.isClient
    Template.user_orders.onCreated ->
        @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'meal'
    Template.user_orders.helpers
        orders: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'order'
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_orders', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'order'
            _author_id: user._id
