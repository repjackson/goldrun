if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_home'
    Router.route '/user/:username/finance', (->
        @layout 'user_layout'
        @render 'user_finance'
        ), name:'user_finance'
    Router.route '/user/:username/orders', (->
        @layout 'user_layout'
        @render 'user_orders'
        ), name:'user_orders'
    Router.route '/user/:username/dashboard', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/messages', (->
        @layout 'user_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/notifications', (->
        @layout 'user_layout'
        @render 'user_notifications'
        ), name:'user_notifications'
    Router.route '/user/:username/meals', (->
        @layout 'user_layout'
        @render 'user_meals'
        ), name:'user_meals'







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
            Router.go '/login'
            Meteor.logout()
