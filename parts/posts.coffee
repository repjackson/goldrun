if Meteor.isClient
    Template.posts.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'datetime_available'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true
        @autorun => @subscribe 'count', ->
        @autorun => @subscribe 'facets',
            Session.get('query')
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'results',
            Session.get('query')
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

    
    # Template.post_card.events
    #     'click .downvote':->
    #         Meteor.users.update Meteor.userId(),
    #             $addToSet:downvoted_ids:@_id
    #         Docs.update @_id, 
    #             $addToSet:downvoter_ids:Meteor.userId()
    #         $('body').toast({
    #             title: "#{@title} downvoted and hidden"
    #             # message: 'Please see desk staff for key.'
    #             class : 'success'
    #             # position:'top center'
    #             # className:
    #             #     toast: 'ui massive message'
    #             displayTime: 5000
    #             transition:
    #               showMethod   : 'zoom',
    #               showDuration : 250,
    #               hideMethod   : 'fade',
    #               hideDuration : 250
    #             })
                

    Template.posts.events
        'click .request_post': ->
            title = prompt "different title than #{Session.get('query')}"
            new_id = 
                Docs.insert 
                    model:'request'
                    title:Session.get('query')
        'click .add_post': ->
            new_id =
                Docs.insert
                    model:'post'
            Router.go("/post/#{new_id}/edit")


        # 'click .toggle_delivery': -> Session.set('view_delivery', !Session.get('view_delivery'))
        # 'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        # 'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .tag_result': -> picked_tags.push @title
        'click .unselect_tag': ->
            picked_tags.remove @valueOf()
            # console.log picked_tags.array()
            # if picked_tags.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if picked_tags.array().length > 0
                # Meteor.call 'search_reddit', picked_tags.array(), ->

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
        query_requests: ->
            Docs.find
                model:'request'
                title:Session.get('query')
            
        counter: -> Counts.get('post_counter')
        tags: -> Results.find({model:'tag'})
        location_tags: -> Results.find({model:'location_tag'})
        authors: -> Results.find({model:'author'})

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
                model: $in:['post','service','rental','post']
                # downvoter_ids:$nin:[Meteor.userId()]
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()
