if Meteor.isClient
    Template.rental_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->


if Meteor.isClient
    Template.rental_big_card.onCreated ->
        @autorun => @subscribe 'rental_orders',@data._id, ->
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => @subscribe 'rental_orders',Router.current().params.doc_id, ->
    Template.rental_view.onRendered ->
        Docs.update Router.current().params.doc_id, 
            $inc:views:1
    
    Template.rental_view.helpers
        future_order_docs: ->
            Docs.find 
                model:'order'
                rental_id:Router.current().params.doc_id
                
                
                
    Template.rental_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
        
    Template.rental_view.events
        'click .new_order': (e,t)->
            rental = Docs.findOne Router.current().params.doc_id
            new_order_id = Docs.insert
                model:'order'
                rental_id: @_id
                rental_id:rental._id
                rental_title:rental.title
                rental_image_id:rental.image_id
                rental_image_link:rental.image_link
                rental_daily_rate:rental.daily_rate
            Router.go "/order/#{new_order_id}/edit"
            
        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'
            
        'click .cancel_order': ->
            console.log 'hi'
            Swal.fire({
                title: "cancel?"
                # text: "this will charge you $5"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                )

    Template.quickbuy.helpers
        button_class: ->
            tech_form = moment().add(@day_diff, 'days').format('YYYY-MM-DD')
            found_order = 
                Docs.findOne
                    model:'order'
                    order_date:tech_form
            if found_order
                'disabled'
            else 
                'large'
                    
                    
                    
        human_form: ->
            moment().add(@day_diff, 'days').format('ddd, MMM Do')
        from_form: ->
            moment().add(@day_diff, 'days').fromNow()
            
    Template.quickbuy.events
        'click .buy': ->
            console.log @
            context = Template.parentData()
            human_form = moment().add(@day_diff, 'days').format('dddd, MMM Do')
            tech_form = moment().add(@day_diff, 'days').format('YYYY-MM-DD')
            Swal.fire({
                title: "quickbuy #{human_form}?"
                # text: "this will charge you $5"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    rental = Docs.findOne context._id
                    new_order_id = Docs.insert
                        model:'order'
                        rental_id: rental._id
                        order_date: tech_form
                        _seller_username:rental._author_username
                        rental_id:rental._id
                        rental_title:rental.title
                        rental_image_id:rental.image_id
                        rental_image_link:rental.image_link
                        rental_daily_rate:rental.daily_rate
                    Swal.fire(
                        "reserved for #{human_form}",
                        ''
                        'success'
                    )
            )

            

if Meteor.isServer
    Meteor.publish 'user_rentals', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'rental'
            _author_id: user._id
            
    Meteor.publish 'rental_orders', (doc_id)->
        rental = Docs.findOne doc_id
        Docs.find
            model:'order'
            rental_id:rental._id
            
            
            
            
if Meteor.isClient
    Template.rental_stats.events
        'click .refresh_rental_stats': ->
            Meteor.call 'refresh_rental_stats', @_id




    Template.order_segment.events
        'click .calc_res_numbers': ->
            start_date = moment(@start_timestamp).date()
            start_month = moment(@start_timestamp).month()
            start_minute = moment(@start_timestamp).minute()
            start_hour = moment(@start_timestamp).hour()
            Docs.update @_id,
                $set:
                    start_date:start_date
                    start_month:start_month
                    start_hour:start_hour
                    start_minute:start_minute



if Meteor.isServer
    Meteor.publish 'rental_orders_by_id', (rental_id)->
        Docs.find
            model:'order'
            rental_id: rental_id


    Meteor.publish 'order_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        orders = Docs.find(model:'order',product_id:product_id).fetch()
        # for order in orders
            # console.log 'id', order._id
            # console.log order.paid_amount
        Docs.find
            model:'order'
            product_id:product_id

    Meteor.publish 'order_slot', (moment_ob)->
        rentals_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            rentals.return.push date_string
        rentals_return

        # data.long_form
        # Docs.find
        #     model:'order_slot'


    Meteor.methods
        refresh_rental_stats: (rental_id)->
            rental = Docs.findOne rental_id
            # console.log rental
            orders = Docs.find({model:'order', rental_id:rental_id})
            order_count = orders.count()
            total_earnings = 0
            total_rental_hours = 0
            average_rental_duration = 0

            # shortest_order =
            # longest_order =

            for res in orders.fetch()
                total_earnings += parseFloat(res.cost)
                total_rental_hours += parseFloat(res.hour_duration)

            average_rental_cost = total_earnings/order_count
            average_rental_duration = total_rental_hours/order_count

            Docs.update rental_id,
                $set:
                    order_count: order_count
                    total_earnings: total_earnings.toFixed(0)
                    total_rental_hours: total_rental_hours.toFixed(0)
                    average_rental_cost: average_rental_cost.toFixed(0)
                    average_rental_duration: average_rental_duration.toFixed(0)