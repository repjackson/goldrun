if Meteor.isClient
    Router.route '/admin', -> @render 'admin'
    Router.route '/global_stats', -> @render 'global_stats'

    Template.global_stats.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'global_stats'

    Template.global_stats.events
        'click .refresh_global_stats': ->
            Meteor.call 'refresh_global_stats', ->

    Template.global_stats.helpers
        global_stats: ->
            found = Docs.findOne {
                model:'global_stats'
            }, sort: _timestamp: -1
            console.log found
            found




    Template.admin.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        @autorun => Meteor.subscribe 'model_docs', 'payment'
    Template.admin.helpers
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
            }, sort: _timestamp: -1

        payments: ->
            Docs.find {
                model:'payment'
            }, sort: _timestamp: -1

    Template.call_method.events
        'click .call_method': ->
            Meteor.call @name



    Template.message_segment.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data.parent_id




if Meteor.isServer
    Meteor.methods
        calculate_model_doc_count: ->
            model_cursor = Docs.find(model:'model')
            console.log model_cursor.count()
            for model in model_cursor.fetch()
                model_docs_count =
                    Docs.find(
                        model:model.slug
                    ).count()
                console.log model.slug, model_docs_count



        refresh_global_stats: ->
            global_stat_doc = Docs.findOne(model:'global_stats')
            unless global_stat_doc
                new_id = Docs.insert
                    model:'global_stats'
                global_stat_doc = Docs.findOne(model:'global_stats')
            total_count = Docs.find().count()

            reservations = Docs.find(
                model:'reservation'
                ).fetch()
            total_reservation_revenue = 0
            for res in reservations
                if res.cost
                    total_reservation_revenue += parseInt(res.cost)

            total_owner_revenue = 0
            for res in reservations
                if res.owner_payout
                    total_owner_revenue += parseInt(res.owner_payout)

            total_handler_revenue = 0
            for res in reservations
                if res.handler_payout
                    total_handler_revenue += parseInt(res.handler_payout)

            total_tax_revenue = 0
            for res in reservations
                if res.taxes_payout
                    total_tax_revenue += parseInt(res.taxes_payout)

            payments = Docs.find(
                model:'payment'
                ).fetch()
            total_payment_amount = 0
            for payment in payments
                if payment.amount
                    total_payment_amount += parseInt(payment.amount)
                # daily_rentals += item.rental_amount
                # if item.handled
                #     handled_rentals += item.rental_amount
                # totaled_daily_revenue += item.calculated_daily_revenue

            total_members_count = Meteor.users.find(roles:$in:['member']).count()
            total_owners_count = Meteor.users.find(owner:true).count()
            total_handlers_count = Meteor.users.find(handler:true).count()

            current_active_handlers = Meteor.users.find(handling_active:true).count()

            payment_count = Docs.find(model:'payment').count()
            rental_count = Docs.find(model:'rental').count()

            withdrawel_count = Docs.find(model:'withdrawel').count()
            reservation_count = Docs.find(model:'reservation').count()
            Docs.update global_stat_doc._id,
                $set:
                    total_count:total_count
                    total_owners_count:total_owners_count
                    total_handlers_count:total_handlers_count
                    current_active_handlers:current_active_handlers
                    total_handler_revenue:total_handler_revenue
                    total_owner_revenue:total_owner_revenue
                    total_tax_revenue:total_tax_revenue
                    rental_count:rental_count
                    total_members_count:total_members_count
                    payment_count:payment_count
                    total_payment_amount:total_payment_amount
                    withdrawel_count:withdrawel_count
                    total_reservation_revenue:total_reservation_revenue
                    reservation_count:reservation_count
            console.log Docs.findOne global_stat_doc._id
