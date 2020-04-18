if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_home'
    Router.route '/user/:username/finance', (->
        @layout 'user_layout'
        @render 'user_finance'
        ), name:'user_finance'
    Router.route '/user/:username/info', (->
        @layout 'user_layout'
        @render 'user_info'
        ), name:'user_info'
    Router.route '/user/:username/services', (->
        @layout 'user_layout'
        @render 'user_services'
        ), name:'user_services'
    Router.route '/user/:username/products', (->
        @layout 'user_layout'
        @render 'user_products'
        ), name:'user_products'
    Router.route '/user/:username/reservations', (->
        @layout 'user_layout'
        @render 'user_reservations'
        ), name:'user_reservations'
    Router.route '/user/:username/rentals', (->
        @layout 'user_layout'
        @render 'user_rentals'
        ), name:'user_rentals'
    Router.route '/user/:username/dashboard', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/requests', (->
        @layout 'user_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/user/:username/transactions', (->
        @layout 'user_layout'
        @render 'user_transactions'
        ), name:'user_transactions'
    Router.route '/user/:username/messages', (->
        @layout 'user_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/notifications', (->
        @layout 'user_layout'
        @render 'user_notifications'
        ), name:'user_notifications'







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
