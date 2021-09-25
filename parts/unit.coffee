if Meteor.isClient
    Router.route '/units', (->
        @layout 'layout'
        @render 'units'
        ), name:'units'


    Template.units.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'unit_sort_key', 'datetime_available'
        Session.setDefault 'unit_sort_label', 'available'
        Session.setDefault 'unit_limit', 5
        Session.setDefault 'view_open', true

    Template.units.onCreated ->
        @autorun => @subscribe 'unit_facets',
            picked_tags.array()
            Session.get('unit_limit')
            Session.get('unit_sort_key')
            Session.get('unit_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'unit_results',
            picked_tags.array()
            Session.get('unit_limit')
            Session.get('unit_sort_key')
            Session.get('unit_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.units.events
        'click .add_unit': ->
            new_id =
                Docs.insert
                    model:'unit'
            Router.go("/unit/#{new_id}/edit")


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

        'click .calc_unit_count': ->
            Meteor.call 'calc_unit_count', ->

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
            if Session.get('unit_sort_direction') is -1
                Session.set('unit_sort_direction', 1)
            else
                Session.set('unit_sort_direction', -1)


    Template.units.helpers
        quickbuying_unit: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('unit_sort_direction')) is 1

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
            unit_count = Docs.find().count()
            # console.log 'unit count', unit_count
            if unit_count < 3
                Tags.find({count: $lt: unit_count})
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
        unit: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'unit'
            },
                sort: "#{Session.get('unit_sort_key')}":parseInt(Session.get('unit_sort_direction'))
                limit:Session.get('unit_limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()
        users: ->
            # if picked_tags.array().length > 0
            Meteor.users.find {
            },
                sort: count:-1
                # limit:1


        timestamp_tags: ->
            # if picked_tags.array().length > 0
            Timestamp_tags.find {
                # model:'reddit'
            },
                sort: count:-1
                # limit:1

        unit_limit: ->
            Session.get('unit_limit')

        current_unit_sort_label: ->
            Session.get('unit_sort_label')


    # Template.set_unit_limit.events
    #     'click .set_limit': ->
    #         console.log @
    #         Session.set('unit_limit', @amount)


if Meteor.isServer
    Meteor.publish 'unit_results', (
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
        match = {model:'unit'}
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

        console.log 'unit match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            sort:_timestamp:-1
            limit: 20

    Meteor.publish 'unit_facets', (
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
        match.model = 'unit'
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



Router.route '/unit/:doc_id/', (->
    @render 'unit_view'
    ), name:'unit_view'
Router.route '/unit/:doc_id/edit', (->
    @render 'unit_edit'
    ), name:'unit_edit'


if Meteor.isClient
    Template.unit_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.unit_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.unit_view.events
        'click .add_unit': ->
            new_id = 
                Docs.insert
                    model:'unit'
                    unit_id: Router.current().params.doc_id
            Router.go "/unit/#{new_id}/edit"
            
        'click .add_unit_post': ->
            new_id = 
                Docs.insert
                    model:'post'
                    unit_id: Router.current().params.doc_id
            Router.go "/post/#{new_id}/edit"
            
        'click .add_unit_product': ->
            new_id = 
                Docs.insert
                    model:'product'
                    unit_id: Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"
            
            
    Template.unit_edit.events
        # 'click .publish': ->
        #     Docs.update Router.current().params.doc_id, 
        #         $set:
        #             published:true
        #             publish_timestamp:Date.now()
    # Template.unit_history.onCreated ->
    #     @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    # Template.unit_history.helpers
    #     unit_events: ->
    #         Docs.find
    #             model:'log_event'
    #             parent_id:Router.current().params.doc_id


    # Template.unit_subscription.onCreated ->
    #     # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    # Template.unit_subscription.events
    #     'click .subscribe': ->
    #         Docs.insert
    #             model:'log_event'
    #             log_type:'subscribe'
    #             parent_id:Router.current().params.doc_id
    #             text: "#{Meteor.user().username} subscribed to unit order."


    # Template.unit_reservations.onCreated ->
    #     @autorun => Meteor.subscribe 'unit_reservations', Router.current().params.doc_id
    # Template.unit_reservations.helpers
    #     reservations: ->
    #         Docs.find
    #             model:'reservation'
    #             unit_id: Router.current().params.doc_id
    # Template.unit_reservations.events
    #     'click .new_reservation': ->
    #         Docs.insert
    #             model:'reservation'
    #             unit_id: Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'unit_reservations', (unit_id)->
        Docs.find
            model:'reservation'
            unit_id: unit_id



    Meteor.methods
        calc_unit_stats: ->
            unit_stat_doc = Docs.findOne(model:'unit_stats')
            unless unit_stat_doc
                new_id = Docs.insert
                    model:'unit_stats'
                unit_stat_doc = Docs.findOne(model:'unit_stats')
            console.log unit_stat_doc
            total_count = Docs.find(model:'unit').count()
            complete_count = Docs.find(model:'unit', complete:true).count()
            incomplete_count = Docs.find(model:'unit', complete:$ne:true).count()
            Docs.update unit_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
