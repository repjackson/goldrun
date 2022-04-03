if Meteor.isClient
    Router.route '/requests', (->
        @layout 'layout'
        @render 'requests'
        ), name:'requests'
    Router.route '/request/:doc_id/edit', (->
        @layout 'layout'
        @render 'request_edit'
        ), name:'request_edit'
    Router.route '/request/:doc_id', (->
        @layout 'layout'
        @render 'request_view'
        ), name:'request_view'
    Router.route '/request/:doc_id/view', (->
        @layout 'layout'
        @render 'request_view'
        ), name:'request_view_long'
    
    
    # Template.requests.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'request', ->
    Template.requests.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', '_timestamp'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'sort_direction', -1
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

    Template.requests.onCreated ->
        # @autorun => @subscribe 'model_docs', 'request', ->
        @autorun => @subscribe 'request_facets',
            picked_tags.array()
            # Session.get('limit')
            # Session.get('sort_key')
            # Session.get('sort_direction')
            # Session.get('view_delivery')
            # Session.get('view_pickup')
            # Session.get('view_open')

        @autorun => @subscribe 'request_results',
            picked_tags.array()
            Session.get('group_title_search')
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

    Template.request_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.request_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.requests.helpers
        request_docs: ->
            Docs.find {
                model:'request'
            }, sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
        tag_results: ->
            Results.find 
                model:'request_tag'
        picked_request_tags: -> picked_tags.array()
        
                
    Template.requests.events
        'click .add_request': ->
            new_id = 
                Docs.insert 
                    model:'request'
            Router.go "/request/#{new_id}/edit"
    Template.request_card.events
        'click .view_request': ->
            Router.go "/request/#{@_id}"
    Template.request_item.events
        'click .view_request': ->
            Router.go "/request/#{@_id}"

    Template.request_view.events
        'click .add_request_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    request_ids:[@_id]
            Router.go "/recipe/#{new_id}/edit"

    # Template.favorite_icon_toggle.helpers
    #     icon_class: ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             'red'
    #         else
    #             'outline'
    # Template.favorite_icon_toggle.events
    #     'click .toggle_fav': ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             Docs.update @_id, 
    #                 $pull:favorite_ids:Meteor.userId()
    #         else
    #             $('body').toast(
    #                 showIcon: 'heart'
    #                 message: "marked favorite"
    #                 showProgress: 'bottom'
    #                 class: 'success'
    #                 # displayTime: 'auto',
    #                 position: "bottom right"
    #             )

    #             Docs.update @_id, 
    #                 $addToSet:favorite_ids:Meteor.userId()
    
    
    Template.request_edit.events
        'click .delete_request': ->
            Swal.fire({
                title: "delete request?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'request removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/request"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish request?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_request', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'request published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish request?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_request', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'request unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.publish 'request_results', (
        )->
        # console.log picked_ingredients
        # if doc_limit
        #     limit = doc_limit
        # else
        limit = 42
        # if doc_sort_key
        #     sort_key = doc_sort_key
        # if doc_sort_direction
        #     sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'request'}
        # if picked_ingredients.length > 0
        #     match.ingredients = $all: picked_ingredients
        #     # sort = 'price_per_serving'
        # if picked_sections.length > 0
        #     match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
        # match.published = true
            # match.source = $ne:'wikipedia'
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if request_query and request_query.length > 1
        #     console.log 'searching request_query', request_query
        #     match.title = {$regex:"#{request_query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}

        # match.tags = $all: picked_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        # console.log 'request match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        unless Meteor.userId()
            match.private = $ne:true
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: 42
            
            
    Meteor.publish 'request_count', (
        picked_ingredients
        picked_sections
        request_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_ingredients
        self = @
        match = {model:'request'}
        if picked_ingredients.length > 0
            match.ingredients = $all: picked_ingredients
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if request_query and request_query.length > 1
            console.log 'searching request_query', request_query
            match.title = {$regex:"#{request_query}", $options: 'i'}
        Counts.publish this, 'request_counter', Docs.find(match)
        return undefined

    Meteor.publish 'request_facets', (
        picked_tags
        request_query
        doc_limit
        doc_sort_key
        doc_sort_direction
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query

        self = @
        match = {}
        match.model = 'request'
            # match.$regex:"#{request_query}", $options: 'i'}
        # if request_query and request_query.length > 1
        #     console.log 'searching request_query', request_query
        #     match.title = {$regex:"#{request_query}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        if picked_tags.length > 0
            match.tags = $all: picked_tags
        # # console.log 'match for tags', match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            # { $match: _id: {$regex:"#{request_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        tag_cloud.forEach (tag, i) =>
            # console.log 'queried tag ', tag
            # console.log 'key', key
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'request_tag'
                # category:key
                # index: i


        self.ready()





if Meteor.isClient
    Template.request_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.request_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.request_card.helpers
        request_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
            