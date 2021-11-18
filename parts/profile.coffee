if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'



    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_bookmarked_docs', Router.current().params.username
        Meteor.call 'calc_user_points', Router.current().params.username, ->


    Template.profile.helpers
        bookmarked_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                _id: $in: user.bookmark_ids
if Meteor.isServer
    Meteor.publish 'user_bookmarked_docs', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            _id: $in: user.bookmark_ids
        
if Meteor.isClient
    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_posts', Router.current().params.username, ->

    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000

    Template.profile.events
        'click .recalc_wage_stats': (e,t)->
            Meteor.call 'recalc_wage_stats', Router.current().params.username, ->


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.profile.helpers
        user_post_docs: ->
            Docs.find
                model:'post'
                _author_username:Router.current().params.username
        user_from_username_param: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

    Template.logout_other_clients_button.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

    Template.logout_button.events
        'click .logout': (e,t)->
            Meteor.call 'insert_log', 'logout', Meteor.userId(), ->
                
            Router.go '/login'
            $(e.currentTarget).closest('.grid').transition('slide left', 500)
            
            Meteor.logout()
            $('body').toast({
                title: "logged out"
                # message: 'Please see desk staff for key.'
                class : 'success'
                # position:'top center'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
            
if Meteor.isServer
    Meteor.publish 'user_posts', (username)->
        Docs.find
            model:'post'
            _author_username:username
    
    Meteor.methods
        calc_user_points: (username)->
            user = Meteor.users.findOne username:username
            point_total = 10
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
            console.log 'calc user points', username, point_total
            Meteor.users.update user._id,   
                $set:points:point_total
    
            
if Meteor.isClient
    Template.profile.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
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
        #         user = Meteor.users.findOne username:Router.current().params.username
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
        #                 Meteor.users.update user._id,
        #                     $inc: credit: deposit_amount*1.05/100
    	# )


    # Template.user_credit.events
    #     'click .add_credits': ->
    #         amount = parseInt $('.deposit_amount').val()
    #         amount_times_100 = parseInt amount*100
    #         calculated_amount = amount_times_100*1.02+20
    #         # Template.instance().checkout.open
    #         #     name: 'credit deposit'
    #         #     # email:Meteor.user().emails[0].address
    #         #     description: 'gold run'
    #         #     amount: calculated_amount
    #         Docs.insert
    #             model:'deposit'
    #             amount: amount
    #         Meteor.users.update Meteor.userId(),
    #             $inc: credit: amount_times_100


    #     'click .initial_withdrawal': ->
    #         withdrawal_amount = parseInt $('.withdrawal_amount').val()
    #         if confirm "initiate withdrawal for #{withdrawal_amount}?"
    #             Docs.insert
    #                 model:'withdrawal'
    #                 amount: withdrawal_amount
    #                 status: 'started'
    #                 complete: false
    #             Meteor.users.update Meteor.userId(),
    #                 $inc: credit: -withdrawal_amount

    #     'click .cancel_withdrawal': ->
    #         if confirm "cancel withdrawal for #{@amount}?"
    #             Docs.remove @_id
    #             Meteor.users.update Meteor.userId(),
    #                 $inc: credit: @amount



    Template.profile.helpers
        owner_earnings: ->
            Docs.find
                model:'reservation'
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
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        received_reservations: ->
            Docs.find {
                model:'reservation'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_reservations: ->
            Docs.find {
                model:'reservation'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1





    Template.profile.onCreated ->
        @autorun => Meteor.subscribe 'user_reservations', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'rental'
    Template.profile.helpers
        reservations: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'reservation'
            }, sort:_timestamp:-1


    Template.profile.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'


    Template.profile.events
        'click .add_credits': ->
            # deposit_amount = parseInt $('.deposit_amount').val()*100
            deposit_amount = parseInt $('.deposit_amount').val()
            calculated_amount = deposit_amount*1.02+20
            note = prompt 'notes?' 
            new_id = 
                Docs.insert 
                    model:'deposit'
                    amount:deposit_amount
                    note:note
            
            # is_number = typeof(Meteor.user().points) is 'number'
            is_number = isNaN(Meteor.user().points)
            console.log typeof(Meteor.user().points)
            unless is_number
                Meteor.users.update Meteor.userId(),
                    $inc:
                        points:deposit_amount
            else                    
                Meteor.users.update Meteor.userId(),
                    $set: points: deposit_amount
            $('.deposit_amount').val('')

        'click .initial_withdrawal': ->
            withdrawal_amount = parseInt $('.withdrawal_amount').val()
            if confirm "initiate withdrawal for #{withdrawal_amount}?"
                Docs.insert
                    model:'withdrawal'
                    amount: withdrawal_amount
                    status: 'started'
                    complete: false
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -withdrawal_amount

        'click .cancel_withdrawal': ->
            if confirm "cancel withdrawal for #{@amount}?"
                Docs.remove @_id
                Meteor.users.update Meteor.userId(),
                    $inc: credit: @amount



    Template.profile.helpers
        owner_earnings: ->
            Docs.find
                model:'reservation'
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
        received_reservations: ->
            Docs.find {
                model:'reservation'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_reservations: ->
            Docs.find {
                model:'reservation'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1





    Template.profile.onCreated ->
        @autorun => Meteor.subscribe 'user_upcoming_reservations', Router.current().params.username
        @autorun => Meteor.subscribe 'user_handling', Router.current().params.username
        @autorun => Meteor.subscribe 'user_current_reservations', Router.current().params.username
    Template.profile.helpers
        current_reservations: ->
            Docs.find
                model:'reservation'
                user_username:Router.current().params.username
        upcoming_reservations: ->
            Docs.find
                model:'reservation'
                user_username:Router.current().params.username
        current_handling_rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'rental'
                handler_username:current_user.username
        current_interest_rate: ->
            interest_rate = 0
            if Meteor.user().handling_active
                current_user = Meteor.users.findOne username:Router.current().params.username
                handling_rentals = Docs.find(
                    model:'rental'
                    handler_username:current_user.username
                ).fetch()
                for handling in handling_rentals
                    interest_rate += handling.hourly_dollars*.1
            interest_rate.toFixed(2)


            