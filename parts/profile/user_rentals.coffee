if Meteor.isClient
    Template.user_rentals.onCreated ->
        @autorun => Meteor.subscribe 'user_rentals', Router.current().params.username
    Template.user_rentals.events
        'click .add_rental': ->
            new_id =
                Docs.insert
                    model:'rental'
            Router.go "/rental/#{new_id}/edit"

    Template.user_rentals.helpers
        rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'rental'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_rentals', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'rental'
            _author_id: user._id
