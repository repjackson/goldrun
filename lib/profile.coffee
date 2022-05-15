if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'profile'
    Router.route '/user/:username/social', (->
        @layout 'profile_layout'
        @render 'user_social'
        ), name:'user_social'
    Router.route '/user/:username/about', (->
        @layout 'profile_layout'
        @render 'user_about'
        ), name:'user_about'
    Router.route '/user/:username/orders', (->
        @layout 'profile_layout'
        @render 'user_orders'
        ), name:'user_orders'
    Router.route '/user/:username/groups', (->
        @layout 'profile_layout'
        @render 'user_groups'
        ), name:'user_groups'
    Router.route '/user/:username/points', (->
        @layout 'profile_layout'
        @render 'user_points'
        ), name:'user_points'
    Router.route '/user/:username/rentals', (->
        @layout 'profile_layout'
        @render 'user_rentals'
        ), name:'user_rentals'
    Router.route '/user/:username/membership', (->
        @layout 'profile_layout'
        @render 'user_membership'
        ), name:'user_membership'
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/user/:username/products', (->
        @layout 'profile_layout'
        @render 'user_products'
        ), name:'user_products'
    Router.route '/user/:username/services', (->
        @layout 'profile_layout'
        @render 'user_services'
        ), name:'user_services'
    Router.route '/user/:username/posts', (->
        @layout 'profile_layout'
        @render 'user_posts'
        ), name:'user_posts'
    Router.route '/user/:username/comments', (->
        @layout 'profile_layout'
        @render 'user_comments'
        ), name:'user_comments'
    Router.route '/user/:username/events', (->
        @layout 'profile_layout'
        @render 'user_events'
        ), name:'user_events'
    Router.route '/user/:username/mail', (->
        @layout 'profile_layout'
        @render 'user_mail'
        ), name:'user_mail'



    Template.profile_layout.onCreated ->
        Meteor.call 'calc_user_points', Router.current().params.username, ->
    Template.profile_layout.onRendered ->
        Meteor.call 'increment_profile_view', Router.current().params.username, ->


        
if Meteor.isClient
    Template.profile_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_deposits', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_rentals', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_orders', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_groups_member', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_groups_owner', Router.current().params.username, ->
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
        
    Template.user_posts.events 
        'click .add_user_post': ->
            user = Meteor.users.findOne username:Router.current().params.username
            new_id = 
                Docs.insert 
                    model:'post'
                    _author_id:user._id
                    _author_username:user.username
            Router.go "/post/#{new_id}/edit"
        
    Template.profile_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000

    Template.profile_layout.events
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
                    recipient_id: user._id
            Router.go "/transfer/#{new_id}/edit"
            
            
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
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'group'
                _id:$in:current_user.group_memberships

    Template.profile_layout.helpers
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
    Meteor.publish 'user_groups_member', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'group'
            _id:$in:user.group_memberships
    Meteor.publish 'user_model_docs', (model,username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:model
            _author_username:username
    Meteor.publish 'user_deposits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'deposit'
            _author_username:username
    Meteor.methods
        increment_profile_view: (username)->
            user = Meteor.users.findOne username:username
            # point_total = 10
            if user
                Meteor.users.update user._id, 
                    $inc:
                        profile_views:1
            if Meteor.userId()
                Meteor.users.update user._id, 
                    $inc:
                        profile_views_logged_in:1
            else
                Meteor.users.update user._id, 
                    $inc:
                        profile_views_anon:1
                
                        
                        
        calc_user_points: (username)->
            console.log 'calculating points'
            if username
                user = Docs.findOne username:username
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

                orders = 
                    Docs.find
                        model:'order'
                        _author_id:user._id
                for order in orders.fetch()
                    if order.total_amount
                        point_total += order.total_amount
                
                upvote_total = 0
                upvotes = 
                    Docs.find
                        upvoter_ids:$in:[user._id]
                for upvote in upvotes.fetch()
                    point_total += -1
                    upvote_total += -1
                
                
                tip_total = 0
                tip_docs = 
                    Docs.find
                        model:'tip'
                        _author_id:user._id
                for tip in tip_docs.fetch()
                    point_total += -10
                    upvote_total += -10
                    
                downvote_total = 0
                downvotes = 
                    Docs.find
                        downvoter_ids:$in:[user._id]
                for downvote in downvotes.fetch()
                    point_total += -1
                    downvote_total += -1
                
                console.log 'calc user points', username, point_total
                Docs.update user._id,   
                    $set:
                        points:point_total
                        upvote_total:upvote_total
                        downvote_total:downvote_total
                        tip_total:tip_total
                        tip_count: tip_docs.count()
if Meteor.isClient
    Template.profile_layout.onCreated ->
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


    Template.profile_layout.events
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



    Template.profile_layout.helpers
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





    Template.profile_layout.onCreated ->
        @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'rental'
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'user_deposts', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'model_docs', 'order', ->
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'


    Template.profile_layout.helpers
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


            