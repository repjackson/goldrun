Router.route '/post/:doc_id/view', (->
    @render 'post_view'
    ), name:'post_view'
Router.route '/post/:doc_id/edit', (->
    @render 'post_edit'
    ), name:'post_edit'


if Meteor.isClient
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.post_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.post_history.helpers
        post_events: ->
            Docs.find
                model:'log_event'
                parent_id:Router.current().params.doc_id


    Template.post_subscription.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    Template.post_subscription.events
        'click .subscribe': ->
            Docs.insert
                model:'log_event'
                log_type:'subscribe'
                parent_id:Router.current().params.doc_id
                text: "#{Meteor.user().username} subscribed to post order."


    Template.post_reservations.onCreated ->
        @autorun => Meteor.subscribe 'post_reservations', Router.current().params.doc_id
    Template.post_reservations.helpers
        reservations: ->
            Docs.find
                model:'reservation'
                post_id: Router.current().params.doc_id
    Template.post_reservations.events
        'click .new_reservation': ->
            Docs.insert
                model:'reservation'
                post_id: Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'post_reservations', (post_id)->
        Docs.find
            model:'reservation'
            post_id: post_id



    Meteor.methods
        calc_post_stats: ->
            post_stat_doc = Docs.findOne(model:'post_stats')
            unless post_stat_doc
                new_id = Docs.insert
                    model:'post_stats'
                post_stat_doc = Docs.findOne(model:'post_stats')
            console.log post_stat_doc
            total_count = Docs.find(model:'post').count()
            complete_count = Docs.find(model:'post', complete:true).count()
            incomplete_count = Docs.find(model:'post', complete:$ne:true).count()
            Docs.update post_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
