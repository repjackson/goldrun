if Meteor.isClient
    Template.nav.events
        # 'mouseenter .item': (e,t)->
        #     $(e.currentTarget).closest('.item').transition('pulse')
        # 'click .menu_dropdown': ->
            # $('.menu_dropdown').dropdown(
                # on:'hover'
            # )

        'click .add_meal': ->
            new_id =
                Docs.insert
                    model:'meal'
            Router.go("/meal/#{new_id}/edit")

        'click #logout': ->
            Session.set 'logging_out', true
            Meteor.logout ->
                Session.set 'logging_out', false
                Router.go '/'

        'click .set_models': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', 'model', ->
                Session.set 'loading', false

        'click .set_model': ->
            Session.set 'loading', true
            # Meteor.call 'increment_view', @_id, ->
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false

    Template.nav.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'users'
        # @autorun -> Meteor.subscribe 'users_by_role','staff'
        # @autorun -> Meteor.subscribe 'unread_messages'

    Template.nav.helpers
        notifications: ->
            Docs.find
                model:'notification'
        role_models: ->
            if Meteor.user()
                if Meteor.user() and Meteor.user().roles
                    if 'dev' in Meteor.user().roles
                        Docs.find {
                            model:'model'
                        }, sort:title:1
                    else
                        Docs.find {
                            model:'model'
                            view_roles:$in:Meteor.user().roles
                        }, sort:title:1
            else
                Docs.find {
                    model:'model'
                    view_roles: $in:['public']
                }, sort:title:1

        models: ->
            Docs.find
                model:'model'

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


        bookmarked_models: ->
            if Meteor.userId()
                Docs.find
                    model:'model'
                    bookmark_ids:$in:[Meteor.userId()]


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

    Meteor.publish 'bookmarked_models', ->
        if Meteor.userId()
            Docs.find
                model:'model'
                bookmark_ids:$in:[Meteor.userId()]


    Meteor.publish 'unread_messages', (username)->
        if Meteor.userId()
            Docs.find {
                model:'message'
                to_username:username
                read_ids:$nin:[Meteor.userId()]
            }, sort:_timestamp:-1


    Meteor.publish 'me', ->
        Meteor.users.find @userId
