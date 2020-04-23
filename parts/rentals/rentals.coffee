if Meteor.isClient
    Router.route '/rentals', (->
        @layout 'layout'
        @render 'rentals'
        ), name:'rentals'


    Template.rentals.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'rental_sort_key', 'datetime_available'
        Session.setDefault 'rental_sort_label', 'available'
        Session.setDefault 'rental_limit', 5
        Session.setDefault 'view_open', true

    Template.rentals.onCreated ->
        @autorun => @subscribe 'rental_facets',
            selected_tags.array()
            Session.get('rental_limit')
            Session.get('rental_sort_key')
            Session.get('rental_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'rental_results',
            selected_tags.array()
            Session.get('rental_limit')
            Session.get('rental_sort_key')
            Session.get('rental_sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.rentals.events
        'click .add_rental': ->
            new_id =
                Docs.insert
                    model:'rental'
            Router.go("/rental/#{new_id}/edit")


        'click .toggle_delivery': -> Session.set('view_delivery', !Session.get('view_delivery'))
        'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .tag_result': -> selected_tags.push @title
        'click .unselect_tag': ->
            selected_tags.remove @valueOf()
            # console.log selected_tags.array()
            # if selected_tags.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if selected_tags.array().length > 0
                # Meteor.call 'search_reddit', selected_tags.array(), ->

        'click .clear_selected_tags': ->
            Session.set('current_query',null)
            selected_tags.clear()

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    selected_tags.push search
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

        'click .calc_rental_count': ->
            Meteor.call 'calc_rental_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = selected_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             selected_tags.pop()
        #             Meteor.call 'search_reddit', selected_tags.array(), ->
        # , 1000)

        'click .reconnect': ->
            Meteor.reconnect()


        'click .set_sort_direction': ->
            if Session.get('rental_sort_direction') is -1
                Session.set('rental_sort_direction', 1)
            else
                Session.set('rental_sort_direction', -1)


    Template.rentals.helpers
        quickbuying_rental: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('rental_sort_direction')) is 1

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
            rental_count = Docs.find().count()
            # console.log 'rental count', rental_count
            if rental_count < 3
                Tags.find({count: $lt: rental_count})
            else
                Tags.find()

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        selected_tags: -> selected_tags.array()
        selected_tags_plural: -> selected_tags.array().length > 1
        searching: -> Session.get('searching')

        one_post: ->
            Docs.find().count() is 1
        rentals: ->
            # if selected_tags.array().length > 0
            Docs.find {
                model:'rental'
            },
                sort: "#{Session.get('rental_sort_key')}":parseInt(Session.get('rental_sort_direction'))
                limit:Session.get('rental_limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()
        users: ->
            # if selected_tags.array().length > 0
            Meteor.users.find {
            },
                sort: count:-1
                # limit:1


        timestamp_tags: ->
            # if selected_tags.array().length > 0
            Timestamp_tags.find {
                # model:'reddit'
            },
                sort: count:-1
                # limit:1

        rental_limit: ->
            Session.get('rental_limit')

        current_rental_sort_label: ->
            Session.get('rental_sort_label')


    # Template.set_rental_limit.events
    #     'click .set_limit': ->
    #         console.log @
    #         Session.set('rental_limit', @amount)

    Template.set_rental_sort_key.events
        'click .set_sort': ->
            console.log @
            Session.set('rental_sort_key', @key)
            Session.set('rental_sort_label', @label)

    Template.session_edit_value_button.events
        'click .set_session_value': ->
            # console.log @key
            # console.log @value
            Session.set(@key, @value)

    Template.session_edit_value_button.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @classes
                res += @classes
            if Session.equals(@key,@value)
                res += ' active'
            # console.log res
            res



    Template.session_boolean_toggle.events
        'click .toggle_session_key': ->
            console.log @key
            Session.set(@key, !Session.get(@key))

    Template.session_boolean_toggle.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @classes
                res += @classes
            if Session.get(@key)
                res += ' blue'
            else
                res += ' basic'

            # console.log res
            res


if Meteor.isServer
    Meteor.publish 'rental_results', (
        selected_tags
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log selected_tags
        if doc_limit
            limit = doc_limit
        else
            limit = 10
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'rental'}
        if view_open
            match.open = $ne:false
        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if selected_tags.length > 0
            match.tags = $all: selected_tags
            sort = 'price_per_serving'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false

        # match.tags = $all: selected_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        console.log 'rental match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit

    Meteor.publish 'rental_facets', (
        selected_tags
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
        console.log 'selected tags', selected_tags

        self = @
        match = {}
        match.model = 'rental'
        if view_open
            match.open = $ne:false

        if view_delivery
            match.delivery = $ne:false
        if view_pickup
            match.pickup = $ne:false
        if selected_tags.length > 0 then match.tags = $all: selected_tags
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
            #     { $match: _id: $nin: selected_tags }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        # else
        # unless query and query.length > 2
        # if selected_tags.length > 0 then match.tags = $all: selected_tags
        # # match.tags = $all: selected_tags
        # # console.log 'match for tags', match
        # tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "tags": 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: "$tags", count: $sum: 1 }
        #     { $match: _id: $nin: selected_tags }
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
