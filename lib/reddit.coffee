if Meteor.isClient
    @picked_tags = new ReactiveArray []
    Router.route '/reddit/', (->
        @layout 'layout'
        @render 'reddit'
        ), name:'reddit'

    
    Template.registerHelper 'session_key_value_is', (key, value) ->
        # console.log 'key', key
        # console.log 'value', value
        Session.equals key,value
    
    Template.registerHelper 'key_value_is', (key, value) ->
        # console.log 'key', key
        # console.log 'value', value
        @["#{key}"] is value
    
    
    Template.registerHelper 'template_subs_ready', () ->
        Template.instance().subscriptionsReady()
    
    Template.registerHelper 'global_subs_ready', () ->
        Session.get('global_subs_ready')
    
    
    Template.registerHelper 'sval', (input)-> Session.get(input)
    Template.registerHelper 'is_loading', -> Session.get 'is_loading'
    Template.registerHelper 'dev', -> Meteor.isDevelopment
    Template.registerHelper 'fixed', (number)->
        # console.log number
        (number*100).toFixed()
    Template.registerHelper 'to_percent', (number)->
        # console.log number
        (number*100).toFixed()
    
    Template.registerHelper 'is_image', () ->
        # regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
        # match = @url.match(regExp)
        # # console.log 'image match', match
        # if match then true
        # true
        regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
        match = @url.match(regExp)
        # console.log 'image match', match
        if match then true
        # true
    
    
    
    Template.registerHelper 'loading_class', ()->
        if Session.get 'loading' then 'disabled' else ''
    
    Template.registerHelper 'in_dev', ()-> Meteor.isDevelopment
    
    
    Template.reddit.onCreated ->
        Session.setDefault('current_query', null)
        Session.setDefault('dummy', false)
        Session.setDefault('is_loading', false)
        @autorun => @subscribe 'reddit_tag_results',
            picked_tags.array()
            Session.get('dummy')
        @autorun => @subscribe 'reddit_doc_results',
            picked_tags.array()
            Session.get('dummy')
    
    
    
    Template.agg_tag.onCreated ->
        # console.log @
        @autorun => @subscribe 'tag_image', @data.title, ->
            
    Template.agg_tag.helpers
        term_image: ->
            console.log Template.currentData().title
            Docs.findOne 
                tags:$in:Template.currentData().title
    Template.agg_tag.events
        'click .result': (e,t)->
            # Meteor.call 'log_term', @title, ->
            picked_tags.push @title
            $('#search').val('')
            Session.set('current_query', null)
            Session.set('searching', true)
            Session.set('is_loading', true)
    
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('is_loading', false)
                Session.set('searching', false)
            Meteor.setTimeout ->
                Session.set('dummy',!Session.get('dummy'))
            , 5000
            
    
    Template.reddit.events
        'click .select_query': ->
            picked_tags.push @title
            Meteor.call 'search_reddit', picked_tags.array(), ->
            $('#search').val('')
            Session.set('current_query', null)
    
    Template.reddit.events
        'click .print_me': ->
            console.log @
        'click .unpick_tag': ->
            picked_tags.remove @valueOf()
            console.log picked_tags.array()
            if picked_tags.array().length > 0
                Session.set('is_loading', true)
                Meteor.call 'search_reddit', picked_tags.array(), =>
                    Session.set('is_loading', false)
                Meteor.setTimeout ->
                    Session.set('dummy', !Session.get('dummy'))
                , 5000
    
        # # 'keyup #search': _.throttle((e,t)->
        'click #search': (e,t)->
            Session.set('dummy', !Session.get('dummy'))
        'keydown #search': (e,t)->
            query = $('#search').val()
            # if query.length > 0
            Session.set('current_query', query)
            # console.log Session.get('current_query')
            if query.length > 0
                if e.which is 13
                    search = $('#search').val().trim().toLowerCase()
                    if search.length > 0
                        # Session.set('searching', true)
                        picked_tags.push search
                        console.log 'search', search
                        Session.set('is_loading', true)
                        Meteor.call 'search_reddit', picked_tags.array(), ->
                            Session.set('is_loading', false)
                            # Session.set('searching', false)
                        Meteor.setTimeout ->
                            Session.set('dummy', !Session.get('dummy'))
                        , 5000
                        $('#search').val('')
                        Session.set('current_query', null)
        # , 200)
    
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
    
        'click .reconnect': -> Meteor.reconnect()
    
        'click .toggle_tag': (e,t)-> picked_tags.push @valueOf()
    
        'click .print_me': (e,t)->
            console.log @
        'click .pull_post': (e,t)->
            # console.log @
            Meteor.call 'get_reddit_post', @_id, @reddit_id, =>
            # Meteor.call 'agg_omega', ->
    
    Template.shortcut.events
        'click .go': -> picked_tags.push @key
        
        
    Template.reddit.helpers
        # in_dev: -> Meteor.isDevelopment()
        not_searching: ->
            picked_tags.array().length is 0 and Session.equals('current_query',null)
            
        search_class: ->
            if Session.get('current_query')
                'big' 
            else
                if picked_tags.array().length is 0
                    'huge fluid'
                else 
                    'big' 
                    
        curent_date_setting: -> Session.get('date_setting')
    
        term_icon: ->
            console.log @
        doc_results: ->
            current_docs = Docs.find()
            # if Session.get('selected_doc_id') in current_docs.fetch()
            # console.log current_docs.fetch()
            # Docs.findOne Session.get('selected_doc_id')
            doc_count = Docs.find().count()
            # if doc_count is 1
            Docs.find({model:'reddit'}, limit:20)
    
    
        is_loading: -> Session.get('is_loading')
    
        tag_result_class: ->
            # ec = omega.emotion_color
            # console.log @
            # console.log omega.total_doc_result_count
            total_doc_result_count = Docs.find({}).count()
            console.log total_doc_result_count
            percent = @count/total_doc_result_count
            # console.log 'percent', percent
            # console.log typeof parseFloat(@relevance)
            # console.log typeof (@relevance*100).toFixed()
            whole = parseInt(percent*10)+1
            # console.log 'whole', whole
    
            # if whole is 0 then "#{ec} f5"
            if whole is 0 then "f5"
            else if whole is 1 then "f11"
            else if whole is 2 then "f12"
            else if whole is 3 then "f13"
            else if whole is 4 then "f14"
            else if whole is 5 then "f15"
            else if whole is 6 then "f16"
            else if whole is 7 then "f17"
            else if whole is 8 then "f18"
            else if whole is 9 then "f19"
            else if whole is 10 then "f20"
    
    
        connection: ->
            # console.log Meteor.status()
            Meteor.status()
        connected: -> Meteor.status().connected
    
        unpicked_tags: ->
            # # doc_count = Docs.find().count()
            # # console.log 'doc count', doc_count
            # # if doc_count < 3
            # #     Tags.find({count: $lt: doc_count})
            # # else
            # unless Session.get('searching')
            #     unless Session.get('current_query').length > 0
            Tags.find({})
    
        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'
    
        picked_tags: -> picked_tags.array()
    
        picked_tags_plural: -> picked_tags.array().length > 1
    
        searching: ->
            # console.log 'searching?', Session.get('searching')
            Session.get('searching')
    
        one_post: -> Docs.find().count() is 1
    
        two_posts: -> Docs.find().count() is 2
        three_posts: -> Docs.find().count() is 3
        four_posts: -> Docs.find().count() is 4
        more_than_four: -> Docs.find().count() > 4
        one_result: ->
            Docs.find().count() is 1
    
        docs: ->
            # if picked_tags.array().length > 0
            cursor =
                Docs.find {
                    model:'reddit'
                },
                    sort:
                        ups:-1
            # console.log cursor.fetch()
            cursor
    
    
        home_subs_ready: ->
            Template.instance().subscriptionsReady()
            
        #     @autorun => Meteor.subscribe 'current_doc', Router.current().params.doc_id
        #     console.log @
        # Template.array_view.events
        #     'click .toggle_post_filter': ->
        #         console.log @
        #         value = @valueOf()
        #         console.log Template.currentData()
        #         current = Template.currentData()
        #         console.log Template.parentData()
                # match = Session.get('match')
                # key_array = match["#{current.key}"]
                # if key_array
                #     if value in key_array
                #         key_array = _.without(key_array, value)
                #         match["#{current.key}"] = key_array
                #         picked_tags.remove value
                #         Session.set('match', match)
                #     else
                #         key_array.push value
                #         picked_tags.push value
                #         Session.set('match', match)
                #         Meteor.call 'search_reddit', picked_tags.array(), ->
                #         # Meteor.call 'agg_idea', value, current.key, 'entity', ->
                #         console.log @
                #         # match["#{current.key}"] = ["#{value}"]
                # else
                # if value in picked_tags.array()
                #     picked_tags.remove value
                # else
                #     # match["#{current.key}"] = ["#{value}"]
                #     picked_tags.push value
                #     # console.log picked_tags.array()
                # # Session.set('match', match)
                # # console.log picked_tags.array()
                # if picked_tags.array().length > 0
                #     Meteor.call 'search_reddit', picked_tags.array(), ->
                # console.log Session.get('match')
    
        # Template.array_view.helpers
        #     values: ->
        #         # console.log @key
        #         Template.parentData()["#{@key}"]
        #
        #     post_label_class: ->
        #         match = Session.get('match')
        #         key = Template.parentData().key
        #         doc = Template.parentData(2)
        #         # console.log key
        #         # console.log doc
        #         # console.log @
        #         if @valueOf() in picked_tags.array()
        #             'active'
        #         else
        #             'basic'
        #         # if match["#{key}"]
        #         #     if @valueOf() in match["#{key}"]
        #         #         'active'
        #         #     else
        #         #         'basic'
        #         # else
        #         #     'basic'
        #
        
if Meteor.isServer
    Meteor.publish 'reddit_tag_results', (
        picked_tags=null
        # query
        # searching
        dummy
        )->
    
        self = @
        match = {}
    
        # match.model = $in: ['reddit','wikipedia']
        match.model = 'reddit'
        # if query
    
        if picked_tags and picked_tags.length > 0
            match.tags = $all: picked_tags
            agg_doc_count = Docs.find(match).count()
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: "tags": 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                { $match: _id: $nin: picked_tags }
                { $match: count: $lt: agg_doc_count }
                # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
                { $sort: count: -1, _id: 1 }
                { $limit: 15 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }
        
            tag_cloud.forEach (tag, i) =>
                self.added 'tags', Random.id(),
                    title: tag.name
                    count: tag.count
                    # category:key
                    # index: i
            self.ready()
        else []
    Meteor.publish 'tag_image', (term)->
        match = {model:'post'}
        match.url = { $regex: /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/, $options: 'i' }
        found = Docs.findOne match
        # console.log found 
        Docs.find match
    Meteor.publish 'reddit_doc_results', (
        picked_tags=null
        # current_query
        # date_setting
        )->
        # else
        self = @
        # match = {model:$in:['reddit','wikipedia']}
        match = {model:'reddit'}
        # match.over_18 = $ne:true
        #         yesterday = now-day
        #         match._timestamp = $gt:yesterday
    
        # if picked_tags.length > 0
        #     # if picked_tags.length is 1
        #     #     found_doc = Docs.findOne(title:picked_tags[0])
        #     #
        #     #     match.title = picked_tags[0]
        #     # else
        if picked_tags and picked_tags.length > 0
            match.tags = $all: picked_tags
            
            Docs.find match,
                sort:
                    ups:-1
                    # points:-1
                limit:10
                # fields:
                #     # youtube_id:1
                #     # thumbnail:1
                #     url:1
                #     ups:1
                #     title:1
                #     model:1
                #     num_comments:1
                #     tags:1
                #     # _timestamp:1
                #     domain:1
        else 
            Docs.find match,
                sort:_timestamp:-1
                limit:10
                
    Meteor.methods
        search_reddit: (query)->
            # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
            # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
            # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
            HTTP.get "http://reddit.com/search.json?q=#{query}&nsfw=1&include_over_18=on&limit=20&include_facets=true",(err,response)=>
                if response.data.data.dist > 1
                    _.each(response.data.data.children, (item)=>
                        unless item.domain is "OneWordBan"
                            data = item.data
                            len = 200
                            # added_tags = [query]
                            # added_tags.push data.domain.toLowerCase()
                            # added_tags.push data.author.toLowerCase()
                            # added_tags = _.flatten(added_tags)
                            # console.log 'data', data
                            reddit_post =
                                reddit_id: data.id
                                url: data.url
                                domain: data.domain
                                comment_count: data.num_comments
                                permalink: data.permalink
                                title: data.title
                                # root: query
                                ups:data.ups
                                num_comments:data.num_comments
                                # selftext: false
                                over_18:data.over_18
                                thumbnail: data.thumbnail
                                tags: query
                                model:'reddit'
                            existing_doc = Docs.findOne url:data.url
                            if existing_doc
                                # if Meteor.isDevelopment
                                # if typeof(existing_doc.tags) is 'string'
                                #     Doc.update
                                #         $unset: tags: 1
                                Docs.update existing_doc._id,
                                    $addToSet: tags: $each: query
                                    $set:
                                        title:data.title
                                        ups:data.ups
                                        num_comments:data.num_comments
                                        over_18:data.over_18
                                        thumbnail:data.thumbnail
                                        permalink:data.permalink
                                # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                                # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                            unless existing_doc
                                new_reddit_post_id = Docs.insert reddit_post
                                # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                                # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                            return true
                    )
    
            # _.each(response.data.data.children, (item)->
            #     # data = item.data
            #     # len = 200
            # )
            