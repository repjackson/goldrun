if Meteor.isClient
    Router.route '/recipes', (->
        @layout 'layout'
        @render 'recipes'
        ), name:'recipes'


    Template.recipes.onCreated ->
        Session.setDefault 'view_mode', 'grid'
        Session.setDefault 'sort_key', '_timestamp'
        Session.setDefault 'sort_direction', -1
        # Session.setDefault 'recipe_sort_label', 'complete'
        Session.setDefault 'limit', 5
        Session.setDefault 'view_open', true

    Template.recipes.onCreated ->
        @autorun => @subscribe 'recipe_facets',
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'recipe_results',
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.recipes.events
        'click .add_recipe': ->
            new_id =
                Docs.insert
                    model:'recipe'
            Router.go("/recipe/#{new_id}/edit")

        'click .get_data': ->
            Meteor.call 'get_recipes', ->
                

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

        'click .calc_recipe_count': ->
            Meteor.call 'calc_recipe_count', ->

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




    Template.recipes.helpers
        quickbuying_recipe: ->
            Docs.findOne Session.get('quickbuying_id')

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_recipe: ->
            Docs.find().count() is 1
        recipe_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'recipe'
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()




if Meteor.isServer
    Meteor.methods 
        get_recipes: ->
            file = JSON.parse(Assets.getText("data.json"));
            # console.log file.recipes
            for recipe in file.recipes
                found_recipe = 
                    Docs.findOne 
                        model:'recipe'
                        uuid:recipe.uuid
                if found_recipe 
                    console.log 'found recipe, skipping', recipe.uuid
                else
                    console.log 'not found for uuid', recipe.uuid
                    recipe.model = 'recipe'
                    recipe.source = 'demo'
                    console.log 'inserting new doc', recipe
                    Docs.insert recipe
                    
            for special in file.specials 
                found_special = 
                    Docs.findOne 
                        model:'special'
                        uuid:special.uuid
                if found_special 
                    console.log 'found special, skipping', special.uuid
                else
                    console.log 'not found for uuid', special.uuid
                    special.model = 'special'
                    special.source = 'demo'
                    console.log 'inserting new doc', special
                    Docs.insert special

                    #   "uuid": "8f730f08-5ea5-48fb-bfd7-6a28337efc28",
                    #   "ingredientId": "aa1ff525-4190-4a66-8d12-3f383a752b55",
                    #   "type": "promocode",
                    #   "code": "GETMILK",
                    #   "title": "$1 off Milk",
                    #   "text": "Use the promocode GETMILK on Peapod and receive $1 off your next gallon!"
                            
    
    Meteor.publish 'recipe_results', (
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
        match = {model:'recipe'}
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

    Meteor.publish 'recipe_facets', (
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
        match.model = 'recipe'
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



Router.route '/recipe/:doc_id', (->
    @render 'recipe_view'
    ), name:'recipe_view'
Router.route '/recipe/:doc_id/edit', (->
    @render 'recipe_edit'
    ), name:'recipe_edit'


if Meteor.isClient
    Template.recipe_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.recipe_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->

    Template.recipe_orders.onCreated ->
        @autorun => Meteor.subscribe 'recipe_orders', Router.current().params.doc_id, ->

    Template.purchase_recipe_button.helpers
        has_purchased: ->
            Docs.findOne 
                model:'order'
                recipe_id:Router.current().params.doc_id
                _author_id:Meteor.userId()
    Template.purchase_recipe_button.events 
        'click .purchase_recipe': ->
            new_id = 
                Docs.insert 
                    model:'order'
                    order_type:'recipe'
                    recipe_id:Router.current().params.doc_id 
            # Router.go "/order/#{new_id}/edit"

    Template.recipe_orders.helpers
        recipe_order_docs: ->
            Docs.find 
                model:'order'
                recipe_id:Router.current().params.doc_id

    Template.recipe_edit.events 
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
    Meteor.publish 'recipe_orders', (recipe_id)->
        Docs.find({
            model:'order'
            recipe_id: recipe_id
        }, limit:10)


    Meteor.methods
        calc_recipe_stats: ->
            recipe_stat_doc = Docs.findOne(model:'recipe_stats')
            unless recipe_stat_doc
                new_id = Docs.insert
                    model:'recipe_stats'
                recipe_stat_doc = Docs.findOne(model:'recipe_stats')
            console.log recipe_stat_doc
            total_count = Docs.find(model:'recipe').count()
            complete_count = Docs.find(model:'recipe', complete:true).count()
            incomplete_count = Docs.find(model:'recipe', complete:$ne:true).count()
            Docs.update recipe_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count
