if Meteor.isClient
    Router.route '/market', (->
        @render 'market'
        ), name:'market'



    Template.market.onCreated ->
        @autorun -> Meteor.subscribe 'market_docs', selected_market_tags.array()
    Template.market.helpers
        market_items: ->
            Docs.find
                model:'rental'
                product_id:Router.current().params.doc_id
