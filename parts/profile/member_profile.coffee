if Meteor.isClient
    Router.route '/member/:username', (->
        @layout 'member_profile_layout'
        @render 'member_info'
        ), name:'member_home'
    Router.route '/member/:username/info', (->
        @layout 'member_profile_layout'
        @render 'member_info'
        ), name:'member_info'
    Router.route '/member/:username/finance', (->
        @layout 'member_profile_layout'
        @render 'member_finance'
        ), name:'member_finance'
    Router.route '/member/:username/services', (->
        @layout 'member_profile_layout'
        @render 'member_services'
        ), name:'member_services'
    Router.route '/member/:username/bids', (->
        @layout 'member_profile_layout'
        @render 'member_bids'
        ), name:'member_bids'
    Router.route '/member/:username/products', (->
        @layout 'member_profile_layout'
        @render 'member_products'
        ), name:'member_products'
    Router.route '/member/:username/reservations', (->
        @layout 'member_profile_layout'
        @render 'member_reservations'
        ), name:'member_reservations'
    Router.route '/member/:username/handling', (->
        @layout 'member_profile_layout'
        @render 'member_handling'
        ), name:'member_handling'
    Router.route '/member/:username/rentals', (->
        @layout 'member_profile_layout'
        @render 'member_rentals'
        ), name:'member_rentals'
    Router.route '/member/:username/workhistory', (->
        @layout 'member_profile_layout'
        @render 'member_workhistory'
        ), name:'member_workhistory'
    Router.route '/member/:username/offers', (->
        @layout 'member_profile_layout'
        @render 'member_offers'
        ), name:'member_offers'
    Router.route '/member/:username/contact', (->
        @layout 'member_profile_layout'
        @render 'member_contact'
        ), name:'member_contact'
    # Router.route '/member/:username/stats', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_stats'
    #     ), name:'member_stats'
    # Router.route '/member/:username/votes', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_votes'
    #     ), name:'member_votes'
    Router.route '/member/:username/dashboard', (->
        @layout 'member_profile_layout'
        @render 'member_dashboard'
        ), name:'member_dashboard'
    # Router.route '/member/:username/requests', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_requests'
    #     ), name:'member_requests'
    # Router.route '/member/:username/tags', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_tags'
    #     ), name:'member_tags'
    # Router.route '/member/:username/tasks', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_tasks'
    #     ), name:'member_tasks'
    # Router.route '/member/:username/transactions', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_transactions'
    #     ), name:'member_transactions'
    # Router.route '/member/:username/messages', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_messages'
    #     ), name:'member_messages'
    # Router.route '/member/:username/bookmarks', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_bookmarks'
    #     ), name:'member_bookmarks'
    # Router.route '/member/:username/social', (->
    #     @layout 'member_profile_layout'
    #     @render 'member_social'
    #     ), name:'member_social'
    Router.route '/member/:username/comparison', (->
        @layout 'member_profile_layout'
        @render 'member_comparison'
        ), name:'member_comparison'
    Router.route '/member/:username/notifications', (->
        @layout 'member_profile_layout'
        @render 'member_notifications'
        ), name:'member_notifications'


    Template.member_profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'member_referenced_docs', Router.current().params.username
        # @autorun -> Meteor.subscribe 'member_models', Router.current().params.username

    Template.member_profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.member_about.helpers
    #     staff_resident_widgets: ->
    #         Docs.find
    #             model:'staff_resident_widget'

    # Template.member_section.helpers
    #     member_section_template: ->
    #         "member_#{Router.current().params.group}"

    Template.member_profile_layout.helpers
        user: ->
            Meteor.users.findOne username:Router.current().params.username

        member_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids

        viewing_more: -> Session.get 'viewing_more'

    Template.member_profile_layout.events
        'click .clock_in': ->
            if confirm 'clock in?'
                new_session_id = Docs.insert
                    model:'handling_session'
                    clock_in_timestamp: Date.now()
                    clock_in_date_ob: new Date()
                Meteor.users.update Meteor.userId(),
                    $set:
                        current_handling_session_id: new_session_id
                        handling_active:true

        'click .clock_out': ->
            Docs.update Meteor.user().current_handling_session_id,
                $set:
                    clock_out_timestamp: Date.now()
                    clock_out_date_ob: new Date()
            Meteor.users.update Meteor.userId(),
                $set:
                    current_handling_session_id: null
                    handling_active:false


        'click .toggle_view_more': ->
            Session.set('viewing_more', !Session.get('viewing_more'))


        'click .set_delta_model': ->
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()





if Meteor.isServer
    Meteor.publish 'user_connected_to', (username)->
        user = Meteor.users.findOne username:username
        if user.connected_ids
            Meteor.users.find
                _id:$in:user.connected_ids
    Meteor.publish 'user_connected_by', (username)->
        user = Meteor.users.findOne username:username
        Meteor.users.find
            connected_ids:$in:[user._id]
