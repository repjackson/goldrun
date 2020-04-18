Router.route '/building/:doc_id/edit', -> @render 'building_edit'

if Meteor.isClient
    Template.building_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'building_options', Router.current().params.doc_id
    Template.building_edit.events
        'click .add_option': ->
            Docs.insert
                model:'building_option'
                ballot_id: Router.current().params.doc_id
    Template.building_edit.helpers
        options: ->
            Docs.find
                model:'building_option'
