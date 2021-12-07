if Meteor.isClient
    # Template.rentals.onCreated ->
    #     Session.setDefault 'view_mode', 'list'
    #     Session.setDefault 'sort_key', 'daily_rate'
    #     Session.setDefault 'sort_label', 'available'
    #     Session.setDefault 'limit',10
    #     Session.setDefault 'view_open', true
    #     @autorun => @subscribe 'count', ->
    #     @autorun => @subscribe 'facets',
    #         Session.get('query')
    #         picked_tags.array()
    #         picked_location_tags.array()
    #         Session.get('limit')
    #         Session.get('sort_key')
    #         Session.get('sort_direction')
    #         Session.get('view_delivery')
    #         Session.get('view_pickup')
    #         Session.get('view_open')

    #     @autorun => @subscribe 'results',
    #         Session.get('query')
    #         picked_tags.array()
    #         picked_location_tags.array()
    #         Session.get('limit')
    #         Session.get('sort_key')
    #         Session.get('sort_direction')
    #         Session.get('view_delivery')
    #         Session.get('view_pickup')
    #         Session.get('view_open')

    
    Template.rentals.events
        'click .request_rental': ->
            title = prompt "different title than #{Session.get('query')}"
            new_id = 
                Docs.insert 
                    model:'request'
                    title:Session.get('query')


        'click .tag_result': -> picked_tags.push @title
        'click .unselect_tag': ->
            picked_tags.remove @valueOf()

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

        'click .calc_rental_count': ->
            Meteor.call 'calc_rental_count', ->

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

    Template.rentals.helpers
        query_requests: ->
            Docs.find
                model:'request'
                title:Session.get('query')
            
        counter: -> Counts.get('rental_counter')
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

        one_rental: ->
            Docs.find().count() is 1
        rental_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model: 'rental'
                # downvoter_ids:$nin:[Meteor.userId()]
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()



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
            picked_tags.array()
            Session.get('current_lat')
            Session.get('current_long')
            Session.get('rental_limit')
            Session.get('rental_sort_key')
            Session.get('rental_sort_direction')

        @autorun => @subscribe 'rental_results',
            picked_tags.array()
            Session.get('lat')
            Session.get('long')
            Session.get('rental_limit')
            Session.get('rental_sort_key')
            Session.get('rental_sort_direction')


    Template.rentals.events
        'click .add_rental': ->
            new_id =
                Docs.insert
                    model:'rental'
            Router.go("/rental/#{new_id}/edit")


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

        'click .calc_rental_count': ->
            Meteor.call 'calc_rental_count', ->

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
            if Session.get('rental_sort_direction') is -1
                Session.set('rental_sort_direction', 1)
            else
                Session.set('rental_sort_direction', -1)


    Template.rentals.helpers
        quickbuying_rental: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('rental_sort_direction')) is 1

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

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_rental: ->
            Docs.find().count() is 1
        rental: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'rental'
            },
                sort: "#{Session.get('rental_sort_key')}":parseInt(Session.get('rental_sort_direction'))
                limit:Session.get('limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()





if Meteor.isServer
    Meteor.publish 'rental_results', (
        picked_tags
        lat=50
        long=100
        doc_limit
        doc_sort_key
        doc_sort_direction
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
        match = {model:'rental'}
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            # sort = 'price_per_serving'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'

        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array
        # match.location = 
        #    { $near : [ -73.9667, 40.78 ], $maxDistance: 110 }
            
        #   { $near :
        #       {
        #         $geometry: { type: "Point",  coordinates: [ long, lat ] },
        #         $minDistance: 1000,
        #         $maxDistance: 5000
        #       }
        #   }
        

        # console.log 'rental match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit

    Meteor.publish 'rental_facets', (
        picked_tags
        lat
        long
        picked_timestamp_tags
        query
        doc_limit
        doc_sort_key
        doc_sort_direction
        )->
        # console.log 'lat', lat
        # console.log 'long', long
        # console.log 'selected tags', picked_tags

        self = @
        match = {}
        match.model = 'rental'

        if picked_tags.length > 0 then match.tags = $all: picked_tags
            # match.$regex:"#{current_query}", $options: 'i'}
        # if lat
        #     match.location = 
        #        { $near :
        #           {
        #             $geometry: { type: "Point",  coordinates: [ lat, long ] },
        #             $minDistance: 1000,
        #             $maxDistance: 5000
        #           }
        #        }

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
    Template.user_rentals.onCreated ->
        @autorun => Meteor.subscribe 'user_rentals', Router.current().params.username
    Template.user_rentals.events
        'click .add_rental': ->
            new_id =
                Docs.insert
                    model:'rental'
            Router.go "/rental/#{new_id}/edit"

    Template.user_rentals.helpers
        rentals: ->
            current_user = Docs.findOne username:Router.current().params.username
            Docs.find {
                model:'rental'
                _author_id: current_user._id
            }, sort:_timestamp:-1
