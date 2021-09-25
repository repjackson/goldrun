if Meteor.isClient
    Router.route '/events', (->
        @layout 'layout'
        @render 'events'
        ), name:'events'


    Template.events.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'event_sort_key', 'datetime_available'
        Session.setDefault 'event_sort_label', 'available'
        Session.setDefault 'event_limit', 5
        Session.setDefault 'view_open', true

    Template.events.onCreated ->
        @autorun => @subscribe 'event_facets',
            picked_tags.array()
            Session.get('event_limit')
            Session.get('event_sort_key')
            Session.get('event_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'event_results',
            picked_tags.array()
            Session.get('event_limit')
            Session.get('event_sort_key')
            Session.get('event_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.events.events
        'click .add_event': ->
            new_id =
                Docs.insert
                    model:'event'
            Router.go("/event/#{new_id}/edit")


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

        'click .calc_event_count': ->
            Meteor.call 'calc_event_count', ->

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



    Template.events.helpers
        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        # picked_tags: -> picked_tags.array()
        # picked_tags_plural: -> picked_tags.array().length > 1
        # searching: -> Session.get('searching')

        one_post: ->
            Docs.find().count() is 1
        event: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'event'
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()


if Meteor.isServer
    Meteor.publish 'event_results', (
        picked_tags
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
            limit = 20
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'event'}
        # if view_open
        #     match.open = $ne:false
        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        # if picked_tags.length > 0
        #     match.tags = $all: picked_tags
        #     sort = 'price_per_serving'
        sort = '_timestamp'
        # else
            # match.tags = $nin: ['wikipedia']
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

        console.log 'event match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            sort:_timestamp:-1
            limit: 20

    Meteor.publish 'event_facets', (
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
        match.model = 'event'
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



Router.route '/event/:doc_id/', (->
    @render 'event_view'
    ), name:'event_view_long'
Router.route '/event/:doc_id', (->
    @render 'event_view'
    ), name:'event_view'
Router.route '/event/:doc_id/edit', (->
    @render 'event_edit'
    ), name:'event_edit'


if Meteor.isClient
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    # Template.event_history.onCreated ->
    #     @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    # Template.event_history.helpers
    #     event_events: ->
    #         Docs.find
    #             model:'log_event'
    #             parent_id:Router.current().params.doc_id


    # Template.event_subscription.onCreated ->
    #     # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    # Template.event_subscription.events
    #     'click .subscribe': ->
    #         Docs.insert
    #             model:'log_event'
    #             log_type:'subscribe'
    #             parent_id:Router.current().params.doc_id
    #             text: "#{Meteor.user().username} subscribed to event order."


    # Template.event_reservations.onCreated ->
    #     @autorun => Meteor.subscribe 'event_reservations', Router.current().params.doc_id
    # Template.event_reservations.helpers
    #     reservations: ->
    #         Docs.find
    #             model:'reservation'
    #             event_id: Router.current().params.doc_id
    # Template.event_reservations.events
    #     'click .new_reservation': ->
    #         Docs.insert
    #             model:'reservation'
    #             event_id: Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'event_reservations', (event_id)->
        Docs.find
            model:'reservation'
            event_id: event_id



    Meteor.methods
        calc_event_stats: ->
            event_stat_doc = Docs.findOne(model:'event_stats')
            unless event_stat_doc
                new_id = Docs.insert
                    model:'event_stats'
                event_stat_doc = Docs.findOne(model:'event_stats')
            console.log event_stat_doc
            total_count = Docs.find(model:'event').count()
            complete_count = Docs.find(model:'event', complete:true).count()
            incomplete_count = Docs.find(model:'event', complete:$ne:true).count()
            Docs.update event_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
