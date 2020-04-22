Router.route '/service/:doc_id/view', (->
    @render 'service_view'
    ), name:'service_view'
Router.route '/service/:doc_id/edit', (->
    @render 'service_edit'
    ), name:'service_edit'


if Meteor.isClient
    Template.service_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.service_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.service_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.service_history.helpers
        service_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id


    Template.service_subscription.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.service_subscription.events
        'click .subscribe': ->
            Docs.insert
                model:'log_event'
                log_type:'subscribe'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} subscribed to service order."


    Template.service_reservations.onCreated ->
        @autorun => Meteor.subscribe 'service_reservations', Router.current().params.doc_id
    Template.service_reservations.helpers
        reservations: ->
            Docs.find
                model:'reservation'
                service_id: Router.current().params.doc_id
    Template.service_reservations.events
        'click .new_reservation': ->
            Docs.insert
                model:'reservation'
                service_id: Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'service_reservations', (service_id)->
        Docs.find
            model:'reservation'
            service_id: service_id



    Meteor.methods
        calc_service_stats: ->
            service_stat_doc = Docs.findOne(model:'service_stats')
            unless service_stat_doc
                new_id = Docs.insert
                    model:'service_stats'
                service_stat_doc = Docs.findOne(model:'service_stats')
            console.log service_stat_doc
            total_count = Docs.find(model:'service').count()
            complete_count = Docs.find(model:'service', complete:true).count()
            incomplete_count = Docs.find(model:'service', complete:$ne:true).count()
            Docs.update service_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
