if Meteor.isClient
    Router.route '/reservation/:doc_id/edit', (->
        @render 'reservation_edit'
        ), name:'reservation_edit'

    Template.reservation_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'owner_by_res_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'handler_by_res_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'user_by_username', 'deb_sclar'

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
                # deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))*100
                # stripe_charge = parseInt(deposit_amount*1.02+20)
                # calculated_amount = deposit_amount*100
                # console.log calculated_amount
                deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
                stripe_charge = parseFloat(deposit_amount)*100
                console.log 'deposit_amount', deposit_amount
                console.log 'stripe charge', stripe_charge

                charge =
                    amount: stripe_charge
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, Meteor.user(), (error, response)=>
                    if error then alert error.reason, 'danger'
                    else
                        # alert 'payment received', 'success'
                        Docs.insert
                            model:'payment'
                            deposit_amount:deposit_amount
                            stripe_charge:stripe_charge
                            amount_with_bonus:deposit_amount*1.05/100
                            bonus:deposit_amount*.05/100
                        Meteor.users.update Meteor.userId(),
                            $inc: credit: deposit_amount*1.05
    	)

    Template.key_value_edit.events
        'click .set_key_value': ->
            parent = Template.parentData()
            Docs.update parent._id,
                $set: "#{@key}": @value

    Template.key_value_edit.helpers
        set_key_value_class: ->
            parent = Template.parentData()
            # console.log parent
            if parent["#{@key}"] is @value then 'active' else ''


    Template.reservation_edit.helpers
        rental: -> Docs.findOne model:'rental'
        now_button_class: -> if @now then 'active' else ''
        sel_hr_class: -> if @duration_type is 'hour' then 'active' else ''
        sel_day_class: -> if @duration_type is 'day' then 'active' else ''
        sel_month_class: -> if @duration_type is 'month' then 'active' else ''
        is_month: -> @duration_type is 'month'
        is_day: -> @duration_type is 'day'
        is_hour: -> @duration_type is 'hour'

        is_paying: -> Session.get 'paying'

        can_buy: ->
            Meteor.user().credit > @total_cost

        need_credit: ->
            Meteor.user().credit < @total_cost

        need_approval: ->
            @friends_only and Meteor.userId() not in @author.friend_ids

        submit_button_class: ->
            if @start_datetime and @end_datetime then '' else 'disabled'

        member_balance_after_reservation: ->
            rental = Docs.findOne @rental_id
            if rental
                current_balance = Meteor.user().credit
                (current_balance-@total_cost).toFixed(2)

        # diff: -> moment(@end_datetime).diff(moment(@start_datetime),'hours',true)

    Template.reservation_edit.events
        'click .add_credit': ->
            deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
            stripe_charge = parseFloat(deposit_amount)*100*1.02+20
            # stripe_charge = parseInt(deposit_amount*1.02+20)

            # if confirm "add #{deposit_amount} credit?"
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: stripe_charge

        'click .trigger_recalc': ->
            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id
            $('.handler')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })
            $('.result')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })

        'change .res_start': (e,t)->
            val = t.$('.res_start').val()
            Docs.update @_id,
                $set:start_datetime:val

        'change .res_end': (e,t)->
            val = t.$('.res_end').val()
            Docs.update @_id,
                $set:end_datetime:val

            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id


        'click .select_day': ->
            Docs.update @_id,
                $set: duration_type: 'day'
        'click .select_hour': ->
            Docs.update @_id,
                $set: duration_type: 'hour'
        'click .select_month': ->
            Docs.update @_id,
                $set: duration_type: 'month'

        'click .set_1_hr': ->
            Docs.update @_id,
                $set:
                    hour_duration: 1
                    end_datetime: moment(@start_datetime).add(1,'hour').format("YYYY-MM-DD[T]HH:mm")
            rental = Docs.findOne @rental_id
            hour_duration = 1
            cost = parseFloat hour_duration*rental.hourly_dollars.toFixed(2)
            # console.log diff
            taxes_payout = parseFloat((cost*.05)).toFixed(2)
            owner_payout = parseFloat((cost*.5)).toFixed(2)
            handler_payout = parseFloat((cost*.45)).toFixed(2)
            Docs.update @_id,
                $set:
                    cost: cost
                    taxes_payout: taxes_payout
                    owner_payout: owner_payout
                    handler_payout: handler_payout

        'change .other_hour': ->
            $('.result_column .header')
              .transition({
                animation : 'pulse',
                duration  : 200,
                interval  : 50
              })

            val = parseInt $('.other_hour').val()
            Docs.update @_id,
                $set:
                    hour_duration: val
                    end_datetime: moment(@start_datetime).add(val,'hour').format("YYYY-MM-DD[T]HH:mm")

            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id

            # rental = Docs.findOne @rental_id
            # hour_duration = val
            # cost = parseFloat hour_duration*rental.hourly_dollars.toFixed(2)
            # # console.log diff
            # taxes_payout = parseFloat((cost*.05)).toFixed(2)
            # owner_payout = parseFloat((cost*.5)).toFixed(2)
            # handler_payout = parseFloat((cost*.45)).toFixed(2)
            # Docs.update @_id,
            #     $set:
            #         cost: cost
            #         taxes_payout: taxes_payout
            #         owner_payout: owner_payout
            #         handler_payout: handler_payout
            # $('.result_column').transition('glow',500)


        'click .reserve_now': ->
            if @now
                Docs.update @_id,
                    $set:
                        now: false
            else
                now = Date.now()
                Docs.update @_id,
                    $set:
                        now: true
                        start_datetime: moment(now).format("YYYY-MM-DD[T]HH:mm")
                        start_timestamp: now

        'click .submit_reservation': ->
            $('.ui.modal')
            .modal({
                closable: true
                onDeny: ()->
                onApprove: ()=>
                    # Session.set 'paying', true
                    rental = Docs.findOne @rental_id
                    # console.log @
                    Docs.update @_id,
                        $set:
                            submitted:true
                            submitted_timestamp:Date.now()
                    Session.set 'paying', false
                    Meteor.call 'pay_for_reservation', @_id, =>
                        Session.set 'paying', true
                        Router.go "/reservation/#{@_id}/view"
            }).modal('show')

        'click .unsubmit': ->
            Docs.update @_id,
                $set:
                    submitted:false
                    unsubmitted_timestamp:Date.now()
            Docs.insert
                model:'log_event'
                parent_id:Router.current().params.doc_id
                log_type:'reservation_unsubmission'
                text:"reservation unsubmitted by #{Meteor.user().username}"
            # Router.go "/reservation/#{@_id}/view"

        'click .cancel_reservation': ->
            if confirm 'delete reservation?'
                Docs.remove @_id
                Router.go "/rental/#{@rental_id}/view"


        #     rental = Docs.findOne @rental_id
        #     # console.log @
        #     Docs.update @_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #     Meteor.call 'pay_for_reservation', @_id, =>
        #         Router.go "/reservation/#{@_id}/view"



if Meteor.isServer
    Meteor.methods
        recalc_reservation_cost: (res_id)->
            res = Docs.findOne res_id
            # console.log res
            rental = Docs.findOne res.rental_id
            hour_duration = moment(res.end_datetime).diff(moment(res.start_datetime),'hours',true)
            cost = parseFloat hour_duration*rental.hourly_dollars
            total_cost = cost
            taxes_payout = parseFloat((cost*.05))
            owner_payout = parseFloat((cost*.5))
            handler_payout = parseFloat((cost*.45))
            if rental.security_deposit_required
                total_cost += rental.security_deposit_amount
            if res.res_start_dropoff_selected
                total_cost += rental.res_start_dropoff_fee
                handler_payout += rental.res_start_dropoff_fee
            if res.res_end_pickup_selected
                total_cost += rental.res_end_pickup_fee
                handler_payout += rental.res_end_pickup_fee
            # console.log diff
            Docs.update res._id,
                $set:
                    hour_duration: hour_duration.toFixed(2)
                    cost: cost.toFixed(2)
                    total_cost: total_cost.toFixed(2)
                    taxes_payout: taxes_payout.toFixed(2)
                    owner_payout: owner_payout.toFixed(2)
                    handler_payout: handler_payout.toFixed(2)

        pay_for_reservation: (res_id)->
            res = Docs.findOne res_id
            # console.log res
            rental = Docs.findOne res.rental_id

            Meteor.call 'send_payment', Meteor.user().username, rental.owner_username, res.owner_payout, 'owner_payment', res_id
            Docs.insert
                model:'log_event'
                log_type: 'payment'

            Meteor.call 'send_payment', Meteor.user().username, rental.handler_username, res.handler_payout, 'handler_payment', res_id
            Meteor.call 'send_payment', Meteor.user().username, 'dev', res.taxes_payout, 'taxes_payment', res_id

            Docs.insert
                model:'log_event'
                parent_id:res_id
                res_id: res_id
                rental_id: res.rental_id
                log_type:'reservation_submission'
                text:"reservation submitted by #{Meteor.user().username}"

        send_payment: (from_username, to_username, amount, reason, reservation_id)->
            console.log 'sending payment from', from_username, 'to', to_username, 'for', amount, reason, reservation_id
            res = reservation_id
            sender = Meteor.users.findOne username:from_username
            recipient = Meteor.users.findOne username:to_username


            console.log 'sender', sender._id
            console.log 'recipient', recipient._id
            console.log typeof amount
            #
            amount  = parseFloat amount

            Meteor.users.update sender._id,
                $inc: credit: -amount

            Meteor.users.update recipient._id,
                $inc: credit: amount

            Docs.insert
                model:'payment'
                sender_username: from_username
                sender_id: sender._id
                recipient_username: to_username
                recipient_id: recipient._id
                amount: amount
                reservation_id: reservation_id
                rental_id: res.rental_id
                reason:reason
            Docs.insert
                model:'log_event'
                log_type: 'payment'
                sender_username: from_username
                recipient_username: to_username
                amount: amount
                recipient_id: recipient._id
                text:"#{from_username} paid #{to_username} #{amount} for #{reason}."
                sender_id: sender._id
            return
