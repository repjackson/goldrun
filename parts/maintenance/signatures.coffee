if Meteor.isClient
    Template.rules_signing.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.doc_id

    Template.rules_signing.helpers
        signing_doc: -> Docs.findOne Router.current().params.doc_id
        agree_class: -> if @agree then 'green' else 'basic'
        resident_email: ->
            res = Meteor.users.findOne
                username:@resident
            res.emails[0].address

    Template.rules_signing.events
        'click .confirm_email':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            email_value = $('.email_value').val('')

            if signing_doc.agree
                Docs.update signing_doc._id,
                    $set:email_confirmed:false
            else
                Docs.update signing_doc._id,
                    $set:email_confirmed:true

        'click .agree':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            if signing_doc.agree
                Docs.update signing_doc._id,
                    $set:agree:false
            else
                Docs.update signing_doc._id,
                    $set:agree:true

        'click .edit_signature':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            Docs.update signing_doc._id,
                $set:signature_saved:false


        'click .submit_rules':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            user = Meteor.users.findOne username:signing_doc.resident
            Meteor.users.update user._id,
                $set:rules_signed:true
            Meteor.call 'send_rules_regs_receipt_email', user._id
            Meteor.call 'run_user_checks', user
            # Session.set 'displaying_profile', user._id
            Router.go "/healthclub_session/#{signing_doc.session_id}"

    Template.guidelines_signing.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.doc_id

    Template.guidelines_signing.helpers
        signing_doc: -> Docs.findOne Router.current().params.doc_id
        agree_class: -> if @agree then 'green' else 'basic'
        resident_email: ->
            res = Meteor.users.findOne
                username:@resident
            res.emails[0].address

    Template.guidelines_signing.events
        'click .confirm_email':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            email_value = $('.email_value').val('')

            if signing_doc.agree
                Docs.update signing_doc._id,
                    $set:email_confirmed:false
            else
                Docs.update signing_doc._id,
                    $set:email_confirmed:true

        'click .agree':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            if signing_doc.agree
                Docs.update signing_doc._id,
                    $set:agree:false
            else
                Docs.update signing_doc._id,
                    $set:agree:true

        'click .edit_signature':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            Docs.update signing_doc._id,
                $set:signature_saved:false


        'click .submit_guidelines':->
            signing_doc = Docs.findOne Router.current().params.doc_id
            user = Meteor.users.findOne username:signing_doc.resident
            Meteor.users.update user._id,
                $set:member_waiver_signed:true
            # Meteor.call 'send_rules_regs_receipt_email', user._id
            Meteor.call 'run_user_checks', user
            # Session.set 'displaying_profile', user._id
            Router.go "/healthclub_session/#{signing_doc.session_id}"




    Template.rules_and_regs_check.onCreated ->
        @autorun => Meteor.subscribe 'rules_signed_username', @data.username
    Template.rules_and_regs_check.helpers
        rules_signed: ->
            Docs.findOne
                model:'rules_and_regs_signing'
                resident:@username
    Template.rules_and_regs_check.events
        'click .sign_rules': ->
            new_id = Docs.insert
                model:'rules_and_regs_signing'
                resident: @username
            Router.go "/sign_rules/#{new_id}/#{@username}"
            Session.set 'displaying_profile',null



    Template.member_guidelines_check.onCreated ->
        @autorun => Meteor.subscribe 'member_guidelines_username', @data.username
    Template.member_guidelines_check.helpers
        guidelines_signed: ->
            Docs.findOne
                model:'member_guidelines_signing'
                resident:@username
    Template.member_guidelines_check.events
        'click .sign_guidelines': ->
            new_id = Docs.insert
                model:'member_guidelines_signing'
                resident: @username
            Router.go "/sign_guidelines/#{new_id}/#{@username}"
            # Session.set 'displaying_profile',null




    Template.add_guest.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.new_guest_id
        @autorun => Meteor.subscribe 'session_from_guest_id', Router.current().params.new_guest_id
        @autorun => Meteor.subscribe 'resident', Router.current().params.new_guest_id
    Template.add_guest.helpers
        new_guest_doc: -> Docs.findOne Router.current().params.new_guest_id

    Template.add_guest.events
        'click .submit_new_guest': ->

        'click .cancel_new_guest': ->
            guest_doc = Docs.findOne Router.current().params.new_guest_id
            Docs.remove guest_doc._id
            Session.set 'displaying_profile', guest_doc.resident_id
            Router.go "/healthclub_session/#{guest_doc.session_id}"

            $('body').toast({
                title: "Adding guest canceled."
                class: 'info'
                transition:
                    showMethod   : 'zoom',
                    showDuration : 100,
                    hideMethod   : 'fade',
                    hideDuration : 100
            })

        'click .agree':->
            guest_doc = Docs.findOne Router.current().params.new_guest_id
            if guest_doc.agree
                Docs.update guest_doc._id,
                    $set:agree:false
            else
                Docs.update guest_doc._id,
                    $set:agree:true

        'click .edit_signature':->
            signing_doc = Docs.findOne Router.current().params.new_guest_id
            Docs.update signing_doc._id,
                $set:signature_saved:false


        'click .submit_guest':->
            guest_doc = Docs.findOne Router.current().params.new_guest_id
            checking_in_doc = Docs.findOne guest_doc.session_id

            Docs.update checking_in_doc._id,
                $addToSet: guest_ids: guest_doc._id

            user = Meteor.users.findOne guest_doc.resident_id
            Meteor.users.update user._id,
                $addToSet:guest_ids: guest_doc._id

            # Session.set 'displaying_profile', guest_doc.resident_id
            Router.go "/healthclub_session/#{guest_doc.session_id}"





    Template.download_rules_pdf.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username
        @autorun => Meteor.subscribe 'document_by_slug', 'rules_regs'

    Template.download_rules_pdf.helpers
        downloading_user: ->
            Meteor.users.findOne username:Router.current().params.username


    Template.download_rules_pdf.events
        'click .download_rules_pdf': ->
            signing_doc = Docs.findOne model:'rules_and_regs_signing'
            Meteor.call 'generate_rules_pdf', signing_doc._id



if Meteor.isServer
    Meteor.publish 'user_by_username', (username)->
        Meteor.users.find
            username:username

    Meteor.publish 'user_by_user_id', (user_id)->
        Meteor.users.find user_id


    Meteor.publish 'session_from_guest_id', (guest_id)->
        guest_doc = Docs.findOne guest_id
        Docs.find
            _id:guest_doc.session_id
