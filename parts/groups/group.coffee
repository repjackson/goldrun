Router.route '/group/:doc_id/view', (->
    @render 'group_view'
    ), name:'group_view'
Router.route '/group/:doc_id/edit', (->
    @render 'group_edit'
    ), name:'group_edit'


if Meteor.isClient
    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.group_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.group_history.helpers
        group_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id


    Template.group_subscription.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.group_subscription.events
        'click .subscribe': ->
            Docs.insert
                model:'log_event'
                log_type:'subscribe'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} subscribed to group order."


    Template.group_reservations.onCreated ->
        @autorun => Meteor.subscribe 'group_reservations', Router.current().params.doc_id
    Template.group_reservations.helpers
        reservations: ->
            Docs.find
                model:'reservation'
                group_id: Router.current().params.doc_id
    Template.group_reservations.events
        'click .new_reservation': ->
            Docs.insert
                model:'reservation'
                group_id: Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'group_reservations', (group_id)->
        Docs.find
            model:'reservation'
            group_id: group_id



    Meteor.methods
        calc_group_stats: ->
            group_stat_doc = Docs.findOne(model:'group_stats')
            unless group_stat_doc
                new_id = Docs.insert
                    model:'group_stats'
                group_stat_doc = Docs.findOne(model:'group_stats')
            console.log group_stat_doc
            total_count = Docs.find(model:'group').count()
            complete_count = Docs.find(model:'group', complete:true).count()
            incomplete_count = Docs.find(model:'group', complete:$ne:true).count()
            Docs.update group_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
