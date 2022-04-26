Router.route '/checkins', -> @render 'checkins'
Router.route '/checkin/:doc_id', -> @render 'checkin_view'
Router.route '/checkin/:doc_id/edit', -> @render 'checkin_edit'
Router.route '/staff', -> @render 'staff'
Router.route '/frontdesk', -> @render 'frontdesk'



if Meteor.isClient
    Template.checkins.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'checkin', ->
    Template.checkin_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.checkin_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            

    Template.checkins.events
        'click .add_checkin': ->
            new_id = 
                Docs.insert 
                    model:'checkin'
            Router.go "/checkin/#{new_id}/edit"
            
            
    Template.checkins.helpers
        checkin_docs: ->
            Docs.find 
                model:'checkin'
                
                
                

    Template.checkin_view.helpers
        checkin: ->
            Docs.findOne
                model:'checkin'
                slug: Router.current().params.checkin_code

        checkins: ->
            Docs.find {
                model:'checkin'
            }, sort: checkin_number:1
                # checkin_slug:Router.current().params.checkin_code

    Template.checkin_view.events
        'keyup .checkin_number': (e,t)->
            if e.which is 13
                checkin_number = parseInt $('.checkin_number').val().trim()
                checkin_number = parseInt $('.checkin_number').val()
                checkin_label = $('.checkin_label').val().trim()
                checkin = Docs.findOne model:'checkin'
                Docs.insert
                    model:'checkin'
                    checkin_number:checkin_number
                    checkin_number:checkin.checkin_number
                    checkin_code:checkin.slug




    Template.checkin_card.onCreated ->
        @autorun => Meteor.subscribe 'checkin_residents', @data._id
        @autorun => Meteor.subscribe 'checkin_owners', @data._id
        @autorun => Meteor.subscribe 'checkin_permits', @data._id
        # @autorun => Meteor.subscribe 'checkin_checkins', Router.current().params.checkin_code

    Template.checkin_card.helpers
        owners: ->
            Meteor.users.find
                roles:$in:['owner']
                building_number:@building_number
                checkin_number:@checkin_number

        residents: ->
            Meteor.users.find
                roles:$in:['resident','owner']
                owner:$ne:true
                building_number:@building_number
                checkin_number:@checkin_number

        permits: ->
            Docs.find
                model: 'parking_permit'
                address_number:@building_number






if Meteor.isServer
    Meteor.publish 'checkin', (checkin_code)->
        Docs.find
            model:'checkin'
            slug:checkin_code



    Meteor.publish 'checkin_residents', (checkin_id)->
        checkin =
            Docs.findOne
                _id:checkin_id
        if checkin
            Meteor.users.find
                roles:$in:['resident']
                building_number:checkin.building_number
                checkin_number:checkin.checkin_number
                
                
                
if Meteor.isClient
    Template.checkin.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Session.get('new_guest_id'), ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'checkin_guests',Router.current().params.doc_id, ->
        @autorun -> Meteor.subscribe 'resident_from_session', Router.current().params.doc_id, ->
        # @autorun -> Meteor.subscribe 'session', Router.current().params.doc_id, ->
        # @autorun -> Meteor.subscribe 'model_docs', 'guest'

        # @autorun => Meteor.subscribe 'rules_signed_username', @data.username
    Template.checkin.onRendered ->
        # @timer = new ReactiveVar 5
        Session.set 'timer',5
        Session.set 'timer_engaged', false
        # Meteor.setTimeout ->
        #     session_document = Docs.findOne Router.current().params.doc_id
        #     # console.log @
        #     if session_document and session_document.user_id
        #         resident = Meteor.users.findOne session_document.user_id
        #         # if resident.user_id
        #         rules_found = Docs.findOne
        #             model:'rules_and_regs_signing'
        #             resident:resident.username
        #         if resident.rules_and_regulations_signed and resident.member_waiver_signed
        #             Session.set 'timer_engaged', true
        #             interval_id = Meteor.setInterval( ->
        #                 if Session.equals 'timer_engaged', true
        #                     if Session.equals 'timer', 0
        #                         Meteor.call 'submit_checkin'
        #                         Meteor.clearInterval interval_id
        #                     else
        #                         Session.set('timer', Session.get('timer')-1)
        #                 # t.timer.set(t.timer.get()-1)
        #             ,1000)
        # , 4000


    Template.checkin.events
        'click .cancel_checkin': ->
            session_document = Docs.findOne Router.current().params.doc_id
            if session_document
                Docs.remove session_document._id
            if session_document and session_document.user_id
                Meteor.users.update session_document.user_id,
                    $inc:
                        checkins_without_email_verification:-1
                        checkins_without_gov_id:-1


            Router.go "/checkin"

        # 'click .recheck_photo': ->
        #     session_document = Docs.findOne Router.current().params.doc_id
        #     if session_document and session_document.user_id
        #         user = Meteor.users.findOne session_document.user_id
        #         Meteor.call 'image_check', user
        #         Meteor.call 'staff_government_id_check', user
        #
        #
        #
        # 'click .recheck': ->
        #     console.log @
        #     Meteor.call 'run_user_checks', @
        #     Meteor.call 'member_waiver_signed', @
        #     Meteor.call 'rules_and_regulations_signed', @

        'click .add_guest': ->
            # console.log @
            session_document = Docs.findOne Router.current().params.doc_id
            new_guest_id =
                Docs.insert
                    model:'guest'
                    session_id: session_document._id
                    resident_id: session_document.user_id
                    resident: session_document.resident_username
            # Session.set 'displaying_profile', null
            #
            Router.go "/add_guest/#{new_guest_id}"

        'click .sign_rules': ->
            session_document = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:'rules_and_regs_signing'
                session_id: session_document._id
                resident_id: session_document.user_id
                resident: session_document.resident_username
            Router.go "/sign_rules/#{new_id}/#{session_document.resident_username}"
            # Session.set 'displaying_profile',null


        'click .sign_guidelines': ->
            session_document = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:'member_guidelines_signing'
                session_id: session_document._id
                resident_id: session_document.user_id
                resident: session_document.resident_username
            Router.go "/sign_guidelines/#{new_id}/#{session_document.resident_username}"
            # Session.set 'displaying_profile',null

        'click .add_recent_guest': ->
            current_session = Docs.findOne
                model:'checkin'
                current:true
            Docs.update current_session._id,
                $addToSet:guest_ids:@_id

        'click .remove_guest': ->
            current_session = Docs.findOne
                model:'checkin'
                current:true
            # console.log current_session
            Docs.update current_session._id,
                $pull:guest_ids:@_id

        'click .toggle_adding_guest': ->
            Session.set 'adding_guest', true
            Session.set 'timer_engaged', false

        'click .submit_checkin': (e,t)->
            Meteor.call 'submit_checkin'

        'click .cancel_auto_checkin': (e,t)->
            Session.set 'timer_engaged',false

    Template.checkin.helpers
        timer_engaged: ->
            Session.get 'timer_engaged'
        timer: ->
            Session.get 'timer'
            # console.log Template.instance()
            # Template.instance().timer.get()

        rules_signed: ->
            session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            if session_document.user_id
                resident = Meteor.users.findOne session_document.user_id
                # if resident.user_id
                Docs.findOne
                    model:'rules_and_regs_signing'
                    resident:resident.username
        session_document: -> Docs.findOne Router.current().params.doc_id

        adding_guests: -> Session.get 'adding_guest'
        checking_in_doc: ->
            session_document = Docs.findOne Router.current().params.doc_id
            # console.log session_document
            session_document
        checkin_guest_docs: () ->
            session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            Docs.find
                _id:$in:session_document.guest_ids

        user: ->
            session_document = Docs.findOne Router.current().params.doc_id
            if session_document and session_document.user_id
                Meteor.users.findOne session_document.user_id


    Template.resident_guest.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc_by_id', @data
    Template.resident_guest.helpers
        guest_doc: ->
            Docs.findOne Template.currentData()



if Meteor.isServer
    Meteor.publish 'kiosk_document', ()->
        Docs.find
            model:'kiosk'



    # publishComposite 'session', (doc_id)->
    #     {
    #         find: ->
    #             Docs.find doc_id
    #         children: [
    #             { find: (doc) ->
    #                 Meteor.users.find
    #                     _id: doc.user_id
    #                 }
    #             { find: (doc) ->
    #                 Docs.find
    #                     model: 'guest'
    #                     _id:doc.guest_ids
    #                 }
    #             ]
    #     }


if Meteor.isClient
    Template.checkin_input.onCreated ->
        @autorun => Meteor.subscribe 'health_club_members', Session.get('name_search'), ->
    Template.checkin.onCreated ->
        @autorun -> Meteor.subscribe 'me'

        # @autorun => Meteor.subscribe 'current_session'
        # @autorun => Meteor.subscribe 'model_docs', 'log_event'
        # @autorun => Meteor.subscribe 'users'


    Template.checkin.onRendered ->
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
        Meteor.setInterval ->
              $('.name_search').focus();
        , 5000
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 3000


    Template.checkin_input.helpers
        search_results: ->
            Docs.find 
                model:'resident'
            #     username: {$regex:"#{name_search}", $options: 'i'}
    Template.checkin.helpers
        current_session_doc: ()->
            Docs.findOne
                model:'checkin'
                current:true

        # selected_person: ->
        #     Meteor.users.findOne Session.get('selected_user_id')

        checkedin_members: ->
            Docs.find
                model:'resident'
                checked_in:true

        checking_in: -> Session.get('checking_in')
        is_query: -> Session.get('name_search')

        # events: ->
        #     Docs.find {
        #       model:'log_event'
        #     }, sort:_timestamp:-1


    Template.checkin_button.events
        'click .new_session': (e,t)->
            # $(e.currentTarget).closest('.button').transition('fade up')
            Session.set 'loading_checkin', true
            # Meteor.setTimeout =>
            # Docs.insert
            #     model:'log_event'
            #     object_id:@_id
            #     body: "#{@username} checked in."
            current_session_id = Docs.insert
                model:'checkin'
                active:true
                submitted:false
                approved:false
                # user_id:@_id
                guest_ids:[]
                # resident_username:@username
                resident_first_name: @first_name
                resident_last_name: @last_name
                resident_image_id: @image_id
                resident_id:@_id
                # current:true
            Session.set('current_session_id', current_session_id)
            # Meteor.call 'member_waiver_signed', @
            # Meteor.call 'image_check', @
            # Meteor.call 'staff_government_id_check', @
            # Meteor.call 'rules_and_regulations_signed', @
            # Meteor.call 'email_verified', @
            # Session.set 'name_search',null
            # Session.set 'session_document',session_document
            # Session.set 'checking_in',false

            # unless @email_verified
            #     Meteor.users.update @_id,
            #         $inc:checkins_without_email_verification:1
            #     updated_user = Meteor.users.findOne @_id
            #     if updated_user.checkins_without_email_verification > 4
            #         Meteor.users.update @_id,
            #             $set: email_red_flagged:true
            #     else
            #         Meteor.users.update @_id,
            #             $set: email_red_flagged:false

            # unless @staff_verifier
            #     Meteor.users.update @_id,
            #         $inc:checkins_without_gov_id:1
            #     updated_user = Meteor.users.findOne @_id
            #     if updated_user.checkins_without_gov_id > 4
            #         Meteor.users.update @_id,
            #             $set: gov_red_flagged:true
            #     else
            #         Meteor.users.update @_id,
            #             $set: gov_red_flagged:false

            $('.name_search').val('')
            # Router.go "/checkin/#{current_session_id}"
            Session.set 'loading_checkin', false
            Session.set 'displaying_profile',@_id
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
                Session.set 'name_search',null
                $('.name_search').val('')
                # , 100


    Template.checkin_input.events
        'click .name_search': (e,t)->
            Session.set 'checking_in',true

        'input .barcode_entry': (e, t)->

        # 'keyup .name_search': _.debounce((e,t)->
        'keyup .name_search': (e,t)->
            name_search = $('.name_search').val()
            console.log name_search
            # if e.which is 8
            #     if name_search.length is 0
            #         Session.set 'name_search',null
            #         Session.set 'checking_in',false
            # else
            if name_search.length > 1
                if isNaN(name_search)
                    Session.set 'name_search',name_search
                    # else
                    #     barcode_entry = parseInt name_search
                    #     # alert barcode_entry
                    #     Meteor.call 'lookup_user_by_code', barcode_entry, (err,res)->
                    #         Session.set 'displaying_profile',res._id
                    #         session_document = Docs.insert
                    #             model:'checkin'
                    #             active:true
                    #             submitted:false
                    #             approved:false
                    #             user_id:res._id
                    #             guest_ids:[]
                    #             resident_username:res.username
                    #             current:true
                    #         Meteor.call 'check_resident_status', res._id
                    #         Session.set 'name_search',null
                    #         # Session.set 'session_document',session_document
                    #         # Session.set 'checking_in',false
                    #         $('.name_search').val('')
                    #         Router.go "/checkin/#{session_document}"
                    #         Session.set 'displaying_profile',res._id
        # , 250)


        'click .clear_results': ->
            Session.set 'name_search',null
            Session.set 'checking_in',false
            $('.name_search').val('')




    Template.sign_waiver.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.receipt_id
        @autorun => Meteor.subscribe 'document_from_slug', 'rules_regs'
    Template.sign_waiver.helpers
        receipt_doc: -> Docs.findOne Router.current().params.receipt_id
        waiver_doc: ->
            Docs.findOne
                model:'document'
                slug:'rules_regs'


    # Template.checkin_card.onCreated ->
    #     @autorun => Meteor.subscribe 'doc_by_id', Session.get('new_guest_id')
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
    #         session_document = Docs.findOne Session.get 'session_document'
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
    #             session_document = Docs.findOne Session.get 'session_document'
    #             Docs.remove session_document._id
    #             checkin_doc = Session.set 'session_document',null
    #         , 250
    #         # document.reload()
    #
    #     'click .checkin': (e,t)->
    #         Session.set 'adding_guest', false
    #         # Session.set 'displaying_profile', null
    #         session_document = Docs.findOne
    #             model:'checkin'
    #         if session_document.guest_ids.length > 0
    #             # now = Date.now()
    #             current_month = moment().format("MMM")
    #             Meteor.users.update @_id,
    #                 $addToSet:
    #                     total_guests:checkin_doc.guest_ids.length
    #                     "#{current_month}_guests":checkin_doc.guest_ids.length
    #         Docs.update session_document._id,
    #             $set:
    #                 session_type:'checkin'
    #                 submitted:true
    #
    #
    #     'click .unit_key_checkout': (e,t)->
    #         session_document = Docs.findOne
    #             model:'checkin'
    #         Docs.update session_document._id,
    #             $set:
    #                 session_type:'unit_key_checkout'
    #                 submitted:true
    #
    #     'click .add_recent_guest': ->
    #         current_session = Docs.findOne
    #             model:'checkin'
    #             current:true
    #         Docs.update current_session._id,
    #             $addToSet:guest_ids:@_id
    #
    #     'click .remove_guest': ->
    #         current_session = Docs.findOne
    #             model:'checkin'
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



if Meteor.isClient
    Template.user_check_steps.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'user_check'
    Template.user_check_steps.helpers
        user_check: ->
            Docs.find
                model:'user_check'

        user_check_completed: ->
            context_user = Template.parentData()
            check = Template.currentData()
            context_user["#{check.slug}"]
            # console.log @slug

        checkins_left_without_email_verification: ->
            6-@checkins_without_email_verification

        checkins_left_without_gov_id: ->
            6-@checkins_without_gov_id


    Template.user_check_steps.events
        'click .recheck': ->
            # console.log @slug
            context_user = Template.currentData()
            console.log context_user
            # username = Template.parentData().resident_username
            Meteor.call @slug, context_user, (err,res)=>
                # Meteor.users.update context_user._id,
                #     $set: "#{@slug}":res


if Meteor.isServer
    Meteor.methods
        run_user_checks:(user)->
            # console.log 'running user checks for', user.username
            user_checks_docs = Docs.find(model:'user_check')
            # console.log 'count', user_checks_docs.count()
            for user_check in user_checks_docs.fetch()
                # console.log user
                console.log 'user_check', user_check.slug
                Meteor.call "#{user_check.slug}", user, (err,res)=>
                    # console.log 'check',user_check.slug,'res',res
            #         Meteor.users.update user._id,
            #             $set: "#{user_check.slug}":res
        image_check: (user)->
            if user.kiosk_photo
                Meteor.users.update user._id,
                    $set:
                        image_check:true
                    $unset:
                        checkins_without_image:1
            else
                Meteor.users.update user._id,
                    $inc:checkins_without_image:1
                updated_user = Meteor.users.findOne user._id
                if updated_user.checkins_without_image > 3
                    Meteor.users.update user._id,
                        $set: red_flagged:true

        rules_and_regulations_signed: (user)->
            console.log 'checking rules and regs for ', user.username
            found_rules_signing = Docs.findOne
                model:'rules_and_regs_signing'
                resident:user.username
                signature_saved:true
            # console.log 'found rules signing', found_rules_signing
            check_value = if found_rules_signing then true else false
            Meteor.users.update user._id,
                $set:rules_and_regulations_signed:check_value

        member_waiver_signed: (user)->
            console.log 'checking member waiver for ', user.username
            found_member_signing = Docs.findOne
                model:'member_guidelines_signing'
                resident:user.username
            # console.log 'found member signing', found_member_signing
            check_value = if found_member_signing then true else false
            Meteor.users.update user._id,
                $set:found_member_signing:check_value

        # email_verified: (user)->
        #     if user.emails and user.emails[0].verified
        #         console.log 'email verification', user.emails[0].verified
        #         Meteor.users.update user._id,
        #             $set:
        #                 email_verified:true
        #                 email_red_flagged:false
        #             $unset:checkins_without_email_verification:1
        #     else
        #         Meteor.users.update user._id,
        #             $set:email_verified:false
        staff_government_id_check: (user)->
            console.log 'running staff gov id check', user.username
            if user.staff_verifier
                Meteor.users.update user._id,
                    $set:staff_government_id_check:true
                    $unset:
                        checkins_without_gov_id:1
                        gov_red_flagged:1                
                        
                        
                        
if Meteor.isClient
    Template.staff.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000

    Template.staff.onCreated ->
        # @autorun => Meteor.subscribe 'todays_checklist', ->
        @autorun => Meteor.subscribe 'sessions', ->
        # @autorun => Meteor.subscribe 'shift_walks', 


    Template.staff.helpers
        old_session_docs: ->
            Docs.find 
                model:'checkin'
                
        active_sessions: ->
            Docs.find
                model:'checkin'
                active:true


    Template.staff.events
        'click .add_resident': ->
            new_id = 
                Docs.insert 
                    model:'resident'
            Router.go "/resident/#{new_id}/edit"
            


    Template.session_card.onCreated ->
        # @autorun => Meteor.subscribe 'user_by_username', @data.resident_username
        console.log @
        @autorun => Meteor.subscribe 'doc_by_id', Session.get('session_resident_id')
        @autorun => Meteor.subscribe 'session_guests', @data
    Template.session_card.helpers
        icon_class: ->
            switch @session_type
                when 'checkin' then 'treadmill'
                when 'garden_key_checkout' then 'basketball'
                when 'unit_key_checkout' then 'key'

        session_resident: ->
            console.log @
            # Meteor.users.findOne
            #     username:@resident_username
            Docs.findOne 
                model:'resident'
                _id:@resident_id
                # _id: Session.get('session_resident_id')


        checkin_guest_docs: () ->
            Docs.find
                _id:$in:@guest_ids

    Template.session_card.events
        'click .sign_out': (e,t)->
            # resident = Meteor.users.findOne
            #     username:@resident_username
            #
            # console.log @
            # if confirm "Check Out #{@first_name} #{@last_name}?"
            $(e.currentTarget).closest('.card').transition('fade up',500)
            Meteor.setTimeout =>
                Docs.update @_id,
                    $set: active: false
            , 500


if Meteor.isServer
    Meteor.methods
        lookup_key: (building_number, unit_number)->
            found_key = Docs.findOne
                model:'key'
                building_number:building_number
                unit_number:unit_number

    Meteor.publish 'sessions', ->
        Docs.find
            model:'checkin'
            # model:$in:['checkin','garden_key_checkout','unit_key_checkout']
            active:true

    Meteor.publish 'old_sessions', ->
        Docs.find
            model:'checkin'
            # model:$in:['checkin','garden_key_checkout','unit_key_checkout']
            active:$ne:true


    Meteor.publish 'session_guests', (session_data)->
        if session_data
            Docs.find
                _id:$in:session_data.guest_ids
                
                
if Meteor.isClient
    Template.view_key.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
        @autorun -> Meteor.subscribe('key_checkouts', Router.current().params.doc_id)

    Template.view_key.helpers
        key: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id

        checkouts: ->
            if Session.get 'editing_id'
                Docs.find
                    _id: Session.get('editing_id')
            else
                Docs.find
                    model: 'key_checkout'

        checkout_cal: -> moment(@checkout_dt).calendar()
        checkin_cal: -> moment(@checkin_dt).calendar()

        is_editing: -> Session.equals 'editing_id', @_id

    Template.view_key.events
        'click #log_checkout': ->
            swal {
                title: "Checkout #{@building_code} ##{@apartment_number} Key?"
                model: 'info'
                animation: true
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Check Out'
                confirmButtonColor: '#da5347'
            }, =>
                new_id = Docs.insert
                    building_code: @building_code
                    apartment_number: @apartment_number
                    checkout_dt: Date.now()
                    model: 'key_checkout'
                Docs.update Router.current().params.doc_id,
                    $set: checked_out: true
                Session.set 'editing_id', new_id

        'click .edit_checkout': -> Session.set 'editing_id', @_id
        'click .stop_editing': -> Session.set 'editing_id', null

        'click #delete_checkout': ->
            swal {
                title: "Delete Checkout?"
                model: 'warning'
                animation: true
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, =>
                Docs.remove @_id
                Session.set 'editing_id', null

        'click .check_in_key': ->
            swal {
                title: "Check In #{@building_code} ##{@apartment_number} Key for #{@name}?"
                model: 'info'
                animation: true
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Check In'
                confirmButtonColor: '#da5347'
            }, =>
                Docs.update @_id,
                    $set: checkin_dt: Date.now()
                Docs.update Router.current().params.doc_id,
                    $set: checked_out: false
                swal "Checked In Key at #{Date.now()}", "",'success'



if Meteor.isServer
    Meteor.publish 'key_checkouts', (doc_id)->

        key = Docs.findOne doc_id

        self = @
        match = {}
        match.type = 'key_checkout'
        match.building_code = key.building_code
        match.apartment_number = key.apartment_number
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true

        Docs.find match                