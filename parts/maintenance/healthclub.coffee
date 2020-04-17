if Meteor.isClient
    Template.healthclub.onCreated ->
        @autorun => Meteor.subscribe 'health_club_members', Session.get('username_query')
        @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'global_settings'
        @autorun -> Meteor.subscribe 'users_by_role', 'staff'
        # @autorun => Meteor.subscribe 'current_session'
        # @autorun => Meteor.subscribe 'latest_movie'
        # @autorun => Meteor.subscribe 'model_docs', 'log_event'
        # @autorun => Meteor.subscribe 'users'


    Template.healthclub.onRendered ->
        # video = document.querySelector('#videoElement')
        # if navigator.mediaDevices.getUserMedia
        #   navigator.mediaDevices.getUserMedia(video: true).then((stream) ->
        #     video.srcObject = stream
        #     return
        #   ).catch (err0r) ->
        #     return
        # @autorun =>
        #     if @subscriptionsReady()
        #         Meteor.setTimeout ->
        #             $('.dropdown').dropdown()
        #         , 3000

        # Meteor.setTimeout ->
        #     $('.item').popup()
        # , 3000
        # Meteor.setInterval ->
        #       $('.username_search').focus();
        # , 5000
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 3000


    Template.healthclub.helpers
        current_session_doc: ()->
            Docs.findOne
                model:'healthclub_session'
                current:true

        latest_movie: ()->
            Docs.findOne
                model:'event'
                tags:$in:['movie']

        selected_person: ->
            Meteor.users.findOne Session.get('selected_user_id')

        checkedin_members: ->
            Meteor.users.find
                healthclub_checkedin:true

        checkedout_members: ->
            username_query = Session.get('username_query')
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                # healthclub_checkedin:$ne:true
                roles:$in:['resident','owner']
                },{ limit:20 }).fetch()


        checking_in: -> Session.get('checking_in')
        is_query: -> Session.get('username_query')

        events: ->
            Docs.find {
               model:'log_event'
            }, sort:_timestamp:-1


    Template.checkin_button.events
        'click .new_hc_session': (e,t)->
            # $(e.currentTarget).closest('.button').transition('fade up')
            Session.set 'loading_checkin', true
            # alert 'loading checkin'
            # Meteor.setTimeout =>
            # Docs.insert
            #     model:'log_event'
            #     object_id:@_id
            #     body: "#{@username} checked in."
            session_document = Docs.insert
                model:'healthclub_session'
                active:true
                submitted:false
                approved:false
                user_id:@_id
                guest_ids:[]
                resident_username:@username
                current:true
            Meteor.call 'member_waiver_signed', @, ->
            Meteor.call 'image_check', @, ->
            Meteor.call 'staff_government_id_check', @, ->
            Meteor.call 'rules_and_regulations_signed', @, ->
            Meteor.call 'email_verified', @, ->
            Meteor.call 'residence_paperwork', @, ->
            Session.set 'username_query',null
            # Session.set 'session_document',session_document
            # Session.set 'checking_in',false

            unless @email_verified
                Meteor.users.update @_id,
                    $inc:checkins_without_email_verification:1
                updated_user = Meteor.users.findOne @_id
                if updated_user.checkins_without_email_verification > 4
                    Meteor.users.update @_id,
                        $set: email_red_flagged:true
                else
                    Meteor.users.update @_id,
                        $set: email_red_flagged:false

            unless @staff_verifier
                Meteor.users.update @_id,
                    $inc:checkins_without_gov_id:1
                updated_user = Meteor.users.findOne @_id
                if updated_user.checkins_without_gov_id > 4
                    Meteor.users.update @_id,
                        $set: gov_red_flagged:true
                else
                    Meteor.users.update @_id,
                        $set: gov_red_flagged:false
            Session.set 'loading_checkin', false
            Meteor.call 'recalc_healthclub_stats', @
            Router.go "/healthclub_session/#{session_document}"
            Session.set 'displaying_profile',@_id

            $('.username_search').val('')
            # , 750

        'click .checkout': (e,t)->
            # $(e.currentTarget).closest('.card').transition('fade up')
            # Meteor.setTimeout =>
            Meteor.call 'checkout_user', @_id, =>
                $('body').toast({
                    title: "#{@first_name} #{@last_name} checked out"
                    class: 'success'
                    transition:
                        showMethod   : 'zoom',
                        showDuration : 250,
                        hideMethod   : 'fade',
                        hideDuration : 250
                })
                Session.set 'username_query',null
                $('.username_search').val('')
                # , 100


    Template.healthclub.events
        'click .username_search': (e,t)->
            Session.set 'checking_in',true

        'input .barcode_entry': (e, t)->

        'keyup .username_search': _.debounce((e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
            else
                if username_query.length > 1
                    if isNaN(username_query)
                        Session.set 'username_query',username_query
                    else
                        barcode_entry = parseInt username_query
                        # alert barcode_entry
                        Meteor.call 'lookup_user_by_code', barcode_entry, (err,res)->
                            Session.set 'displaying_profile',res._id
                            session_document = Docs.insert
                                model:'healthclub_session'
                                active:true
                                submitted:false
                                approved:false
                                user_id:res._id
                                guest_ids:[]
                                resident_username:res.username
                                current:true
                            Meteor.call 'check_resident_status', res._id
                            Session.set 'username_query',null
                            # Session.set 'session_document',session_document
                            # Session.set 'checking_in',false
                            $('.username_search').val('')
                            Router.go "/healthclub_session/#{session_document}"
                            Session.set 'displaying_profile',res._id
        , 250)


        'click .clear_results': ->
            Session.set 'username_query',null
            Session.set 'checking_in',false
            $('.username_search').val('')



    Template.add_resident.onCreated ->
        Session.set 'permission', false

    Template.add_resident.events
        'keyup #last_name': (e,t)->
            first_name = $('#first_name').val()
            last_name = $('#last_name').val()
            # $('#username').val("#{first_name.toLowerCase()}_#{last_name.toLowerCase()}")
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"
            Session.set 'permission',true
            if e.which is 13
                Meteor.call 'add_user', username, (err,res)=>
                    if err
                        alert err
                    else
                        Meteor.users.update res,
                            $set:
                                first_name:first_name
                                last_name:last_name
                                added_by_username:Meteor.user().username
                                added_by_user_id:Meteor.userId()
                                roles:['resident']
                                # healthclub_checkedin:true
                        Docs.insert
                            model: 'log_event'
                            object_id: res
                            body: "#{username} was created"
                        # Docs.insert
                        #     model:'log_event'
                        #     object_id:res
                        #     body: "#{username} checked in."
                        new_user = Meteor.users.findOne res
                        Session.set 'username_query',null
                        $('.username_search').val('')
                        Meteor.call 'email_verified',new_user
                        Router.go "/user/#{username}/edit"


        'click .create_resident': ->
            first_name = $('#first_name').val()
            last_name = $('#last_name').val()
            username = "#{first_name.toLowerCase()}_#{last_name.toLowerCase()}"
            Meteor.call 'add_user', username, (err,res)=>
                if err
                    alert err
                else
                    Meteor.users.update res,
                        $set:
                            first_name:first_name
                            last_name:last_name
                            added_by_username:Meteor.user().username
                            added_by_user_id:Meteor.userId()
                            roles:['resident']
                            # healthclub_checkedin:true
                    Docs.insert
                        model: 'log_event'
                        object_id: res
                        body: "#{username} was created"
                    # Docs.insert
                    #     model:'log_event'
                    #     object_id:res
                    #     body: "#{username} checked in."
                    new_user = Meteor.users.findOne res
                    Session.set 'username_query',null
                    $('.username_search').val('')
                    Meteor.call 'email_verified',new_user
                    Router.go "/user/#{username}/edit"


    Template.add_resident.helpers
        permission: -> Session.get 'permission'



    Template.health_club_status_small.onCreated ->
        Meteor.subscribe 'latest_reading', 'lower_hot_tub'
        Meteor.subscribe 'latest_reading', 'upper_hot_tub'
        Meteor.subscribe 'latest_reading', 'pool'



    Template.health_club_status_small.helpers
        latest_uht_reading: ->
            found = Docs.findOne {
                model:"upper_hot_tub_reading"
            }, {sort:_timestamp:-1, limit:1}
            # console.log found
            found
        latest_lht_reading: ->
            found = Docs.findOne {
                model:"lower_hot_tub_reading"
            }, {sort:_timestamp:-1, limit:1}
            # console.log found
            found

        latest_pool_reading: ->
            found = Docs.findOne {
                model:"pool_reading"
            }, {sort:_timestamp:-1, limit:1}
            # console.log found
            found



    Template.water_status.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'water_status'
        Meteor.subscribe 'latest_reading', @data.slug


    Template.water_status.helpers
        on: ->
            water_feature_status_doc =
                Docs.findOne
                    model:'water_status'
                    slug:@slug
            if water_feature_status_doc
                water_feature_status_doc.on

        latest_reading: ->
            Docs.findOne {
                model:"#{@slug}_reading"
            }, {sort:_timestamp:-1, limit:1}


    Template.water_status.events
        'click .toggle_status': ->
            # console.log @
            status_doc =
                Docs.findOne
                    model:'water_status'
                    slug:@slug
            if status_doc
                Docs.update status_doc._id,
                    $set:on:!status_doc.on
            else
                Docs.insert
                    model:'water_status'
                    slug:@slug
                    on:true




    Template.sign_waiver.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.receipt_id
        @autorun => Meteor.subscribe 'document_from_slug', 'rules_regs'
    Template.sign_waiver.helpers
        receipt_doc: -> Docs.findOne Router.current().params.receipt_id
        waiver_doc: ->
            Docs.findOne
                model:'document'
                slug:'rules_regs'


    # Template.checkin_card.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Session.get('new_guest_id')
    #     @autorun => Meteor.subscribe 'checkin_guests'
    #     # @autorun => Meteor.subscribe 'rules_signed_username', @data.username
    #
    #
    # Template.checkin_card.helpers
    #     rules_signed: ->
    #         Docs.findOne
    #             model:'rules_and_regs_signing'
    #             resident:@username
    #     session_document: ->
    #         healthclub_session_document = Docs.findOne Session.get 'session_document'
    #
    #     new_guest_doc: -> Docs.findOne Session.get('new_guest_id')
    #     user: -> Meteor.users.findOne @valueOf()
    #     checkin_card_class: ->
    #         unless @rules_signed then 'red_flagged'
    #         else unless @email_verified then 'yellow_flagged'
    #         else ""
    #         # else "green_flagged"
    #
    #     adding_guests: -> Session.get 'adding_guest'
    #
    #     red_flagged: ->
    #         rule_doc = Docs.findOne(
    #             model:'rules_and_regs_signing'
    #             resident:@username)
    #         if rule_doc
    #             false
    #         else
    #             true
    #         # unless @rules_signed then true else false
    #
    # Template.checkin_card.events
    #     'click .sign_rules': ->
    #         new_id = Docs.insert
    #             model:'rules_and_regs_signing'
    #             resident: @username
    #         Router.go "/sign_rules/#{new_id}/#{@username}"
    #         Session.set 'displaying_profile',null
    #
    #     'click .cancel_checkin': (e,t)->
    #         $(e.currentTarget).closest('.segment').transition('fade right',250)
    #         Meteor.setTimeout =>
    #             Session.set 'displaying_profile', null
    #             Session.set 'adding_guest', false
    #             healthclub_session_document = Docs.findOne Session.get 'session_document'
    #             Docs.remove healthclub_session_document._id
    #             checkin_doc = Session.set 'session_document',null
    #         , 250
    #         # document.reload()
    #
    #     'click .healthclub_checkin': (e,t)->
    #         Session.set 'adding_guest', false
    #         # Session.set 'displaying_profile', null
    #         healthclub_session_document = Docs.findOne
    #             model:'healthclub_session'
    #         if healthclub_session_document.guest_ids.length > 0
    #             # now = Date.now()
    #             current_month = moment().format("MMM")
    #             Meteor.users.update @_id,
    #                 $addToSet:
    #                     total_guests:checkin_doc.guest_ids.length
    #                     "#{current_month}_guests":checkin_doc.guest_ids.length
    #         Docs.update healthclub_session_document._id,
    #             $set:
    #                 session_type:'healthclub_checkin'
    #                 submitted:true
    #
    #
    #     'click .unit_key_checkout': (e,t)->
    #         healthclub_session_document = Docs.findOne
    #             model:'healthclub_session'
    #         Docs.update healthclub_session_document._id,
    #             $set:
    #                 session_type:'unit_key_checkout'
    #                 submitted:true
    #
    #     'click .add_recent_guest': ->
    #         current_session = Docs.findOne
    #             model:'healthclub_session'
    #             current:true
    #         Docs.update current_session._id,
    #             $addToSet:guest_ids:@_id
    #
    #     'click .remove_guest': ->
    #         current_session = Docs.findOne
    #             model:'healthclub_session'
    #             current:true
    #         Docs.update current_session._id,
    #             $pull:guest_ids:@_id
    #
    #     'click .toggle_adding_guest': ->
    #         Session.set 'adding_guest', true
    #
    #
    #     'click .add_guest': ->
    #         new_guest_id =
    #             Docs.insert
    #                 model:'guest'
    #                 resident_id: @_id
    #                 resident: @username
    #         Session.set 'displaying_profile', null
    #         #
    #         Router.go "/add_guest/#{new_guest_id}"
    #         #
    #         # Session.set 'new_guest_id', new_guest_id
    #         # $('.ui.fullscreen.modal').modal({
    #         #     closable: false
    #         #     onDeny: ->
    #         #         # window.alert('Wait not yet!')
    #         #         # return false;
    #         #         Docs.remove new_guest_id
    #         #     onApprove: ->
    #         #         # window.alert('Approved!')
    #         #   })
    #         #   .modal('show')
    #
    #
    #
    #
    # Template.checkin_card.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_id', @data


if Meteor.isServer
    Meteor.publish 'latest_movie', ->
        Docs.find {
            model:'event'
            tags:$in:['movie']
        }, sort: _timestamp:-1

    Meteor.publish 'global_settings', ->
        Docs.find {
            model:'global_settings'
        }, sort: _timestamp:-1

    Meteor.publish 'latest_reading', (slug)->
        # console.log slug
        Docs.find {
            model:"#{slug}_reading"
        }, {sort:_timestamp:-1, limit:1}
