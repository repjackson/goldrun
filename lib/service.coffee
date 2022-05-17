if Meteor.isClient
    Template.service_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->
    Template.service_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->
