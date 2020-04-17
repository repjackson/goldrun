if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'profile_home'
        ), name:'user_home'
    Router.route '/user/:username/healthclub', (->
        @layout 'user_layout'
        @render 'resident_about'
        ), name:'resident_about'
    Router.route '/user/:username/residency', (->
        @layout 'user_layout'
        @render 'user_residency'
        ), name:'user_residency'


    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_models', Router.current().params.username
        @autorun -> Meteor.subscribe 'model_docs', 'staff_resident_widget'

    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    Template.user_section.helpers
        user_section_template: ->
            "user_#{Router.current().params.group}"

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



    Template.user_healthclub.events
        'click .generate_barcode': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user.healthclub_code
                JsBarcode("#barcode", current_user.healthclub_code);
            else
                alert 'no healthclub code'



    Template.user_array_element_toggle.helpers
        user_array_element_toggle_class: ->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"] and @value in @user["#{@key}"] then 'active' else ''
    Template.user_array_element_toggle.events
        'click .toggle_element': (e,t)->
            # user = Meteor.users.findOne Router.current().params.username
            if @user["#{@key}"]
                if @value in @user["#{@key}"]
                    Meteor.users.update @user._id,
                        $pull: "#{@key}":@value
                else
                    Meteor.users.update @user._id,
                        $addToSet: "#{@key}":@value
            else
                Meteor.users.update @user._id,
                    $addToSet: "#{@key}":@value


    Template.user_array_list.helpers
        users: ->
            users = []
            if @user["#{@array}"]
                for user_id in @user["#{@array}"]
                    user = Meteor.users.findOne user_id
                    users.push user
                users



    Template.user_array_list.onCreated ->
        @autorun => Meteor.subscribe 'user_array_list', @data.user, @data.array
    Template.user_array_list.helpers
        users: ->
            users = []
            if @user["#{@array}"]
                for user_id in @user["#{@array}"]
                    user = Meteor.users.findOne user_id
                    users.push user
                users




    Template.user_unit.onCreated ->
        @autorun => Meteor.subscribe 'user_unit', Router.current().params.username
    Template.user_unit.helpers
        unit: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            console.log
            Docs.findOne
                model:'unit'
                building_number:current_user.building_number
                unit_number:current_user.unit_number


    # Template.user_unit.onCreated ->
    #     @autorun => Meteor.subscribe 'user_unit', Router.current().params.username
    Template.user_permit.helpers
        permit_doc: ->
            Docs.findOne
                model:'parking_permit'


    Template.user_guests.onCreated ->
        @autorun => Meteor.subscribe 'user_guests', Router.current().params.username
    Template.user_guests.helpers
        guests: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'guest'
                _id:$in:user.guest_ids






    Template.user_checkins.onCreated ->
        @autorun => Meteor.subscribe 'healthclub_checkins', Router.current().params.username
    Template.user_checkins.helpers
        healthclub_checkins: ->
            Docs.find {
                model:'healthclub_session'
                resident_username:Router.current().params.username
            }, sort: _timestamp:-1




    Template.user_log.onCreated ->
        @autorun => Meteor.subscribe 'user_log', Router.current().params.username
    Template.user_log.helpers
        user_log_events: ->
            Docs.find {
                model:'log_event'
            }, sort:_timestamp:-1


    Template.membership_status.events
        'click .email_rules_receipt': ->
            Meteor.call 'send_rules_regs_receipt_email', @_id


    Template.staff_verification.events
        'click .verify': ->
            if confirm 'verify user government id?'
                current_user = Meteor.users.findOne username:Router.current().params.username
                Meteor.users.update current_user._id,
                    $set:
                        staff_verifier:Meteor.user().username
                        verification_timestamp:Date.now()

        'click .rerun_check': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'staff_government_id_check', current_user




if Meteor.isServer
    Meteor.publish 'healthclub_checkins', (username)->
        Docs.find
            model:'healthclub_session'
            resident_username:username


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


    Meteor.publish 'user_guests', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'guest'
            _id:$in:user.guest_ids


    Meteor.publish 'user_log', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'log_event'
            object_id:user._id


    Meteor.publish 'user_referenced_docs', (username)->
        Docs.find
            resident:username
