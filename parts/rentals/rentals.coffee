Router.route '/rentals/', (->
    @layout 'layout'
    @render 'rentals'
    ), name:'rentals'

if Meteor.isClient
    Template.rentals.onRendered ->
        @autorun -> Meteor.subscribe 'rental_docs', selected_rental_tags.array(), Session.get('query')
    Template.rentals.events
        'click .add_rental': ->
            new_rental_id =
                Docs.insert
                    model:'rental'
            Router.go "/rental/#{new_rental_id}/edit"
        'keyup .rental_search': (e,t)->
            query = $('.rental_search').val()
            if e.which is 8
                if query.length is 0
                    Session.set 'query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'query',query
            else
                Session.set 'query',query



    Template.rentals.helpers
        rentals: ->
            query = Session.get('query')
            if query
                Docs.find({
                    title: {$regex:"#{query}", $options: 'i'}
                    model:'rental'
                    },{ limit:20 }).fetch()
            else
                Docs.find({
                    model:'rental'
                    },{ limit:20 }).fetch()
