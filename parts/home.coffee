if Meteor.isClient
    Router.route '/', (->
        @render 'home'
        ), name:'home'

    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'service'
        @autorun -> Meteor.subscribe 'model_docs', 'rental'
        @autorun -> Meteor.subscribe 'model_docs', 'product'
        @autorun -> Meteor.subscribe 'model_docs', 'food'
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
