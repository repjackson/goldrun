if Meteor.isClient
    Router.route '/users', -> @render 'users'

    Template.users.onCreated ->
        @autorun -> Meteor.subscribe('users')
        @autorun => Meteor.subscribe 'user_search', Session.get('username_query')
    Template.users.helpers
        user_docs: ->
            username_query = Session.get('username_query')
            if username_query
                Docs.find({
                    username: {$regex:"#{username_query}", $options: 'i'}
                    # roles:$in:['resident','owner']
                    },{ limit:parseInt(Session.get('limit')) })
            else
                Docs.find({
                    },{ limit:parseInt(Session.get('limit')) })

    Template.users.events
        'click .add_user': ->
            new_username = prompt('username')
            Meteor.call 'add_user', new_username, (err,res)->
                console.log res
                new_user = Docs.findOne res
                Router.go "/user/#{new_user.username}/dashboard"
        'keyup .username_search': (e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query




if Meteor.isServer
    Meteor.publish 'users', (limit)->
        if limit
            Docs.find({},limit:limit)
        else
            Docs.find()


    Meteor.publish 'user_search', (username, role)->
        match = {}
        if username.length > 0 then match.username = {$regex:"#{username}", $options: 'i'}
        Docs.find(match,{limit:200})
