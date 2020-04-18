if Meteor.isClient
    Template.user_credit.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
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


    Template.user_credit.events
        'click .add_credits': ->
            amount = parseInt $('.deposit_amount').val()
            amount_times_100 = parseInt amount*100
            calculated_amount = amount_times_100*1.02+20
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount
            Docs.insert
                model:'deposit'
                amount: amount
            Meteor.users.update Meteor.userId(),
                $inc: credit: amount_times_100


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



    Template.user_credit.helpers
        owner_earnings: ->
            Docs.find
                model:'reservation'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        deposits: ->
            Docs.find {
                model:'deposit'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        received_reservations: ->
            Docs.find {
                model:'reservation'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_reservations: ->
            Docs.find {
                model:'reservation'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1





    Template.user_reservations.onCreated ->
        @autorun => Meteor.subscribe 'user_reservations', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'rental'
    Template.user_reservations.helpers
        reservations: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'reservation'
            }, sort:_timestamp:-1


    Template.user_finance.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # product = Docs.findOne Router.current().params.doc_id
                user = Meteor.users.findOne username:Router.current().params.username
                deposit_amount = parseInt $('.deposit_amount').val()*100
                stripe_charge = deposit_amount*100*1.02+20
                # calculated_amount = deposit_amount*100
                # console.log calculated_amount
                charge =
                    amount: deposit_amount*1.02+20
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
                    if error then alert error.reason, 'danger'
                    else
                        alert 'payment received', 'success'
                        Docs.insert
                            model:'deposit'
                            deposit_amount:deposit_amount/100
                            stripe_charge:stripe_charge
                            amount_with_bonus:deposit_amount*1.05/100
                            bonus:deposit_amount*.05/100
                        Meteor.users.update user._id,
                            $inc: credit: deposit_amount*1.05/100
    	)


    Template.user_finance.events
        'click .add_credits': ->
            deposit_amount = parseInt $('.deposit_amount').val()*100
            calculated_amount = deposit_amount*1.02+20
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: calculated_amount

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



    Template.user_finance.helpers
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




    Template.user_rentals.onCreated ->
        @autorun => Meteor.subscribe 'user_rentals', Router.current().params.username
    Template.user_rentals.helpers
        rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'rental'
                _author_username:current_user.username
                # _author_id:current_user._id
                # confirmed:true




    Template.user_handling.onCreated ->
        @autorun => Meteor.subscribe 'user_handling', Router.current().params.username
    Template.user_handling.helpers
        handling_rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find
                model:'rental'
                handler_username:current_user.username
                # _author_id:current_user._id
                # confirmed:true



    Template.user_info.onCreated ->
        @autorun => Meteor.subscribe 'user_stats', Router.current().params.username
    Template.user_info.helpers
        user_stats: ->
            Docs.findOne
                model:'user_stats'
                user_username:Router.current().params.username
    Template.user_info.events
        'click .refresh_user_stats': (e,t)->
            Meteor.call 'refresh_user_stats', Router.current().params.username




    Template.user_dashboard.onCreated ->
        @autorun => Meteor.subscribe 'user_upcoming_reservations', Router.current().params.username
        @autorun => Meteor.subscribe 'user_handling', Router.current().params.username
        @autorun => Meteor.subscribe 'user_current_reservations', Router.current().params.username
    Template.user_dashboard.helpers
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

    Template.rental_small_interest.helpers
        rental_interest_rate: -> @hourly_dollars*.1


    Template.user_dashboard.events
        'click .recalc_wage_stats': (e,t)->
            Meteor.call 'recalc_wage_stats', Router.current().params.username


if Meteor.isServer

    Meteor.publish 'user_rentals', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'rental'
            _author_username:username
            # _author_id: current_user._id

    Meteor.publish 'user_reservations', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'reservation'
            _author_username:username
            # _author_id: current_user._id


    Meteor.publish 'user_stats', (username)->
        Docs.find
            model:'user_stats'
            user_username: username



    Meteor.methods
        refresh_user_stats: (username)->
            user = Meteor.users.findOne username:username
            stats_doc =
                Docs.findOne
                    model:'user_stats'
                    user_username: username
            unless stats_doc
                new_stats_doc_id = Docs.insert
                    model:'user_stats'
                    user_username: username
                stats_doc = Docs.findOne new_stats_doc_id
            service_count = Docs.find(model:'service', _author_username:username).count()
            rental_count = Docs.find(model:'rental', _author_username:username).count()
            owned_rentals =
                Docs.find(
                    model:'rental',
                    owner_username:username
                ).count()
            handled_rentals =
                Docs.find(
                    model:'rental',
                    handler_username:username
                ).count()
            product_count = Docs.find(model:'product', _author_username:username).count()
            reservation_count = Docs.find(model:'reservation', _author_username:username).count()
            comment_count = Docs.find(model:'comment', _author_username:username).count()

            # total_passive_potential =
            owned_rentals =
                Docs.find(
                    model:'rental'
                    owner_username:username
                )

            # total_active_potential =
            handled_rentals =
                Docs.find(
                    model:'rental'
                    handler_username:username
                )

            # total_managed_potential =
            managed_rentals =
                Docs.find(
                    model:'rental'
                    handler_username:username
                    owner_username:username
                )

            total_hourly_credit = 0

            for managed_rental in managed_rentals.fetch()
                # console.log 'adding hourly', managed_rental.hourly_dollars
                total_hourly_credit += managed_rental.hourly_dollars

            # console.log 'total_hourly_credit', total_hourly_credit
            potential_daily_revenue = total_hourly_credit*8*.95
            potential_two_hour_daily_revenue = total_hourly_credit*2*.95

            potential_weekly_revenue = potential_daily_revenue*7
            potential_two_hour_weekly_revenue = potential_two_hour_daily_revenue*7


            Docs.update stats_doc._id,
                $set:
                    service_count: service_count
                    rental_count: rental_count
                    owned_count: owned_rentals.count()
                    handled_count: handled_rentals.count()
                    managed_count: managed_rentals.count()
                    potential_daily_revenue: potential_daily_revenue.toFixed(0)
                    potential_two_hour_daily_revenue: potential_two_hour_daily_revenue.toFixed(0)
                    potential_weekly_revenue: potential_weekly_revenue.toFixed(0)
                    potential_two_hour_weekly_revenue: potential_two_hour_weekly_revenue.toFixed(0)
                    # total_active_potential: total_active_potential
                    # total_passive_potential: total_passive_potential
                    total_hourly_credit: total_hourly_credit
                    product_count: product_count
                    reservation_count: reservation_count
                    comment_count: comment_count
