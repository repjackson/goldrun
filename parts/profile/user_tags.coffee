if Meteor.isClient
    Template.user_tags.onCreated ->
        @autorun => Meteor.subscribe 'user_tag_reviews', Router.current().params.username


    Template.user_tags.helpers
        connections: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                _id:$in: current_user.connected_ids

        people_connected: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find
                connected_ids:$in:[current_user._id]




# if Meteor.isServer
    # Meteor.publish 'connections', (username)->
    #     current_user = Meteor.users.findOne username:username
    #     Meteor.users.find
    #         _id:$in: current_user.connected_ids
    #
    # Meteor.publish 'people_connected', (username)->
    #     current_user = Meteor.users.findOne username:username
    #     Meteor.users.find
    #         connected_ids:$in:[current_user._id]
