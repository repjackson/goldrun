if Meteor.isClient
    Router.route '/residents', -> @render 'residents'
    Router.route '/users', -> @render 'users'
    Router.route '/members', -> @render 'members'

    Template.residents.onCreated ->
        @autorun => Meteor.subscribe 'user_search', Session.get('username_query'), 'resident'
    Template.profiles.onCreated ->
        @autorun => Meteor.subscribe 'profiles'
    Template.residents.helpers
        residents: ->
            username_query = Session.get('username_query')
            if username_query
                Meteor.users.find({
                    username: {$regex:"#{username_query}", $options: 'i'}
                    # healthclub_checkedin:$ne:true
                    # roles:$in:['resident','owner']
                    },{ limit:20 }).fetch()
            else
                Meteor.users.find({
                    # username: {$regex:"#{username_query}", $options: 'i'}
                    # healthclub_checkedin:$ne:true
                    roles:$in:['member']
                    },{ limit:20 }).fetch()
    Template.residents.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
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


    Router.route '/profiles', -> @render 'profiles'
    Template.profiles.helpers
        profiles: ->
            username_query = Session.get('username_query')
            if username_query and username_query.length > 0
                Meteor.users.find({
                    username: {$regex:"#{username_query}", $options: 'i'}
                    },{ limit:20 })
            else
                Meteor.users.find({
                    },{ limit:20 })
    Template.profiles.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
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


    Template.users.onCreated ->
        # @autorun -> Meteor.subscribe('users')
        @autorun => Meteor.subscribe 'user_search', Session.get('username_query')
    Template.users.helpers
        users: ->
            username_query = Session.get('username_query')
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # healthclub_checkedin:$ne:true
                # roles:$in:['resident','owner']
                },{ limit:20 }).fetch()
    Template.users.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
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


    Template.members.onCreated ->
        # @autorun -> Meteor.subscribe('members')
        @autorun => Meteor.subscribe 'user_search', Session.get('username_query'), 'member'
    Template.members.helpers
        members: ->
            username_query = Session.get('username_query')
            if username_query
                Meteor.users.find({
                    username: {$regex:"#{username_query}", $options: 'i'}
                    roles:$in:['member']
                    },{ limit:20 }).fetch()
            else
                Meteor.users.find({
                    roles:$in:['member']
                    },{ limit:20 }).fetch()
    Template.members.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        'keyup .member_search': (e,t)->
            username_query = $('.member_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query




    Router.route '/owners', -> @render 'owners'
    Template.owners.onCreated ->
        @autorun -> Meteor.subscribe('owners')
        @autorun => Meteor.subscribe 'user_search', Session.get('username_query'), 'owner'
    Template.owners.helpers
        owners: ->
            username_query = Session.get('username_query')
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # healthclub_checkedin:$ne:true
                roles:$in:['owner']
                },{ limit:20 }).fetch()
    Template.owners.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
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
            Meteor.users.find({},limit:limit)
        else
            Meteor.users.find()

    Meteor.publish 'owners', (limit)->
        if limit
            Meteor.users.find({},limit:limit)
        else
            Meteor.users.find(owner:true)

    Meteor.publish 'profiles', ()->
        Meteor.users.find
            roles:$in:['resident']
            profile_published:true


    Meteor.publish 'user_search', (username, role)->
        if role
            if username
                Meteor.users.find({
                    username: {$regex:"#{username}", $options: 'i'}
                    roles:$in:[role]
                },{ limit:20})
            else
                Meteor.users.find({
                    roles:$in:[role]
                },{ limit:20})
        else
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
            },{ limit:20})
