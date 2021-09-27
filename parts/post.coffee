if Meteor.isClient
    Router.route '/posts', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'


    Template.posts.onCreated ->
        Session.setDefault 'view_mode', 'grid'
        Session.setDefault 'sort_key', '_timestamp'
        Session.setDefault 'sort_direction', -1
        # Session.setDefault 'post_sort_label', 'complete'
        Session.setDefault 'limit', 5
        Session.setDefault 'view_open', true

    Template.posts.onCreated ->
        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'post_results',
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.posts.events
        'click .add_post': ->
            new_id =
                Docs.insert
                    model:'post'
            Router.go("/post/#{new_id}/edit")


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




    Template.posts.helpers
        quickbuying_post: ->
            Docs.findOne Session.get('quickbuying_id')

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
                model:'post'
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()




if Meteor.isServer
    Meteor.publish 'post_results', (
        picked_tags=[]
        limit=20
        sort_key='_timestamp'
        sort_direction=-1
        view_delivery
        view_pickup
        view_open
        )->
        # console.log picked_tags
        self = @
        match = {model:'post'}
        # if view_pickup
        #     match.pickup = $ne:false
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            # sort = '_timestamp'
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



Router.route '/post/:doc_id', (->
    @render 'post_view'
    ), name:'post_view'
Router.route '/post/:doc_id/edit', (->
    @render 'post_edit'
    ), name:'post_edit'


if Meteor.isClient
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->

    Template.post_orders.onCreated ->
        @autorun => Meteor.subscribe 'post_orders', Router.current().params.doc_id, ->

    Template.purchase_post_button.helpers
        has_purchased: ->
            Docs.findOne 
                model:'order'
                post_id:Router.current().params.doc_id
                _author_id:Meteor.userId()
    Template.purchase_post_button.events 
        'click .purchase_post': ->
            new_id = 
                Docs.insert 
                    model:'order'
                    order_type:'post'
                    post_id:Router.current().params.doc_id 
            # Router.go "/order/#{new_id}/edit"

    Template.post_orders.helpers
        post_order_docs: ->
            Docs.find 
                model:'order'
                post_id:Router.current().params.doc_id

    Template.post_edit.events 
        'keyup body': (e,t)->
            if e.ctrlKey or e.metaKey
                switch String.fromCharCode(e.which).toLowerCase()
                    when 's'
                        e.preventDefault()
                        alert('ctrl-s')
                        break
                    when 'f'
                        e.preventDefault()
                        alert('ctrl-f')
                        break
                    when 'g'
                        e.preventDefault()
                        alert('ctrl-g')
                        break




if Meteor.isServer
    Meteor.publish 'post_orders', (post_id)->
        Docs.find({
            model:'order'
            post_id: post_id
        }, limit:10)


    Meteor.methods
        calc_post_stats: ->
            post_stat_doc = Docs.findOne(model:'post_stats')
            unless post_stat_doc
                new_id = Docs.insert
                    model:'post_stats'
                post_stat_doc = Docs.findOne(model:'post_stats')
            console.log post_stat_doc
            total_count = Docs.find(model:'post').count()
            complete_count = Docs.find(model:'post', complete:true).count()
            incomplete_count = Docs.find(model:'post', complete:$ne:true).count()
            Docs.update post_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
