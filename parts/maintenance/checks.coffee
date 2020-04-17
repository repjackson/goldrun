if Meteor.isClient
    Template.user_check_steps.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'user_check'
    Template.user_check_steps.helpers
        user_check: ->
            Docs.find
                model:'user_check'

        user_check_completed: ->
            if Meteor.user().roles
                if 'dev' in Meteor.user().roles
                    false
                else
                    context_user = Template.parentData()
                    check = Template.currentData()
                    context_user["#{check.slug}"]
                    # console.log @slug

        checkins_left_without_email_verification: ->
            6-@checkins_without_email_verification

        checkins_left_without_gov_id: ->
            6-@checkins_without_gov_id


    Template.user_check_steps.events
        'click .recheck': (e,t)->
            $(e.currentTarget).closest('.recheck').transition('pulse')
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

        email_verified: (user)->
            if user.emails and user.emails[0].verified
                console.log 'email verification', user.emails[0].verified
                Meteor.users.update user._id,
                    $set:
                        email_verified:true
                        email_red_flagged:false
                    $unset:checkins_without_email_verification:1
            else
                Meteor.users.update user._id,
                    $set:email_verified:false
        staff_government_id_check: (user)->
            console.log 'running staff gov id check', user.username
            if user.staff_verifier
                Meteor.users.update user._id,
                    $set:staff_government_id_check:true
                    $unset:
                        checkins_without_gov_id:1
                        gov_red_flagged:1
        residence_paperwork: (user)->
            console.log 'running residence paperwork', user.username
            if user.owner
                if user.ownership_paperwork
                    Meteor.users.update user._id,
                        $set:residence_paperwork:true
            else
                if user.lease_agreement
                    Meteor.users.update user._id,
                        $set:residence_paperwork:true
