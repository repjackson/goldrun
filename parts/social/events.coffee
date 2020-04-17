Router.route '/events/', (->
    @render 'my_events'
    ), name:'my_events'
Router.route '/event/:doc_id/view', (->
    @render 'event_view'
    ), name:'event_view'
Router.route '/event/:doc_id/edit', (->
    @render 'event_edit'
    ), name:'event_edit'

if Meteor.isClient
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
