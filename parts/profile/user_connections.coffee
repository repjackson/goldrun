if Meteor.isClient
    Template.user_connections.onCreated ->
        @autorun => Meteor.subscribe 'connections', Router.current().params.username
        @autorun => Meteor.subscribe 'people_connected', Router.current().params.username



    Template.user_connections.helpers
        connections: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                _id:$in: current_user.connected_ids

        people_connected: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                connected_ids:$in:[current_user._id]


    Template.user_connect_button.helpers
        is_connected: ->
            Meteor.user() and Meteor.user().connected_ids and @_id in Meteor.user().connected_ids


    Template.user_connect_button.events
        'click .connect':->
            Meteor.users.update Meteor.userId(),
                $addToSet: connected_ids:@_id

        'click .disconnect':->
            Meteor.users.update Meteor.userId(),
                $pull: connected_ids:@_id


        'keyup .assign_task': (e,t)->
            if e.which is 13
                post = t.$('.assign_task').val().trim()
                console.log post
                current_user = Meteor.users.findOne username:Router.current().params.username
                Docs.insert
                    body:post
                    model:'task'
                    assigned_user_id:current_user._id
                    assigned_username:current_user.username
                t.$('.assign_task').val('')




if Meteor.isServer
    Meteor.publish 'connections', (username)->
        current_user = Meteor.users.findOne username:username
        Meteor.users.find
            _id:$in: current_user.connected_ids

    Meteor.publish 'people_connected', (username)->
        current_user = Meteor.users.findOne username:username
        Meteor.users.find
            connected_ids:$in:[current_user._id]
