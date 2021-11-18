if Meteor.isClient
    
    Router.route '/orders', (->
        @layout 'layout'
        @render 'orders'
        ), name:'orders'
    
    Template.orders.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'daily_rate'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true
        @autorun => @subscribe 'count', ->
        @autorun => @subscribe 'order_facets',
            Session.get('query')
            picked_tags.array()
            picked_location_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_order')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'order_results',
            Session.get('query')
            picked_tags.array()
            picked_location_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_order')
            Session.get('view_pickup')
            Session.get('view_open')

    
    # Template.order_card.events
    #     'click .downvote':->
    #         Meteor.users.update Meteor.userId(),
    #             $addToSet:downvoted_ids:@_id
    #         Docs.update @_id, 
    #             $addToSet:downvoter_ids:Meteor.userId()
    #         $('body').toast({
    #             title: "#{@title} downvoted and hidden"
    #             # message: 'Please see desk staff for key.'
    #             class : 'success'
    #             # position:'top center'
    #             # className:
    #             #     toast: 'ui massive message'
    #             displayTime: 5000
    #             transition:
    #               showMethod   : 'zoom',
    #               showDuration : 250,
    #               hideMethod   : 'fade',
    #               hideDuration : 250
    #             })
                

    Template.orders.events
        'click .request_order': ->
            title = prompt "different title than #{Session.get('query')}"
            new_id = 
                Docs.insert 
                    model:'request'
                    title:Session.get('query')


        # 'click .toggle_order': -> Session.set('view_order', !Session.get('view_order'))
        # 'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        # 'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .tag_result': -> picked_tags.push @title
        'click .unselect_tag': ->
            picked_tags.remove @valueOf()
            # console.log picked_tags.array()
            # if picked_tags.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if picked_tags.array().length > 0
                # Meteor.call 'search_reddit', picked_tags.array(), ->

        'click .clear_picked_tags': ->
            Session.set('query',null)
            picked_tags.clear()

        'keyup .query': _.throttle((e,t)->
            query = $('.query').val()
            Session.set('query', query)
            # console.log Session.get('query')
            if e.which is 13
                search = $('.query').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('.query').val('')
                    Session.set('query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_order_count': ->
            Meteor.call 'calc_order_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)

    Template.orders.helpers
        query_requests: ->
            Docs.find
                model:'request'
                title:Session.get('query')
            
        counter: -> Counts.get('order_counter')
        tags: -> Results.find({model:'tag', title:$nin:picked_tags.array()})
        location_tags: -> Results.find({model:'location_tag',title:$nin:picked_location_tags.array()})
        authors: -> Results.find({model:'author'})

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_order: ->
            Docs.find().count() is 1
        order_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model: 'order'
                # downvoter_ids:$nin:[Meteor.userId()]
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()


if Meteor.isServer 
    Meteor.publish 'order_results', (
        query=''
        picked_tags=[]
        picked_location_tags=[]
        limit=20
        sort_key='_timestamp'
        sort_direction=-1
        view_delivery
        view_pickup
        view_open
        )->
        console.log picked_tags
        self = @
        match = {}
        match.model = 'order'
        
        match.app = 'goldrun'
        # if view_open
        #     match.open = $ne:false
        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        # if Meteor.userId()
        #     if Meteor.user().downvoted_ids
        #         match._id = $nin:Meteor.user().downvoted_ids
        if query
            match.title = {$regex:"#{query}", $options: 'i'}
        
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            # sort = 'price_per_serving'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false
    
        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array
    
        # console.log 'product match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit
