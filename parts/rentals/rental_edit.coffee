if Meteor.isClient
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'


    Template.rental_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1500


    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.rental_edit.helpers
        viewing_content: ->
            Session.equals('expand_field', @_id)

    Template.rental_edit.events
        'click .field_edit': ->
            if Session.equals('expand_field', @_id)
                Session.set('expand_field', null)
            else
                Session.set('expand_field', @_id)
