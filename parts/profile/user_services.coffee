if Meteor.isClient
    Template.user_services.onCreated ->
        @autorun => Meteor.subscribe 'user_services', Router.current().params.username
    Template.user_services.events
        'click .add_service': ->
            new_id =
                Docs.insert
                    model:'service'
            Router.go "/service/#{new_id}/edit"

    Template.user_services.helpers
        services: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'service'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_services', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'service'
            _author_id: user._id
