if Meteor.isClient
    Template.bounty_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'bounty_list'
    Template.bounty_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.bounty_edit.events
        'click .clear_bounty_list': ->
            bounty = Docs.findOne Router.current().params.doc_id
            Docs.update bounty._id,
                $unset:bounty_list_id:1
    Template.bounty_edit.helpers
        bounty_list: ->
            bounty = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                _id: bounty.bounty_list_id
                model:'bounty_list'
        choices: ->
            Docs.find
                model:'choice'
                bounty_id:@_id
    Template.bounty_edit.events
