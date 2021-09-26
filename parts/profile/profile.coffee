if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/rentals', (->
        @layout 'user_layout'
        @render 'user_rentals'
        ), name:'user_rentals'
    Router.route '/user/:username/services', (->
        @layout 'user_layout'
        @render 'user_services'
        ), name:'user_services'
    Router.route '/user/:username/products', (->
        @layout 'user_layout'
        @render 'user_products'
        ), name:'user_products'
    Router.route '/user/:username/credit', (->
        @layout 'user_layout'
        @render 'user_credit'
        ), name:'user_credit'
    Router.route '/user/:username/orders', (->
        @layout 'user_layout'
        @render 'user_orders'
        ), name:'user_orders'
    Router.route '/user/:username/messages', (->
        @layout 'user_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/groups', (->
        @layout 'user_layout'
        @render 'user_groups'
        ), name:'user_groups'
    Router.route '/user/:username/notifications', (->
        @layout 'user_layout'
        @render 'user_notifications'
        ), name:'user_notifications'
    Router.route '/user/:username/food', (->
        @layout 'user_layout'
        @render 'user_food'
        ), name:'user_food'
    Router.route '/user/:username/friends', (->
        @layout 'user_layout'
        @render 'user_friends'
        ), name:'user_friends'



    Template.user_bookmarks.onCreated ->
        @autorun -> Meteor.subscribe 'user_bookmarked_docs', Router.current().params.username


    Template.user_bookmarks.helpers
        bookmarked_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                _id: $in: user.bookmark_ids
if Meteor.isServer
    Meteor.publish 'user_bookmarked_docs', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            _id: $in: user.bookmark_ids
        
if Meteor.isClient
    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username

    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.user_layout.helpers
        user_from_username_param: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

    Template.user_layout.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Meteor.call 'insert_log', 'logout', Meteor.userId(), ->
                
            Router.go '/login'
            Meteor.logout()
