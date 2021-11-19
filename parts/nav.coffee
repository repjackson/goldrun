if Meteor.isClient
    Template.nav.events
        # 'mouseenter .item': (e,t)->
        #     $(e.currentTarget).closest('.item').transition('pulse')
        # 'click .menu_dropdown': ->
            # $('.menu_dropdown').dropdown(
                # on:'hover'
            # )
        'click .add_post': ->
            # passcode = prompt 'set passcode'
            # if passcode
            new_id =
                Docs.insert
                    model:'post'
                    passcode:passcode
                    published:false
                    daily_rate:1
            Router.go "/post/#{new_id}/edit"
            

        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'

        'click .clear': ->
            picked_tags.clear()
                

    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.item').popup()
        , 2000
        
    Template.nav.onCreated ->
        Session.setDefault 'limit', 20
        @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'users'
        # @autorun -> Meteor.subscribe 'users_by_role','staff'
        # @autorun -> Meteor.subscribe 'unread_messages'

    Template.nav.helpers
        notifications: ->
            Docs.find
                model:'notification'

        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()

        cart_amount: ->
            cart_amount = Docs.find({
                model:'cart_item'
                _author_id:Meteor.userId()
            }).count()

        mail_icon_class: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()
            if unread_count then 'red' else ''



    Template.my_latest_activity.onCreated ->
        @autorun -> Meteor.subscribe 'my_latest_activity'
    Template.my_latest_activity.helpers
        my_latest_activity: ->
            Docs.find {
                model:'log_event'
                _author_id:Meteor.userId()
            },
                sort:_timestamp:-1
                limit:5


    Template.latest_activity.onCreated ->
        @autorun -> Meteor.subscribe 'latest_activity'
    Template.latest_activity.helpers
        latest_activity: ->
            Docs.find {
                model:'log_event'
            },
                sort:_timestamp:-1
                limit:5

if Meteor.isServer
    Meteor.publish 'my_notifications', ->
        Docs.find
            model:'notification'
            user_id: Meteor.userId()

    Meteor.publish 'my_latest_activity', ->
        Docs.find {
            model:'log_event'
            _author_id: Meteor.userId()
        },
            limit:5
            sort:_timestamp:-1

    Meteor.publish 'latest_activity', ->
        Docs.find {
            model:'log_event'
        },
            limit:5
            sort:_timestamp:-1


    Meteor.publish 'unread_messages', (username)->
        if Meteor.userId()
            Docs.find {
                model:'message'
                to_username:username
                read_ids:$nin:[Meteor.userId()]
            }, sort:_timestamp:-1

