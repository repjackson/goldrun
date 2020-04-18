if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'profile_home'
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
    Router.route '/user/:username/handling', (->
        @layout 'user_layout'
        @render 'user_handling'
        ), name:'user_handling'
    Router.route '/user/:username/rentals', (->
        @layout 'user_layout'
        @render 'user_rentals'
        ), name:'user_rentals'
    Router.route '/user/:username/offers', (->
        @layout 'user_layout'
        @render 'user_offers'
        ), name:'user_offers'
    Router.route '/user/:username/contact', (->
        @layout 'user_layout'
        @render 'user_contact'
        ), name:'user_contact'
    Router.route '/user/:username/stats', (->
        @layout 'user_layout'
        @render 'user_stats'
        ), name:'user_stats'
    Router.route '/user/:username/dashboard', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
    Router.route '/user/:username/requests', (->
        @layout 'user_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/user/:username/tags', (->
        @layout 'user_layout'
        @render 'user_tags'
        ), name:'user_tags'
    Router.route '/user/:username/tasks', (->
        @layout 'user_layout'
        @render 'user_tasks'
        ), name:'user_tasks'
    Router.route '/user/:username/transactions', (->
        @layout 'user_layout'
        @render 'user_transactions'
        ), name:'user_transactions'
    Router.route '/user/:username/messages', (->
        @layout 'user_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/bookmarks', (->
        @layout 'user_layout'
        @render 'user_bookmarks'
        ), name:'user_bookmarks'
    Router.route '/user/:username/social', (->
        @layout 'user_layout'
        @render 'user_social'
        ), name:'user_social'
    Router.route '/user/:username/friends', (->
        @layout 'user_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:username/comparison', (->
        @layout 'user_layout'
        @render 'user_comparison'
        ), name:'user_comparison'
    Router.route '/user/:username/notifications', (->
        @layout 'user_layout'
        @render 'user_notifications'
        ), name:'user_notifications'







    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_models', Router.current().params.username
        @autorun -> Meteor.subscribe 'model_docs', 'staff_user_widget'

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

        user_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids


    Template.user_layout.events
        'click .set_delta_model': ->
            Meteor.call 'set_delta_facets', @slug, null, true

        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()



    # Template.user_array_element_toggle.helpers
    #     user_array_element_toggle_class: ->
    #         # user = Meteor.users.findOne Router.current().params.username
    #         if @user["#{@key}"] and @value in @user["#{@key}"] then 'active' else ''
    # Template.user_array_element_toggle.events
    #     'click .toggle_element': (e,t)->
    #         # user = Meteor.users.findOne Router.current().params.username
    #         if @user["#{@key}"]
    #             if @value in @user["#{@key}"]
    #                 Meteor.users.update @user._id,
    #                     $pull: "#{@key}":@value
    #             else
    #                 Meteor.users.update @user._id,
    #                     $addToSet: "#{@key}":@value
    #         else
    #             Meteor.users.update @user._id,
    #                 $addToSet: "#{@key}":@value


    # Template.user_array_list.helpers
    #     users: ->
    #         users = []
    #         if @user["#{@array}"]
    #             for user_id in @user["#{@array}"]
    #                 user = Meteor.users.findOne user_id
    #                 users.push user
    #             users
    #
    #
    #
    # Template.user_array_list.onCreated ->
    #     @autorun => Meteor.subscribe 'user_array_list', @data.user, @data.array
    # Template.user_array_list.helpers
    #     users: ->
    #         users = []
    #         if @user["#{@array}"]
    #             for user_id in @user["#{@array}"]
    #                 user = Meteor.users.findOne user_id
    #                 users.push user
    #             users
    #
    #


    # Template.user_unit.onCreated ->
    #     @autorun => Meteor.subscribe 'user_unit', Router.current().params.username
    # Template.user_unit.helpers
    #     unit: ->
    #         current_user = Meteor.users.findOne username:Router.current().params.username
    #         console.log
    #         Docs.findOne
    #             model:'unit'
    #             building_number:current_user.building_number
    #             unit_number:current_user.unit_number


    # Template.user_unit.onCreated ->
    #     @autorun => Meteor.subscribe 'user_unit', Router.current().params.username

    # Template.user_log.onCreated ->
    #     @autorun => Meteor.subscribe 'user_log', Router.current().params.username
    # Template.user_log.helpers
    #     user_log_events: ->
    #         Docs.find {
    #             model:'log_event'
    #         }, sort:_timestamp:-1
    #



if Meteor.isServer
    Meteor.publish 'user_unit', (username)->
        user = Meteor.users.findOne username:username
        if user.unit_number
            Docs.find
                model:'unit'
                # building_code:user.building_code
                building_number:user.building_number
                unit_number:user.unit_number


    Meteor.publish 'user_bookmarks', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            bookmark_ids:$in:[user._id]


    Meteor.publish 'violations', (username)->
        Docs.find
            model:'violation'
            username:username


    Meteor.publish 'user_log', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'log_event'
            object_id:user._id


    Meteor.publish 'user_referenced_docs', (username)->
        Docs.find
            user:username


if Meteor.isClient
    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        # @autorun -> Meteor.subscribe 'member_referenced_docs', Router.current().params.username
        # @autorun -> Meteor.subscribe 'member_models', Router.current().params.username

    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.member_about.helpers
    #     staff_user_widgets: ->
    #         Docs.find
    #             model:'staff_user_widget'

    # Template.member_section.helpers
    #     member_section_template: ->
    #         "member_#{Router.current().params.group}"

    Template.user_layout.helpers
        user: ->
            Meteor.users.findOne username:Router.current().params.username

        member_models: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'model'
                _id:$in:user.model_ids

        viewing_more: -> Session.get 'viewing_more'

    Template.user_layout.events
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
