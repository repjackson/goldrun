if Meteor.isClient
    Router.route '/search', (->
        @layout 'layout'
        @render 'search'
        ), name:'search'



    Template.search.onCreated ->
        @autorun => Meteor.subscribe 'search_results', Session.get('query')

    Template.search.events
        'keyup .global_search': (e,t)->
            val = $('.global_search').val()
            console.log val
            Session.set('query',val)
            
    Template.search.helpers
        results: ->
            Docs.find 
                title:{$regex:Session.get('query'), $options:'i'}
                
                
                
                
                
if Meteor.isServer
    Meteor.publish 'search_results', (query)->
        if query.length > 0
            Docs.find({
                title:{$regex:query, $options:'i'}
            }, {
                limit:20
                sort:
                    _timestamp:-1
            })