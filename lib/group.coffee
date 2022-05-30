if Meteor.isClient
    Router.route '/groups', (->
        @layout 'layout'
        @render 'groups'
        ), name:'groups'
    Router.route '/group/:doc_id/', (->
        @layout 'group_layout'
        @render 'group_dashboard'
        ), name:'group_home'
    Router.route '/group/:doc_id/:section', (->
        @layout 'group_layout'
        @render 'group_section'
        ), name:'group_section'
    Template.group_layout.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.group_section.helpers
        section_template: -> "group_#{Router.current().params.section}"




    # Template.groups.onRendered ->
    #     Session.set('model',Router.current().params.model)
    Template.groups.onCreated ->
        Session.setDefault('limit',42)
        Session.setDefault('sort_key','_timestamp')
        Session.setDefault('sort_icon','clock')
        Session.setDefault('sort_label','added')
        Session.setDefault('sort_direction',-1)
        # @autorun => @subscribe 'model_docs', 'post', ->
        # @autorun => @subscribe 'user_info_min', ->
        @autorun => @subscribe 'facet_sub',
            'group'
            picked_tags.array()
            Session.get('current_search')
            picked_timestamp_tags.array()
    
        @autorun => @subscribe 'doc_results',
            'group'
            picked_tags.array()
            Session.get('current_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
    Template.groups.helpers
        group_docs: ->
            match = {model:'group'}
            Docs.find match, 
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')        




if Meteor.isServer
    Meteor.publish 'user_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'group'
            _author_id: user._id
    Meteor.publish 'user_group_memberships', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'group'
            member_ids: $in:[user._id]

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
if Meteor.isClient
    Template.group_picker.onCreated ->
        @autorun => @subscribe 'group_search_results', Session.get('group_search'), ->
        @autorun => @subscribe 'group_from_doc_id', Router.current().params.doc_id, ->
    Template.group_picker.helpers
        group_results: ->
            Docs.find 
                model:'group'
                title: {$regex:"#{Session.get('group_search')}",$options:'i'}
                
        group_search_value: ->
            Session.get('group_search')
        group_doc: ->
            # console.log @
            Docs.findOne @group_id
    Template.group_picker.events
        'click .clear_search': (e,t)->
            Session.set('group_search', null)
            t.$('.group_search').val('')

            
        'click .remove_group': (e,t)->
            if confirm "remove #{@title} group?"
                Docs.update Router.current().params.doc_id,
                    $unset:
                        group_id:@_id
                        group_title:@title
        'click .pick_group': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:
                    group_id:@_id
                    group_title:@title
            Session.set('group_search',null)
            t.$('.group_search').val('')
            location.reload() 
        'keyup .group_search': (e,t)->
            # if e.which is '13'
            val = t.$('.group_search').val()
            if val.length > 1
                # console.log val
                Session.set('group_search', val)

        'click .create_group': ->
            new_id = 
                Docs.insert 
                    model:'group'
                    title:Session.get('group_search')
            Router.go "/doc/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'group_search_results', (group_title_queary)->
        Docs.find 
            model:'group'
            title: {$regex:"#{group_title_queary}",$options:'i'}


if Meteor.isClient
    Template.group_layout.onCreated ->
        @autorun => Meteor.subscribe 'group_logs', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_leaders', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_events', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_posts', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_products', Router.current().params.doc_id, ->
    
    Template.group_layout.helpers
        group_log_docs: ->
            Docs.find {
                model:'log'
                group_id:Router.current().params.doc_id
            },
                sort:_timestamp:-1
        group_post_docs: ->
            Docs.find 
                model:'post'
                group_id:Router.current().params.doc_id
        _members: ->
            Meteor.users.find 
                _id:$in:@member_ids
                
    # Template.groups_small.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'group', Sesion.get('group_search'),->
    # Template.groups_small.helpers
    #     group_docs: ->
    #         Docs.find   
    #             model:'group'
                
                
                
    # Template.group_products.events
    #     'click .add_product': ->
    #         new_id = 
    #             Docs.insert 
    #                 model:'product'
    #                 group_id:Router.current().params.doc_id
    #         Router.go "/doc/#{new_id}/edit"
            
    Template.group_layout.events
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
            Router.go "/doc/#{new_id}/edit"
        'click .join': ->
            doc = Docs.findOne Router.current().params.doc_id
            Docs.update doc._id,
                $addToSet:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username
        'click .leave': ->
            doc = Docs.findOne Router.current().params.doc_id
            Docs.update doc._id,
                $pull:
                    member_ids:Meteor.userId()
                    member_usernames:Meteor.user().username


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
    Template.group_checkins.onCreated ->
        @autorun => @subscribe 'child_docs', 'checkin', Router.current().params.doc_id, ->
    Template.group_checkins.events 
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
                    
                    
    Template.group_checkins.helpers
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
        
        
