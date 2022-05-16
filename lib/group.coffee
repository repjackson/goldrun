Router.route '/group/:doc_id/events', (->
    @layout 'group_view'
    @render 'group_events'
    ), name:'group_events'
Router.route '/group/:doc_id/about', (->
    @layout 'group_view'
    @render 'group_about'
    ), name:'group_about'
Router.route '/group/:doc_id/posts', (->
    @layout 'group_view'
    @render 'group_posts'
    ), name:'group_posts'
Router.route '/group/:doc_id/members', (->
    @layout 'group_view'
    @render 'group_members'
    ), name:'group_members'
Router.route '/group/:doc_id/related', (->
    @layout 'group_view'
    @render 'group_related'
    ), name:'group_related'
Router.route '/group/:doc_id/products', (->
    @layout 'group_view'
    @render 'group_products'
    ), name:'group_products'
Router.route '/group/:doc_id/chat', (->
    @layout 'group_view'
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
        Docs.find {
            model:'group'
            _id:$nin:[group_id]
        }, limit:10
if Meteor.isClient
    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'children', 'group_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_leaders', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_events', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_posts', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_products', Router.current().params.doc_id, ->
    Template.group_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->


    # Template.groups_small.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'group', Sesion.get('group_search'),->
    # Template.groups_small.helpers
    #     group_docs: ->
    #         Docs.find   
    #             model:'group'
                
                
                
    Template.group_events.helpers
        group_event_docs: ->
            Docs.find 
                model:'event'
                group_ids:Router.current().params.doc_id
    Template.group_posts.events 
        'click .add_group_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    group_id:Router.current().params.doc_id
            Router.go "/doc/#{new_id}/edit"
    Template.group_posts.helpers
        group_post_docs: ->
            Docs.find 
                model:'post'
                group_id:Router.current().params.doc_id
    Template.group_members.helpers

    Template.group_products.events
        'click .add_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    group_id:Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"
            
    Template.group_view.events
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
            group_ids:group_id

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



if Meteor.isClient 
    Template.checkin_widget.onCreated ->
        @autorun => @subscribe 'child_docs', 'checkin', Router.current().params.doc_id, ->
    Template.checkin_widget.events 
        'click .checkin': ->
            Docs.insert 
                model:'checkin'
                active:true
                group_id:Router.current().params.doc_id
                parent_id:Router.current().params.doc_id
        'click .checkout': ->
            active_doc =
                Docs.findOne 
                    model:'checkin'
                    active:true
                    parent_id:Router.current().params.doc_id
            if active_doc
                Docs.update active_doc._id, 
                    $set:
                        active:false
                        checkout_timestamp:Date.now()
                    
                    
    Template.checkin_widget.helpers
        checkin_docs: ->
            Docs.find {
                model:'checkin'
                parent_id:Router.current().params.doc_id
            }, sort:_timestamp:-1
        checked_in: ->
            Docs.findOne 
                model:'checkin'
                _author_id:Meteor.userId()
                active:true
        
        



Router.route '/group/:doc_id/edit', -> @render 'group_edit'


# group edit
if Meteor.isClient
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'group_options', Router.current().params.doc_id

# groups
# if Meteor.isClient
    # Template.groups.onCreated ->
    #     Session.setDefault 'view_mode', 'list'
    #     Session.setDefault 'sort_key', 'views'
    #     Session.setDefault 'sort_label', 'available'
    #     Session.setDefault 'limit', 20
    #     Session.setDefault 'view_open', true

    #     # @autorun => @subscribe 'facets',
    #     #     'group'
    #     #     picked_tags.array()
    #     #     Session.get('current_search')

    #     @autorun => @subscribe 'doc_results',
    #         'group'
    #         picked_tags.array()
    #         Session.get('current_search')
    #         Session.get('sort_key')
    #         Session.get('sort_direction')
    #         Session.get('limit')

    # Template.groups.helpers
    #     group_docs: ->
    #         # if picked_tags.array().length > 0
    #         Docs.find {
    #             model:'group'
    #         },
    #             sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
    #             # limit:Session.get('group_limit')


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
        calc_group_stats: (group_id)->
            group = Docs.findOne
                model:'group'
                _id:group_id

            member_count =
                group.member_ids.length

            group_members =
                Meteor.users.find
                    _id: $in: group.member_ids
            group_posts =
                Docs.users.find
                    group_id:group_id
            # dish_count = 0
            # for member in group_members.fetch()
            #     member_dishes =
            #         Docs.find(
            #             model:'dish'
            #             _author_id:member._id
            #         ).fetch()

            post_ids = []
            group_posts =
                Docs.find
                    model:'post'
                    group_id:group_id
            post_count = 0
            
            for post in group_posts.fetch()
                console.log 'group post', post.title
                post_ids.push post._id
                post_count++
                
                
                
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
                    event_count:event_count
                    total_credit_exchanged:total_credit_exchanged
                    post_count:post_count
                    post_ids:post_ids
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
                    