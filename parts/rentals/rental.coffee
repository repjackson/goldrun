Router.route '/rental/:doc_id/view', (->
    @render 'rental_view'
    ), name:'rental_view'
Router.route '/rental/:doc_id/edit', (->
    @render 'rental_edit'
    ), name:'rental_edit'


if Meteor.isClient
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.rental_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.rental_history.helpers
        rental_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id


    Template.rental_subscription.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.rental_subscription.events
        'click .subscribe': ->
            Docs.insert
                model:'log_event'
                log_type:'subscribe'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} subscribed to rental order."


    Template.rental_reservations.onCreated ->
        @autorun => Meteor.subscribe 'rental_reservations', Router.current().params.doc_id
    Template.rental_reservations.helpers
        reservations: ->
            Docs.find
                model:'reservation'
                rental_id: Router.current().params.doc_id
    Template.rental_reservations.events
        'click .new_reservation': ->
            Docs.insert
                model:'reservation'
                rental_id: Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'rental_reservations', (rental_id)->
        Docs.find
            model:'reservation'
            rental_id: rental_id



    Meteor.methods
        calc_rental_stats: ->
            rental_stat_doc = Docs.findOne(model:'rental_stats')
            unless rental_stat_doc
                new_id = Docs.insert
                    model:'rental_stats'
                rental_stat_doc = Docs.findOne(model:'rental_stats')
            console.log rental_stat_doc
            total_count = Docs.find(model:'rental').count()
            complete_count = Docs.find(model:'rental', complete:true).count()
            incomplete_count = Docs.find(model:'rental', complete:$ne:true).count()
            Docs.update rental_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
