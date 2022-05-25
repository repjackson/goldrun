if Meteor.isClient
    Router.route '/users', -> @render 'users'

    Template.users.onCreated ->
        Session.set('view_friends', false)
        # @autorun -> Meteor.subscribe('users')
        Session.setDefault 'limit', 42
        Session.setDefault 'sort_key', 'points'
        Session.setDefault('view_mode','grid')
        @autorun => Meteor.subscribe 'users_pub', 
            Session.get('current_search')
            picked_user_tags.array()
            Session.get('view_friends')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
            ->
        @autorun => Meteor.subscribe 'user_tags', picked_user_tags.array(), ->
            
if Meteor.isServer 
    Meteor.publish 'users_pub', (
        username_search, 
        picked_user_tags=[], 
        view_friends=false
        sort_key='points'
        sort_direction=-1
        limit=50
    )->
        match = {}
        if view_friends
            match._id = $in: Meteor.user().friend_ids
        if picked_user_tags.length > 0 then match.tags = $all:picked_user_tags 
        if username_search
            match.username = {$regex:"#{username_search}", $options: 'i'}
        Meteor.users.find(match,{ 
            limit:100, 
            sort:
                "#{sort_key}":sort_direction
            fields:
                username:1
                image_id:1
                tags:1
                points:1
                credit:1
                first_name:1
                last_name:1
                group_memberships:1
                createdAt:1
        })
            
if Meteor.isClient  
    Template.users.events
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        'keyup .username_search': (e,t)->
            username_search = $('.username_search').val()
            if e.which is 8
                if username_search.length is 0
                    Session.set 'username_search',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_search',username_search
            else
                Session.set 'username_search',username_search
            
            
    Template.users.helpers
        toggle_friends_class: -> if Session.get('view_friends',true) then 'blue large' else ''
        picked_user_tags: -> picked_user_tags.array()
        all_user_tags: -> Results.find model:'user_tag'
        one_result: ->
            # console.log 'one'
            Meteor.users.find({_id:$ne:Meteor.userId()}).count() is 1
        username_query: -> Session.get('username_query')
        user_docs: ->
            match = {}
            username_query = Session.get('username_query')
            if username_query
                match.username = {$regex:"#{username_query}", $options: 'i'}
            if picked_user_tags.array().length > 0
                match.tags = $all: picked_user_tags.array()
                
            match._id = $ne:Meteor.userId()
            Meteor.users.find(match
                # roles:$in:['resident','owner']
            ,
                # limit:Session.get('limit')
                limit:150
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
            )
        # users: ->
        #     username_search = Session.get('username_search')
        #     Meteor.users.find({
        #         username: {$regex:"#{username_search}", $options: 'i'}
        #         # healthclub_checkedin:$ne:true
        #         # roles:$in:['resident','owner']
        #         },{ 
        #             limit:100
        #             sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
        #     })

    Template.users.events
        'click .toggle_friends': -> Session.set('view_friends', !Session.get('view_friends'))
        'click .pick_user_tag': -> picked_user_tags.push @name
        'click .unpick_user_tag': -> picked_user_tags.remove @valueOf()
        'click .add_user': ->
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
                Router.go "/user/#{formatted}"
                $('body').toast({
                    title: "user created"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    icon:'user'
                    position:'bottom right'
                    # className:
                    #     toast: 'ui massive message'
                    # displayTime: 5000
                    transition:
                      showMethod   : 'zoom',
                      showDuration : 250,
                      hideMethod   : 'fade',
                      hideDuration : 250
                    })
                
        'keyup .search_user': (e,t)->
            username_query = $('.search_user').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    # Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query

        'click .clear_query': ->
            Session.set('username_query',null)


if Meteor.isServer
    Meteor.publish 'user_results', (
        picked_tags
        limit=150
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log picked_tags
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'event'}
        # if view_open
        #     match.open = $ne:false
        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            # sort = 'member_count'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
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

        console.log 'group match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            sort:_timestamp:-1
            limit: 150
            # limit: limit


    
    Meteor.publish 'user_tags', (picked_tags)->
        # user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd
    
        self = @
        match = {}
    
        # picked_tags.push current_herd
        if picked_tags.length > 0
            match.tags = $all: picked_tags
        count = Meteor.users.find(match).count()
        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        cloud.forEach (tag, i) ->
    
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'user_tag'
                index: i
    
        self.ready()
        
        
        
if Meteor.isServer 
    Meteor.methods
        calc_user_tags: (user_id)->
            debit_tags = Meteor.call 'omega', user_id, 'debit'
            # debit_tags = Meteor.call 'omega', user_id, 'debit', (err, res)->
            # console.log res
            # console.log 'res from async agg'
            Meteor.users.update user_id, 
                $set:
                    debit_tags:debit_tags
    
            credit_tags = Meteor.call 'omega', user_id, 'credit'
            # console.log res
            # console.log 'res from async agg'
            Meteor.users.update user_id, 
                $set:
                    credit_tags:credit_tags
    
    
        omega: (user_id, direction)->
            user = Meteor.users.findOne user_id
            options = {
                explain:false
                allowDiskUse:true
            }
            match = {}
            match.model = 'debit'
            if direction is 'debit'
                match._author_id = user_id
            if direction is 'credit'
                match.recipient_id = user_id
    
            console.log 'found debits', Docs.find(match).count()
            # if omega.selected_tags.length > 0
            #     limit = 42
            # else
            # limit = 10
            # console.log 'omega_match', match
            # { $match: tags:$all: omega.selected_tags }
            pipe =  [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                # { $match: _id: $nin: omega.selected_tags }
                { $sort: count: -1, _id: 1 }
                { $limit: 42 }
                { $project: _id: 0, title: '$_id', count: 1 }
            ]
    
            if pipe
                agg = global['Docs'].rawCollection().aggregate(pipe,options)
                # else
                res = {}
                if agg
                    agg.toArray()
                    # printed = console.log(agg.toArray())
                    # console.log(agg.toArray())
                    # omega = Docs.findOne model:'omega_session'
                    # Docs.update omega._id,
                    #     $set:
                    #         agg:agg.toArray()
            else
                return null
            
            
            


if Meteor.isServer
    Meteor.publish 'user_search', (username, role)->
        if role
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
                roles:$in:[role]
            },{ limit:150})
        else
            Meteor.users.find({
                username: {$regex:"#{username}", $options: 'i'}
            },{ limit:150})