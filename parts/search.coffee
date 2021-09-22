if Meteor.isClient
    Router.route '/search', (->
        @layout 'layout'
        @render 'search'
        ), name:'search'



    Template.search.onCreated ->
        Session.setDefault('query','')
        @autorun => Meteor.subscribe 'search_results', Session.get('query')

    Template.search.events
        'click .clear_query': (e,t)-> 
            Session.set('query', null)
            $('.global_search').focus()
        'keyup .global_search': _.throttle((e,t)->
            if e.which is 27
                Session.set('query', '')
            else 
                val = $('.global_search').val()
                console.log val
                Session.set('query',val)
        , 500)    
            
            
    Template.search.helpers
        current_query: -> Session.get('query')
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