Router.route '/group/:doc_id', (->
    @layout 'group_layout'
    @render 'group_view'
    ), name:'group_view
    '
Router.route '/group/:doc_id/events', (->
    @layout 'group_layout'
    @render 'group_events'
    ), name:'group_events'
Router.route '/group/:doc_id/about', (->
    @layout 'group_layout'
    @render 'group_about'
    ), name:'group_about'
Router.route '/group/:doc_id/posts', (->
    @layout 'group_layout'
    @render 'group_posts'
    ), name:'group_posts'
Router.route '/group/:doc_id/members', (->
    @layout 'group_layout'
    @render 'group_members'
    ), name:'group_members'
Router.route '/group/:doc_id/related', (->
    @layout 'group_layout'
    @render 'group_related'
    ), name:'group_related'
Router.route '/group/:doc_id/products', (->
    @layout 'group_layout'
    @render 'group_products'
    ), name:'group_products'
Router.route '/group/:doc_id/chat', (->
    @layout 'group_layout'
    @render 'group_chat'
    ), name:'group_chat'



if Meteor.isClient
    Template.group_widget.onCreated ->
        @autorun => Meteor.subscribe 'user_from_username', @data
    Template.group_widget.helpers
        
    Template.related_groups.onCreated ->
        @autorun => Meteor.subscribe 'related_groups', @data._id, ->
    Template.related_groups.helpers
        related_group_docs: ->
            Docs.find 
                model:'group'
                _id: $nin:[Router.current().params.doc_id]
                
if Meteor.isServer 
    Meteor.publish 'related_groups', (group_id)->
        Docs.find 
            model:'group'
            _id:$nin:[group_id]
            
if Meteor.isClient
    Template.group_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'children', 'group_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_leaders', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_events', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_posts', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_products', Router.current().params.doc_id, ->
    Template.group_layout.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->


    # Template.groups_small.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'group', Sesion.get('group_search'),->
    # Template.groups_small.helpers
    #     group_docs: ->
    #         Docs.find   
    #             model:'group'
                
                
                
    Template.group_layout.helpers
        group_events: ->
            Docs.find 
                model:'event'
                group_ids:$in:[Router.current().params.doc_id]
    Template.group_posts.events 
        'click .add_group_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    group_id:Router.current().params.doc_id
            Router.go "/post/#{new_id}/edit"
    Template.group_posts.helpers
        group_post_docs: ->
            Docs.find 
                model:'post'
                group_id:Router.current().params.doc_id
    Template.group_members.helpers
        group_member_docs: ->
            Docs.find 
                model:'user'
                # group_ids:$in:[Router.current().params.doc_id]
        # current_group: ->
        #     Docs.findOne
        #         model:'group'
        #         slug: Router.current().params.doc_id

    Template.group_products.events
        'click .add_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    group_id:Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"
            
    Template.group_layout.events
        'click .add_group_task': ->
            new_id = 
                Docs.insert 
                    model:'task'
                    group_id:Router.current().params.doc_id
                    
            Router.go "/task/#{new_id}/edit"
            
        'click .add_group_member': ->
            new_username = prompt('username')
            splitted = new_username.split(' ')
            formatted = new_username.split(' ').join('_').toLowerCase()
            console.log formatted
            Meteor.call 'add_user', formatted, (err,res)->
                console.log res
                new_user = Meteor.users.findOne res
                Meteor.users.update res,
                    $set:
                        first_name:splitted[0]
                        last_name:splitted[1]
                    $addToSet:
                        group_memberships:Router.current().params.doc_id



        'click .refresh_group_stats': ->
            Meteor.call 'calc_group_stats', Router.current().params.doc_id, ->
        'click .add_group_event': ->
            new_id = 
                Docs.insert 
                    model:'event'
                    group_id:Router.current().params.doc_id
            Router.go "/event/#{new_id}/edit"
        # 'click .join': ->
        #     Docs.update
        #         model:'group'
        #         _author_id: Meteor.userId()
        # 'click .group_leave': ->
        #     my_group = Docs.findOne
        #         model:'group'
        #         _author_id: Meteor.userId()
        #         ballot_id: Router.current().params.doc_id
        #     if my_group
        #         Docs.update my_group._id,
        #             $set:value:'no'
        #     else
        #         Docs.insert
        #             model:'group'
        #             ballot_id: Router.current().params.doc_id
        #             value:'no'


if Meteor.isServer
    Meteor.publish 'group_events', (group_id)->
        # group = Docs.findOne
        #     model:'group'
        #     _id:group_id
        Docs.find
            model:'event'
            group_ids:$in: [group_id]

    Meteor.publish 'group_posts', (group_id)->
        # group = Docs.findOne
        #     model:'group'
        #     _id:group_id
        Docs.find
            model:'post'
            group_id:group_id


    Meteor.publish 'group_leaders', (group_id)->
        group = Docs.findOne group_id
        if group.leader_ids
            Meteor.users.find
                _id: $in: group.leader_ids

    Meteor.publish 'group_members', (group_id)->
        group = Docs.findOne group_id
        Meteor.users.find
            _id: $in: group.member_ids




Router.route '/group/:doc_id/edit', -> @render 'group_edit'


# group edit
if Meteor.isClient
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'group_options', Router.current().params.doc_id
    Template.group_edit.events
        'click .add_option': ->
            Docs.insert
                model:'group_option'
                ballot_id: Router.current().params.doc_id
    Template.group_edit.helpers
        options: ->
            Docs.find
                model:'group_option'


# groups
if Meteor.isClient
    Router.route '/groups', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'


    Template.groups.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'views'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

        @autorun => @subscribe 'group_facets',
            picked_tags.array()
            Session.get('current_search')
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'group_results',
            picked_tags.array()
            Session.get('current_search')
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')




    Template.groups.events
        'click .add_group': ->
            new_id =
                Docs.insert
                    model:'group'
            Router.go("/group/#{new_id}/edit")
            


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
            Session.set('current_group_search',null)
            picked_tags.clear()

        # 'keyup #search': _.throttle((e,t)->
        #     query = $('#search').val()
        #     Session.set('current_group_search', query)
        #     # console.log Session.get('current_group_search')
        #     if e.which is 13
        #         search = $('#search').val().trim().toLowerCase()
        #         if search.length > 0
        #             picked_tags.push search
        #             console.log 'search', search
        #             # Meteor.call 'log_term', search, ->
        #             $('#search').val('')
        #             Session.set('current_group_search', null)
        #             # # $('#search').val('').blur()
        #             # # $( "p" ).blur();
        #             # Meteor.setTimeout ->
        #             #     Session.set('dummy', !Session.get('dummy'))
        #             # , 10000
        # , 1000)

        'click .calc_group_count': ->
            Meteor.call 'calc_group_count', ->

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



    Template.groups.helpers

        # toggle_open_class: -> if Session.get('view_open') then 'blue' else ''
        # connection: ->
        #     console.log Meteor.status()
        #     Meteor.status()
        # connected: ->
        #     Meteor.status().connected
        group_tag_results: ->
            # if Session.get('current_group_search') and Session.get('current_group_search').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            group_count = Docs.find().count()
            # console.log 'group count', group_count
            # if group_count < 3
            #     Results.find({count: $lt: group_count})
            # else
            Results.find()

        current_group_search: -> Session.get('current_group_search')

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        group_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'group'
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                # limit:Session.get('group_limit')

        users: ->
            # if picked_tags.array().length > 0
            Meteor.users.find {
            },
                sort: count:-1
                # limit:1


        # timestamp_tags: ->
        #     # if picked_tags.array().length > 0
        #     Timestamp_tags.find {
        #         # model:'reddit'
        #     },
        #         sort: count:-1
        #         # limit:1

        group_limit: ->
            Session.get('group_limit')

        current_group_sort_label: ->
            Session.get('group_sort_label')


if Meteor.isServer
    Meteor.publish 'group_results', (
        picked_tags
        title_search=null
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log picked_tags
        match = {model:'group'}
        if doc_limit
            limit = doc_limit
        else
            limit = 42
        if title_search
            match.title = {$regex:"#{title_search}", $options: 'i'}

        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        # if view_open
        #     match.open = $ne:false
        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            sort = 'member_count'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false
        unless Meteor.userId()
            match.private = $ne:true

        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        console.log 'group match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            sort:_timestamp:-1
            limit: limit

    Meteor.publish 'group_facets', (
        picked_tags=[]
        title_search=null
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
        match.model = 'group'
        # if view_open
        #     match.open = $ne:false

        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        if title_search
            match.title = $regex:{"#{title_search}", $options: 'i'}

        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            # console.log 'group tag result ', tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'group_tag'
                # category:key
                # index: i


        self.ready()


# Router.route '/group/:doc_id/', (->
#     @render 'group_layout'
#     ), name:'group_layout'
# Router.route '/group/:doc_id/edit', (->
#     @render 'group_edit'
#     ), name:'group_edit'


if Meteor.isServer
    Meteor.publish 'user_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'group'
            _author_id: user._id

    Meteor.publish 'related_group', (doc_id)->
        doc = Docs.findOne doc_id
        if doc
            Docs.find {
                model:'group'
                _id:doc.group_id
            }
            


    Meteor.publish 'group_by_slug', (group_slug)->
        Docs.find
            model:'group'
            slug:group_slug
    Meteor.methods
        calc_group_stats: (group_slug)->
            group = Docs.findOne
                model:'group'
                slug: group_slug

            member_count =
                group.member_ids.length

            group_members =
                Meteor.users.find
                    _id: $in: group.member_ids

            dish_count = 0
            dish_ids = []
            for member in group_members.fetch()
                member_dishes =
                    Docs.find(
                        model:'dish'
                        _author_id:member._id
                    ).fetch()
                for dish in member_dishes
                    console.log 'dish', dish.title
                    dish_ids.push dish._id
                    dish_count++
            # dish_count =
            #     Docs.find(
            #         model:'dish'
            #         group_id:group._id
            #     ).count()
            group_count =
                Docs.find(
                    model:'group'
                    group_id:group._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    group_id:group._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            group_groups =
                Docs.find(
                    model:'group'
                    group_id:group._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update group._id,
                $set:
                    member_count:member_count
                    group_count:group_count
                    dish_count:dish_count
                    total_credit_exchanged:total_credit_exchanged
                    dish_ids:dish_ids
                    
        # calc_group_stats: ->
        #     group_stat_doc = Docs.findOne(model:'group_stats')
        #     unless group_stat_doc
        #         new_id = Docs.insert
        #             model:'group_stats'
        #         group_stat_doc = Docs.findOne(model:'group_stats')
        #     console.log group_stat_doc
        #     total_count = Docs.find(model:'group').count()
        #     complete_count = Docs.find(model:'group', complete:true).count()
        #     incomplete_count = Docs.find(model:'group', complete:$ne:true).count()
        #     Docs.update group_stat_doc._id,
        #         $set:
        #             total_count:total_count
        #             complete_count:complete_count
        #             incomplete_count:incomplete_count
                    