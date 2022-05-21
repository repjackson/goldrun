if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'



    Template.profile.onCreated ->
        Meteor.call 'calc_user_points', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'unread_logs',->
    Template.profile.onRendered ->
        Meteor.call 'increment_profile_view', Router.current().params.username, ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000

        
if Meteor.isClient
    Template.user_favorites.onCreated ->
        @autorun -> Meteor.subscribe 'user_favorites', Router.current().params.username, ->
    Template.user_favorites.helpers
        user_favorite_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                _id:$in:user.favorite_ids

    Template.user_social.onCreated ->
        @autorun -> Meteor.subscribe 'refered_users', Router.current().params.username, ->
    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_deposits', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_rentals', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_orders', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'current_viewing_doc', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'model_docs', 'group', ->
            
    Template.user_groups.onCreated ->
        @autorun -> Meteor.subscribe 'user_groups_member', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_groups_owner', Router.current().params.username, ->
        
        
        
        
if Meteor.isServer
    Meteor.publish 'refered_users', (username)->
        user = Meteor.users.findOne username:username
        Meteor.users.find 
            refered_by_id:user._id
            
if Meteor.isClient
    Template.user_social.helpers
        refered_user_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find 
                refered_by_id:user._id
            
    
    
    Template.user_posts.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'post', Router.current().params.username, ->
    Template.user_comments.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'comment', Router.current().params.username, ->
        
    Template.user_comments.helpers
        user_comment_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'comment'
                _author_id:user._id
        
    Template.user_posts.helpers
        user_authored_post_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'post'
                _author_id:user._id
    Template.user_posts.events 
        'click .add_user_post': ->
            user = Meteor.users.findOne username:Router.current().params.username
            new_id = 
                Docs.insert 
                    model:'post'
                    _author_id:user._id
                    _author_username:user.username
            Router.go "/doc/#{new_id}/edit"
        
    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
            $('.avatar').popup()
        , 2000
    Template.doc_view.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000

    Template.profile.events
        'click .login_as_user': ->
            
        'click .recalc_wage_stats': (e,t)->
            Meteor.call 'recalc_wage_stats', Router.current().params.username, ->

        'click .create_profile': ->
            Docs.insert 
                model:'user'
                username:Router.current().params.username
                
        'click .send_points': ->
            user = Meteor.users.findOne username:Router.current().params.username
            new_id = 
                Docs.insert 
                    model:'transfer'
                    target_user_id: user._id
            Router.go "/doc/#{new_id}/edit"
            
            
        'click .boop': (e,t)->
            $(e.currentTarget).closest('.boop').transition('bounce', 500)
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update user._id, 
                $inc:boops:1
                
    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.user_groups.helpers
        group_memberships: ->   
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'group'
                member_ids:$in:[user._id]
        user_group_memberships: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'group'
                member_ids: $in:[user._id]

    Template.profile.helpers
        my_unread_log_docs: ->
            Docs.find 
                model:'log'
                read_user_ids:$nin:[Meteor.userId()]
        user_unread_log_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'log'
                read_user_ids:$nin:[user._id]
    Template.profile.helpers
        current_viewing_doc: ->
            if Meteor.user().current_viewing_doc_id
                Docs.findOne Meteor.user().current_viewing_doc_id
        user_rental_docs: ->
            Docs.find
                model:'rental'
                _author_username:Router.current().params.username
        sent_transfer_docs: ->
            Docs.find
                model:'transfer'
                _author_username:Router.current().params.username
        reserved_from_docs: ->
            Docs.find
                model:'order'
                _author_username:Router.current().params.username
        user_order_docs: ->
            Docs.find
                model:'order'
                _author_username:Router.current().params.username

    Template.logout_other_clients_button.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

    Template.logout_button.events
        'click .logout': (e,t)->
            Meteor.call 'insert_log', 'logout', Session.get('current_userid'), ->
                
            Router.go '/login'
            $(e.currentTarget).closest('.grid').transition('slide left', 500)
            
            Meteor.logout()
            $('body').toast({
                title: "logged out"
                # message: 'Please see desk staff for key.'
                class : 'success'
                position:'bottom center'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
                
                
    Template.user_friends.helpers
        user_friended_by_docs: ->
            Meteor.users.find 
                _id:$in:@user_friended_by
                
        friends_of_docs: ->
            Meteor.users.find 
                _id:$in:@user_friended_by
                
            
if Meteor.isServer
    Meteor.publish 'current_viewing_doc', (username)->
        user = Meteor.users.findOne username:username
        if user.current_viewing_doc_id
            Docs.find 
                _id:user.current_viewing_doc_id
    Meteor.publish 'user_favorites', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            _id:$in:user.favorite_ids
        }, 
            fields:
                title:1
                model:1
                image_id:1
    Meteor.publish 'user_groups_member', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'group'
            member_ids:$in:[user._id]
        }
            # fields:
            #     title:1
            #     model:1
            #     image_id:1
            #     member_ids:1
            #     points:1
            #     tags:1
            #     _author:1
            
    Meteor.publish 'user_model_docs', (model,username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:model
            _author_username:username
        }, 
            limit:20
            fields:
                title:1
                model:1
                image_id:1
                _author_id:1
                points:1
                views:1
                _timestamp:-1
                tags:1

    Meteor.publish 'user_deposits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'deposit'
            _author_username:username
    Meteor.methods
        increment_profile_view: (username)->
            target_user = Meteor.users.findOne username:username
            # point_total = 10
            if target_user
                if Meteor.userId()
                    unless Meteor.user().username is username
                        Meteor.users.update target_user._id, 
                            $inc:
                                profile_views:1
                        Meteor.users.update target_user._id, 
                            $inc:
                                profile_views_logged_in:1
                else
                    Meteor.users.update target_user._id, 
                        $inc:
                            profile_views_anon:1
                            profile_views:1
                
                        
                        
        calc_user_points: (username)->
            console.log 'calculating points'
            if username
                user = Meteor.users.findOne username:username
            else 
                user = Meteor.user()
            point_total = 100
            if user
                deposits = 
                    Docs.find 
                        model:'deposit'
                        _author_id:user._id
                for deposit in deposits.fetch()
                    if deposit.amount
                        point_total += deposit.amount

                comment_total = 0
                comments = 
                    Docs.find
                        model:'comment'
                        _author_id:user._id
                for comment in comments.fetch()
                    point_total += -2
                
                
                
                upvote_total = 0
                upvotes = 
                    Docs.find
                        upvoter_ids:$in:[user._id]
                for upvote in upvotes.fetch()
                    # console.log 'upvote', upvote
                    point_total += -1
                    upvote_total += -1
                
                viewed_total = 0
                
                viewed_docs = 
                    Docs.find
                        read_user_ids:$in:[user._id]
                for viewed in viewed_docs.fetch()
                    # console.log 'upvote', upvote
                    point_total += 1
                    viewed_total += 1
                
                
                tip_total = 0
                # console.log 'tip'
                tip_docs = 
                    Docs.find
                        model:'transfer'
                        transfer_type:'tip'
                        _author_id:user._id
                for tip in tip_docs.fetch()
                    # console.log 'tip', tip
                    point_total += -10
                    upvote_total += -10
                    
                downvote_total = 0
                downvotes = 
                    Docs.find
                        downvoter_ids:$in:[user._id]
                for downvote in downvotes.fetch()
                    # console.log 'downvote', downvote
                    point_total += -1
                    downvote_total += -1
                
                console.log 'calc user points', username, point_total
                Meteor.users.update user._id,   
                    $set:
                        points:point_total
                        upvote_total:upvote_total
                        downvote_total:downvote_total
                        tip_total:tip_total
                        tip_count: tip_docs.count()
                        comment_total: comment_total
                        comment_count: tip_docs.count()
                        viewed_total: viewed_total
if Meteor.isClient
    Template.profile.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'order'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
        #     locale: 'auto'
        #     # zipCode: true
        #     token: (token) ->
        #         # product = Docs.findOne Router.current().params.doc_id
        #         user = Docs.findOne username:Router.current().params.username
        #         deposit_amount = parseInt $('.deposit_amount').val()*100
        #         stripe_charge = deposit_amount*100*1.02+20
        #         # calculated_amount = deposit_amount*100
        #         # console.log calculated_amount
        #         charge =
        #             amount: deposit_amount*1.02+20
        #             currency: 'usd'
        #             source: token.id
        #             description: token.description
        #             # receipt_email: token.email
        #         Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
        #             if error then alert error.reason, 'danger'
        #             else
        #                 alert 'payment received', 'success'
        #                 Docs.insert
        #                     model:'deposit'
        #                     deposit_amount:deposit_amount/100
        #                     stripe_charge:stripe_charge
        #                     amount_with_bonus:deposit_amount*1.05/100
        #                     bonus:deposit_amount*.05/100
        #                 Docs.update user._id,
        #                     $inc: credit: deposit_amount*1.05/100
    	# )


    Template.profile.events
        'click .add_points': ->
            amount = parseInt $('.deposit_amount').val()
            # amount_times_100 = parseInt amount*100
            # calculated_amount = amount_times_100*1.02+20
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount
            Docs.insert
                model:'deposit'
                amount: amount
            Meteor.users.update Meteor.userId(),
                $inc: points: amount


    #     'click .initial_withdrawal': ->
    #         withdrawal_amount = parseInt $('.withdrawal_amount').val()
    #         if confirm "initiate withdrawal for #{withdrawal_amount}?"
    #             Docs.insert
    #                 model:'withdrawal'
    #                 amount: withdrawal_amount
    #                 status: 'started'
    #                 complete: false
    #             Docs.update Session.get('current_userid'),
    #                 $inc: credit: -withdrawal_amount

    #     'click .cancel_withdrawal': ->
    #         if confirm "cancel withdrawal for #{@amount}?"
    #             Docs.remove @_id
    #             Docs.update Session.get('current_userid'),
    #                 $inc: credit: @amount



    Template.profile.helpers
        owner_earnings: ->
            Docs.find
                model:'order'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        deposit_docs: ->
            Docs.find {
                model:'deposit'
                # _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        received_orders: ->
            Docs.find {
                model:'order'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_orders: ->
            Docs.find {
                model:'order'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1





    Template.profile.onCreated ->
        # @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'rental'
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'user_deposts', Router.current().params.username, ->
        # @autorun => Meteor.subscribe 'model_docs', 'order', ->
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'


    Template.profile.helpers
        owner_earnings: ->
            Docs.find
                model:'order'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        received_orders: ->
            Docs.find {
                model:'order'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_orders: ->
            Docs.find {
                model:'order'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1


        current_orders: ->
            Docs.find
                model:'order'
                user_username:Router.current().params.username
        upcoming_orders: ->
            Docs.find
                model:'order'
                user_username:Router.current().params.username


if Meteor.isClient
    Router.route '/user/:username/edit', (->
        @layout 'layout'
        @render 'account'
        ), name:'account'

    Template.account.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username

    Template.account.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    Template.user_single_doc_ref_editor.onCreated ->
        @autorun => Meteor.subscribe 'type', @data.model

    Template.user_single_doc_ref_editor.events
        'click .select_choice': ->
            context = Template.currentData()
            current_user = Meteor.users.findOne Router.current().params._id
            Meteor.users.update current_user._id,
                $set: "#{context.key}": @slug

    Template.user_single_doc_ref_editor.helpers
        choices: ->
            Docs.find
                model:@model

        choice_class: ->
            context = Template.parentData()
            current_user = Meteor.users.findOne Router.current().params._id
            if current_user["#{context.key}"] and @slug is current_user["#{context.key}"] then 'grey' else ''



    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            if new_username
                if confirm "Change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/user/#{new_username}")




    Template.password_edit.events
        # 'click .change_password': (e, t) ->
        #     Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
        #         if err
        #             alert err.reason
        #         else
        #             alert 'password changed'
        #             # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            console.log 'new password', new_password
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'set_password', current_user._id, new_password, (err,res)->
                if err 
                    alert err
                else if res
                    alert "password set to #{new_password}."
                    console.lgo 'res', res