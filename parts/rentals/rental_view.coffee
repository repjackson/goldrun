if Meteor.isClient
    Router.route '/rental/:doc_id/view', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'


    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Session.set 'view_mode', 'cards'

    #     'click .calculate_diff': ->
    #         product = Template.parentData()
    #         console.log product
    #         moment_a = moment @start_datetime
    #         moment_b = moment @end_datetime
    #         reservation_hours = -1*moment_a.diff(moment_b,'hours')
    #         reservation_days = -1*moment_a.diff(moment_b,'days')
    #         hourly_reservation_price = reservation_hours*product.hourly_rate
    #         daily_reservation_price = reservation_days*product.daily_rate
    #         Docs.update @_id,
    #             $set:
    #                 reservation_hours:reservation_hours
    #                 reservation_days:reservation_days
    #                 hourly_reservation_price:hourly_reservation_price
    #                 daily_reservation_price:daily_reservation_price

    Template.rental_stats.events
        'click .refresh_rental_stats': ->
            Meteor.call 'refresh_rental_stats', @_id


    Template.reserve_button.events
        'click .new_reservation': (e,t)->
            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: @_id
            Router.go "/reservation/#{new_reservation_id}/edit"


    Template.reservation_segment.events
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
    Meteor.publish 'rental_reservations_by_id', (rental_id)->
        Docs.find
            model:'reservation'
            rental_id: rental_id

    Meteor.publish 'rentals', (product_id)->
        Docs.find
            model:'rental'
            product_id:product_id

    Meteor.publish 'reservation_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
        # for reservation in reservations
            # console.log 'id', reservation._id
            # console.log reservation.paid_amount
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'reservation_slot', (moment_ob)->
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
        #     model:'reservation_slot'


    Meteor.methods
        refresh_rental_stats: (rental_id)->
            rental = Docs.findOne rental_id
            # console.log rental
            reservations = Docs.find({model:'reservation', rental_id:rental_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_rental_hours = 0
            average_rental_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_rental_hours += parseFloat(res.hour_duration)

            average_rental_cost = total_earnings/reservation_count
            average_rental_duration = total_rental_hours/reservation_count

            Docs.update rental_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_rental_hours: total_rental_hours.toFixed(0)
                    average_rental_cost: average_rental_cost.toFixed(0)
                    average_rental_duration: average_rental_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header rental ranking #reservations
            # .ui.small.header rental ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg rental time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
