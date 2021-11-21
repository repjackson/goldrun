if Meteor.isClient
    Template.posts.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'daily_rate'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit',10
        Session.setDefault 'view_open', true
        @autorun => @subscribe 'count', ->
        @autorun => @subscribe 'facets',
            Session.get('query')
            picked_tags.array()
            picked_location_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'results',
            Session.get('query')
            picked_tags.array()
            picked_location_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

    
    # Template.post_card.events
    #     'click .downvote':->
    #         Docs.update Meteor.userId(),
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
                

    Template.posts.events
        'click .request_post': ->
            title = prompt "different title than #{Session.get('query')}"
            new_id = 
                Docs.insert 
                    model:'request'
                    title:Session.get('query')


        # 'click .toggle_delivery': -> Session.set('view_delivery', !Session.get('view_delivery'))
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

        'click .calc_post_count': ->
            Meteor.call 'calc_post_count', ->

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

    Template.posts.helpers
        query_requests: ->
            Docs.find
                model:'request'
                title:Session.get('query')
            
        counter: -> Counts.get('post_counter')
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

        one_post: ->
            Docs.find().count() is 1
        post_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model: 'post'
                # downvoter_ids:$nin:[Meteor.userId()]
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()



if Meteor.isClient
    Router.route '/posts', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'


    Template.posts.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'post_sort_key', 'datetime_available'
        Session.setDefault 'post_sort_label', 'available'
        Session.setDefault 'post_limit', 5
        Session.setDefault 'view_open', true

    Template.posts.onCreated ->
        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('post_limit')
            Session.get('post_sort_key')
            Session.get('post_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'post_results',
            picked_tags.array()
            Session.get('post_limit')
            Session.get('post_sort_key')
            Session.get('post_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.posts.events
        'click .add_post': ->
            new_id =
                Docs.insert
                    model:'post'
            Router.go("/post/#{new_id}/edit")


        'click .toggle_delivery': -> Session.set('view_delivery', !Session.get('view_delivery'))
        'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .tag_result': -> picked_tags.push @title
        'click .unselect_tag': ->
            picked_tags.remove @valueOf()
            # console.log picked_tags.array()
            # if picked_tags.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if picked_tags.array().length > 0
                # Meteor.call 'search_reddit', picked_tags.array(), ->

        'click .clear_picked_tags': ->
            Session.set('current_query',null)
            picked_tags.clear()

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_post_count': ->
            Meteor.call 'calc_post_count', ->

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

        'click .reconnect': ->
            Meteor.reconnect()


        'click .set_sort_direction': ->
            if Session.get('post_sort_direction') is -1
                Session.set('post_sort_direction', 1)
            else
                Session.set('post_sort_direction', -1)


    Template.posts.helpers
        quickbuying_post: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('post_sort_direction')) is 1

        toggle_delivery_class: -> if Session.get('view_delivery') then 'blue' else ''
        toggle_pickup_class: -> if Session.get('view_pickup') then 'blue' else ''
        toggle_open_class: -> if Session.get('view_open') then 'blue' else ''
        connection: ->
            console.log Meteor.status()
            Meteor.status()
        connected: ->
            Meteor.status().connected
        invert_class: ->
            if Meteor.user()
                if Meteor.user().dark_mode
                    'invert'
        tags: ->
            # if Session.get('current_query') and Session.get('current_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            post_count = Docs.find().count()
            # console.log 'post count', post_count
            if post_count < 3
                Tags.find({count: $lt: post_count})
            else
                Tags.find()

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_post: ->
            Docs.find().count() is 1
        post: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'post'
            },
                sort: "#{Session.get('post_sort_key')}":parseInt(Session.get('post_sort_direction'))
                limit:Session.get('limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()





if Meteor.isServer
    Meteor.publish 'post_results', (
        picked_tags
        lat
        long
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log picked_tags
        if doc_limit
            limit = doc_limit
        else
            limit = 10
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'post'}
        if view_open
            match.open = $ne:false
        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            sort = 'price_per_serving'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
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
        match: location = 
           { $near :
              {
                $geometry: { type: "Point",  coordinates: [ lat, long ] },
                $minDistance: 1000,
                $maxDistance: 5000
              }
           }
        

        console.log 'post match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit

    Meteor.publish 'post_facets', (
        picked_tags
        picked_timestamp_tags
        query
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        console.log 'selected tags', picked_tags

        self = @
        match = {}
        match.model = 'post'
        if view_open
            match.open = $ne:false

        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if picked_tags.length > 0 then match.tags = $all: picked_tags
            # match.$regex:"#{current_query}", $options: 'i'}
        # if query and query.length > 1
        # #     console.log 'searching query', query
        # #     # match.tags = {$regex:"#{query}", $options: 'i'}
        # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        # #
        #     Terms.find {
        #         title: {$regex:"#{query}", $options: 'i'}
        #     },
        #         sort:
        #             count: -1
        #         limit: 20
            # tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: "tags": 1 }
            #     { $unwind: "$tags" }
            #     { $group: _id: "$tags", count: $sum: 1 }
            #     { $match: _id: $nin: picked_tags }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        # else
        # unless query and query.length > 2
        # if picked_tags.length > 0 then match.tags = $all: picked_tags
        # # match.tags = $all: picked_tags
        # # console.log 'match for tags', match
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: picked_tags }
        #     # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 20 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ], {
        #     allowDiskUse: true
        # }
        #
        # tag_cloud.forEach (tag, i) =>
        #     # console.log 'queried tag ', tag
        #     # console.log 'key', key
        #     self.added 'tags', Random.id(),
        #         title: tag.name
        #         count: tag.count
        #         # category:key
        #         # index: i


        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            # console.log 'tag result ', tag
            self.added 'tags', Random.id(),
                title: tag.title
                count: tag.count
                # category:key
                # index: i


        self.ready()


if Meteor.isClient
    Template.user_posts.onCreated ->
        @autorun => Meteor.subscribe 'user_posts', Router.current().params.username
    Template.user_posts.events
        'click .add_post': ->
            new_id =
                Docs.insert
                    model:'post'
            Router.go "/post/#{new_id}/edit"

    Template.user_posts.helpers
        posts: ->
            current_user = Docs.findOne username:Router.current().params.username
            Docs.find {
                model:'post'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_posts', (username)->
        user = Docs.findOne username:username
        Docs.find
            model:'post'
            _author_id: user._id
