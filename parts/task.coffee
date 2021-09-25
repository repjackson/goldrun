if Meteor.isClient
    Router.route '/tasks', (->
        @layout 'layout'
        @render 'tasks'
        ), name:'tasks'


    Template.tasks.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'task_sort_key', 'datetime_available'
        Session.setDefault 'task_sort_label', 'available'
        Session.setDefault 'task_limit', 5
        Session.setDefault 'view_open', true

    Template.tasks.onCreated ->
        @autorun => @subscribe 'task_facets',
            picked_tags.array()
            Session.get('task_limit')
            Session.get('task_sort_key')
            Session.get('task_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'task_results',
            picked_tags.array()
            Session.get('task_limit')
            Session.get('task_sort_key')
            Session.get('task_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.tasks.events
        'click .add_task': ->
            new_id =
                Docs.insert
                    model:'task'
            Router.go("/task/#{new_id}/edit")


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

        'click .calc_task_count': ->
            Meteor.call 'calc_task_count', ->

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
            if Session.get('task_sort_direction') is -1
                Session.set('task_sort_direction', 1)
            else
                Session.set('task_sort_direction', -1)


    Template.tasks.helpers
        quickbuying_task: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('task_sort_direction')) is 1

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
            task_count = Docs.find().count()
            # console.log 'task count', task_count
            if task_count < 3
                Tags.find({count: $lt: task_count})
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
        task_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'task'
            },
                sort: "#{Session.get('task_sort_key')}":parseInt(Session.get('task_sort_direction'))
                limit:Session.get('task_limit')

        # home_subs_ready: ->
        #     Template.instance().subscriptionsReady()


if Meteor.isServer
    Meteor.publish 'task_results', (
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
        match = {model:'task'}
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

        console.log 'task match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            sort:_timestamp:-1
            limit: 20

    Meteor.publish 'task_facets', (
        picked_tags
        selected_timestamp_tags
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
        match.model = 'task'
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



Router.route '/task/:doc_id/', (->
    @render 'task_view'
    ), name:'task_view'
Router.route '/task/:doc_id/edit', (->
    @render 'task_edit'
    ), name:'task_edit'


if Meteor.isClient
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.task_edit.events
        'click .publish': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    published:true
                    publish_timestamp:Date.now()
    # Template.task_history.onCreated ->
    #     @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    # Template.task_history.helpers
    #     task_events: ->
    #         Docs.find
    #             model:'log_event'
    #             parent_id:Router.current().params.doc_id


    # Template.task_subscription.onCreated ->
    #     # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
    # Template.task_subscription.events
    #     'click .subscribe': ->
    #         Docs.insert
    #             model:'log_event'
    #             log_type:'subscribe'
    #             parent_id:Router.current().params.doc_id
    #             text: "#{Meteor.user().username} subscribed to task order."


    # Template.task_reservations.onCreated ->
    #     @autorun => Meteor.subscribe 'task_reservations', Router.current().params.doc_id
    # Template.task_reservations.helpers
    #     reservations: ->
    #         Docs.find
    #             model:'reservation'
    #             task_id: Router.current().params.doc_id
    # Template.task_reservations.events
    #     'click .new_reservation': ->
    #         Docs.insert
    #             model:'reservation'
    #             task_id: Router.current().params.doc_id


if Meteor.isServer
    Meteor.publish 'task_reservations', (task_id)->
        Docs.find
            model:'reservation'
            task_id: task_id



    Meteor.methods
        calc_task_stats: ->
            task_stat_doc = Docs.findOne(model:'task_stats')
            unless task_stat_doc
                new_id = Docs.insert
                    model:'task_stats'
                task_stat_doc = Docs.findOne(model:'task_stats')
            console.log task_stat_doc
            total_count = Docs.find(model:'task').count()
            complete_count = Docs.find(model:'task', complete:true).count()
            incomplete_count = Docs.find(model:'task', complete:$ne:true).count()
            Docs.update task_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
