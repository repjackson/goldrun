if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'rentals'
        ), name:'home'


    Template.rental_reservations.onCreated ->
        @autorun => @subscribe 'rental_reservations',Router.current().params.doc_id, ->
    Template.rental_reservations.helpers
        rental_reservation_docs: ->
            Docs.find 
                model:'reservation'
                rental_id:Router.current().params.doc_id




if Meteor.isClient
    Router.route '/rental/:doc_id/', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'
    Router.route '/reservation/:doc_id/checkout', (->
        @layout 'layout'
        @render 'reservation_edit'
        ), name:'reservation_checkout'


    
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_edit.helpers
        upcoming_days: ->
            upcoming_days = []
            now = new Date()
            today = moment(now).format('dddd MMM Do')
            # upcoming_days.push today
            day_number = 0
            # for day in [0..3]
            for day in [0..1]
                day_number++
                moment_ob = moment(now).add(day, 'days')
                long_form = moment(now).add(day, 'days').format('dddd MMM Do')
                upcoming_days.push {moment_ob:moment_ob,long_form:long_form}
            upcoming_days
    
    
    Template.rental_edit.events
        'click .delete_rental_item': ->
            if confirm 'delete rental?'
                Docs.remove @_id
                Router.go "/"
                
      'click .refresh_gps': ->
            navigator.geolocation.getCurrentPosition (position) =>
                console.log 'navigator position', position
                Session.set('current_lat', position.coords.latitude)
                Session.set('current_long', position.coords.longitude)
                
                console.log 'saving long', position.coords.longitude
                console.log 'saving lat', position.coords.latitude
            
                pos = Geolocation.currentLocation()
                Docs.update Router.current().params.doc_id, 
                    $set:
                        lat:position.coords.latitude
                        long:position.coords.longitude

    Template.rental_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
    Template.rental_view.events
        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'cart_item'
        #         rental_id:@_id
        #     $('body').toast({
        #         title: "#{@title} added to cart."
        #         # message: 'Please see desk staff for key.'
        #         class : 'green'
        #         # position:'top center'
        #         # className:
        #         #     toast: 'ui massive message'
        #         displayTime: 5000
        #         transition:
        #           showMethod   : 'zoom',
        #           showDuration : 250,
        #           hideMethod   : 'fade',
        #           hideDuration : 250
        #         })

        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'reservation'
        #         rental_id:@_id
        #     $('body').toast({
        #         title: "#{@title} added to cart."
        #         # message: 'Please see desk staff for key.'
        #         class : 'green'
        #         # position:'top center'
        #         # className:
        #         #     toast: 'ui massive message'
        #         displayTime: 5000
        #         transition:
        #           showMethod   : 'zoom',
        #           showDuration : 250,
        #           hideMethod   : 'fade',
        #           hideDuration : 250
        #         })
        'click .new_reservation': (e,t)->
            rental = Docs.findOne Router.current().params.doc_id
            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: @_id
                rental_id:rental._id
                rental_title:rental.title
                rental_image_id:rental.image_id
                rental_daily_rate:rental.daily_rate
            Router.go "/reservation/#{new_reservation_id}/edit"
            
            

        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'

        # 'click .buy_rental': (e,t)->
        #     rental = Docs.findOne Router.current().params.doc_id
        #     new_reservation_id = 
        #         Docs.insert 
        #             model:'reservation'
        #             reservation_type:'rental'
        #             rental_id:rental._id
        #             rental_title:rental.title
        #             rental_price:rental.dollar_price
        #             rental_image_id:rental.image_id
        #             rental_point_price:rental.point_price
        #             rental_dollar_price:rental.dollar_price
        #     Router.go "/reservation/#{new_reservation_id}/checkout"
            
if Meteor.isClient
    Template.user_rentals.onCreated ->
        @autorun => Meteor.subscribe 'user_rentals', Router.current().params.username
    Template.user_rentals.events
        'click .add_rental': ->
            new_id =
                Docs.insert
                    model:'rental'
            Router.go "/rental/#{new_id}/edit"

    Template.user_rentals.helpers
        rentals: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'rental'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_rentals', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'rental'
            _author_id: user._id
            
    Meteor.publish 'rental_reservations', (doc_id)->
        rental = Docs.findOne doc_id
        Docs.find
            model:'reservation'
            rental_id:rental._id
            
            
            
            
if Meteor.isClient
    Template.rental_stats.events
        'click .refresh_rental_stats': ->
            Meteor.call 'refresh_rental_stats', @_id




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