if Meteor.isClient
    Template.user_groups.onCreated ->
        @autorun => Meteor.subscribe 'user_groups', Router.current().params.username
    Template.user_groups.events
        'click .add_group': ->
            new_id =
                Docs.insert
                    model:'group'
            Router.go "/group/#{new_id}/edit"

    Template.user_groups.helpers
        groups: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'group'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'group'
            _author_id: user._id
