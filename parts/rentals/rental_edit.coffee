if Meteor.isClient
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'


    Template.rental_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 2000


    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.rental_edit.events
        'click .toggle_info': (e,t)->
            # console.log e
            # console.log @
            # search_value = $(e.currentTarget).closest('.segment')
            if Session.equals('viewing_segment', 'info')
                Session.set('viewing_segment', null)
            else
                Session.set('viewing_segment', 'info')

    Template.rental_edit.helpers
        viewing_info: -> Session.get('viewing_segment', 'info')
