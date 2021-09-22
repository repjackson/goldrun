if Meteor.isClient
    Router.route '/', (->
        @render 'home'
        ), name:'home'

    Template.take_poll.onCreated ->
        @autorun -> Meteor.subscribe 'current_poll', ->
    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'service'
        @autorun -> Meteor.subscribe 'model_docs', 'question'
        @autorun -> Meteor.subscribe 'model_docs', 'rental'
        @autorun -> Meteor.subscribe 'model_docs', 'product'
        @autorun -> Meteor.subscribe 'model_docs', 'food'
        @autorun -> Meteor.subscribe 'model_docs', 'public_note'
        @autorun -> Meteor.subscribe 'users'

    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.home.helpers
        top_food: ->
            Docs.find
                model:'food'

        top_rentals: ->
            Docs.find
                model:'rental'

        top_services: ->
            Docs.find
                model:'service'

        top_products: ->
            Docs.find
                model:'product'
    
        public_note_docs: ->
            Docs.find 
                model:'public_note'

    Template.take_poll.helpers 
        current_poll: ->
            Docs.findOne 
                model:'poll'

    Template.home.events
        'keyup .add_note': (e,t)->
            if e.which is 13
                val = $('.add_note').val()
                console.log 'val', val
                Docs.insert 
                    model:'public_note'
                    body:val
                $('.add_note').val('')
                
            
if Meteor.isServer 
    Meteor.publish 'current_poll', ()->
        Docs.find 
            model:'poll'