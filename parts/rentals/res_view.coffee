if Meteor.isClient
    Router.route '/reservation/:doc_id/', (->
        @render 'reservation_view'
        ), name:'reservation_view'
    Template.reservation_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id


    # Template.rental_view_reservations.onCreated ->
    #     @autorun -> Meteor.subscribe 'rental_reservations',
    #         Template.currentData()
    #         Session.get 'res_view_mode'
    #         Session.get 'date_filter'
    # Template.rental_view_reservations.helpers
    #     reservations: ->
    #         Docs.find {
    #             model:'reservation'
    #         }, sort: start_datetime:-1
    #     view_res_cards: -> Session.equals 'res_view_mode', 'cards'
    #     view_res_segments: -> Session.equals 'res_view_mode', 'segments'
    # Template.rental_view_reservations.events
    #     'click .set_card_view': -> Session.set 'res_view_mode', 'cards'
    #     'click .set_segment_view': -> Session.set 'res_view_mode', 'segments'

    Template.reservation_events.onCreated ->
        @autorun => Meteor.subscribe 'log_events', Router.current().params.doc_id
    Template.reservation_events.helpers
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id

    # Template.rental_stats.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1000

    # Template.rental_view_reservations.onRendered ->
    #     Session.setDefault 'view_mode', 'cards'


    # Template.set_date_filter.events
    #     'click .set_date_filter': -> Session.set 'date_filter', @key
    #
    # Template.set_date_filter.helpers
    #     date_filter_class: ->
    #         if Session.equals('date_filter', @key) then 'active' else ''


if Meteor.isServer
    Meteor.publish 'rental_reservations', (rental, view_mode, date_filter)->
        console.log view_mode
        console.log date_filter
        Docs.find
            model:'reservation'
            rental_id: rental._id


    Meteor.publish 'log_events', (parent_id)->
        Docs.find
            model:'log_event'
            parent_id:parent_id

    Meteor.publish 'reservations_by_product_id', (product_id)->
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'rental_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        if reservation
            Docs.find
                model:'rental'
                _id: reservation.rental_id

    Meteor.publish 'owner_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        rental =
            Docs.findOne
                model:'rental'
                _id: reservation.rental_id

        Meteor.users.find
            _id: rental.owner_username

    Meteor.publish 'handler_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        rental =
            Docs.findOne
                model:'rental'
                _id: reservation.rental_id

        Meteor.users.find
            _id: rental.handler_username

    Meteor.methods
        calc_reservation_stats: ->
            reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            unless reservation_stat_doc
                new_id = Docs.insert
                    model:'reservation_stats'
                reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            console.log reservation_stat_doc
            total_count = Docs.find(model:'reservation').count()
            submitted_count = Docs.find(model:'reservation', submitted:true).count()
            current_count = Docs.find(model:'reservation', current:true).count()
            unsubmitted_count = Docs.find(model:'reservation', submitted:$ne:true).count()
            Docs.update reservation_stat_doc._id,
                $set:
                    total_count:total_count
                    submitted_count:submitted_count
                    current_count:current_count
