if Meteor.isClient
    @picked_tags = new ReactiveArray []
    Router.route '/reddit/', (->
        @layout 'layout'
        @render 'reddit'
        ), name:'reddit'
    Router.route '/reddit/:doc_id', (->
        @layout 'layout'
        @render 'reddit_view'
        ), name:'reddit_view'

    
    Template.registerHelper 'unescaped', () ->
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.selftext_html
        return txt.value

            # html.unescape(@rd.selftext_html)
    Template.registerHelper 'unescaped_content', () ->
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.media_embed.content
        return txt.value
        
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
    
    
    Template.reddit_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.reddit_view.onRendered ->
        # console.log @
        found_doc = Docs.findOne Router.current().params.doc_id
        if found_doc 
            unless found_doc.watson
                Meteor.call 'call_watson',Router.current().params.doc_id,'rd.selftext', ->
                    console.log 'autoran watson'
    # Template.reddit_card.onRendered ->
    #     console.log @
    #     found_doc = @data
    #     if found_doc 
    #         unless found_doc.watson
    #             Meteor.call 'call_watson',found_doc._id,'rd.selftext', ->
    #                 console.log 'autoran watson'

        # @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.reddit.onCreated ->
        Session.setDefault('current_query', null)
        Session.setDefault('dummy', false)
        Session.setDefault('is_loading', false)
        Session.setDefault('sort_key', '_timestamp')
        Session.setDefault('sort_direction', -1)
        @autorun => @subscribe 'agg_emotions',
            picked_tags.array()
            # Session.get('dummy')
        @autorun => @subscribe 'reddit_tag_results',
            picked_tags.array()
            Session.get('domain')
            Session.get('subreddit')
            Session.get('view_nsfw')
            Session.get('dummy')
        @autorun => @subscribe 'reddit_doc_results',
            picked_tags.array()
            Session.get('domain')
            Session.get('subreddit')
            Session.get('view_nsfw')
            Session.get('sort_key')
            Session.get('sort_direction')
            # Session.get('dummy')
    
    
    Template.reddit_view.events 
        'click .get_post': ->
            Meteor.call 'get_reddit_post_by_doc_id', Router.current().params.doc_id, ->
    
        'click .pick_subreddit': ->
            Session.set('subreddit',@subreddit)
            Router.go "/reddit"
    
    Template.agg_tag.onCreated ->
        # console.log @
        @autorun => @subscribe 'tag_image', @data.name, picked_tags.array(),->
            
    Template.agg_tag.helpers
        term_image: ->
            # console.log Template.currentData().name
            found = Docs.findOne 
                tags:$in:[Template.currentData().name]
            # console.log 'found image', found
            found
    Template.agg_tag.events
        'click .result': (e,t)->
            # Meteor.call 'log_term', @title, ->
            picked_tags.push @name
            $('#search').val('')
            Session.set('current_query', null)
            Session.set('searching', true)
            Session.set('is_loading', true)
            Meteor.call 'call_wiki', @name, ->
    
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('is_loading', false)
                Session.set('searching', false)
            # Meteor.setTimeout ->
            #     Session.set('dummy',!Session.get('dummy'))
            # , 5000
            
    
    Template.reddit.events
        'click .select_query': ->
            picked_tags.push @name
            Meteor.call 'search_reddit', picked_tags.array(), ->
            $('#search').val('')
            Session.set('current_query', null)
    
    Template.reddit_card.helpers
        five_cleaned_tags: ->
            # console.log picked_tags.array()
            # console.log @tags[..5] not in picked_tags.array()
            # console.log _.without(@tags[..5],picked_tags.array())
            if picked_tags.array().length
                _.difference(@tags[..10],picked_tags.array())
            #     @tags[..5] not in picked_tags.array()
            else 
                @tags[..5]
    Template.reddit_card.events
        'click .pick_flat_tag': -> 
            picked_tags.push @valueOf()
            Session.set('loading',true)
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('loading',false)
        'click .pick_subreddit': -> Session.set('subreddit',@subreddit)
        'click .pick_domain': -> Session.set('domain',@domain)
        'click .autotag': (e)->
            # console.log @
            # console.log Template.currentData()
            # console.log Template.parentData()
            # console.log Template.parentData(1)
            # console.log Template.parentData(2)
            # console.log Template.parentData(3)
            # if @rd and @rd.selftext_html
            #     dom = document.createElement('textarea')
            #     # dom.innerHTML = doc.body
            #     dom.innerHTML = @rd.selftext_html
            #     # console.log 'innner html', dom.value
            #     # return dom.value
            #     Docs.update @_id,
            #         $set:
            #             parsed_selftext_html:dom.value
            
            # doc = Template.parentData()
            # doc = Docs.findOne Template.parentData()._id
            # Meteor.call 'call_watson', Template.parentData()._id, parent.key, @mode, ->
            # if doc 
            # console.log 'calling client watson',doc, 'rd.selftext'
            Meteor.call 'call_watson', @_id, 'rd.selftext', 'html', ->
                $(e.currentTarget).closest('.button').transition('scale', 500)
                $('body').toast({
                    title: "emotions brokedown"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    showIcon:'chess'
                    # showProgress:'bottom'
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
                # Session.set('dummy', !Session.get('dummy'))
            # Meteor.call 'call_watson', doc._id, @key, @mode, ->
        
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
                        # console.log 'search', search
                        Session.set('is_loading', true)
                        Meteor.call 'search_reddit', picked_tags.array(), ->
                            Session.set('is_loading', false)
                            # Session.set('searching', false)
                        # Meteor.setTimeout ->
                        #     Session.set('dummy', !Session.get('dummy'))
                        # , 5000
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
        # 'click .pick_subreddit': -> Session.set('subreddit',@name)
        # 'click .unpick_subreddit': -> Session.set('subreddit',null)
        # 'click .pick_domain': -> Session.set('domain',@name)
        # 'click .unpick_domain': -> Session.set('domain',null)
        'click .print_me': (e,t)->
            console.log @
            
    Template.reddit_view.helpers
        unescaped: -> 
            txt = document.createElement("textarea")
            txt.innerHTML = @rd.selftext_html
            return txt.value

            # html.unescape(@rd.selftext_html)
        unescaped_content: -> 
            txt = document.createElement("textarea")
            txt.innerHTML = @rd.media_embed.content
            return txt.value

            # html.unescape(@rd.selftext_html)
    Template.reddit_view.events
        'click .pick_flat_tag': ->
            picked_tags.push @valueOf()
            Router.go "/reddit"
            Session.set('is_loading', true)
            Meteor.call 'search_reddit', picked_tags.array(), ->
                Session.set('is_loading', false)
                # Session.set('searching', false)
            
        'click .pull_post': (e,t)->
            # console.log @
            Meteor.call 'get_reddit_post', @_id, @reddit_id, =>
            # Meteor.call 'agg_omega', ->
    
    Template.shortcut.events
        'click .go': -> picked_tags.push @key
        
        
    Template.reddit.helpers
        emotion_avg_result: ->
            Results.findOne 
                model:'emotion_avg'
        # in_dev: -> Meteor.isDevelopment()
        not_searching: ->
            picked_tags.array().length is 0 and Session.equals('current_query',null)
            
        search_class: ->
            if Session.get('current_query')
                'massive active' 
            else
                if picked_tags.array().length is 0
                    'big'
                else 
                    'big' 
              
        domain_results: ->
            Results.find 
                model:'domain'
        picked_subreddit: -> Session.get('subreddit')
        picked_domain: -> Session.get('domain')
        subreddit_results: ->
            Results.find 
                model:'subreddit'
                    
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
            Docs.find({model:'reddit'}, 
                limit:20
                sort:
                    "#{Session.get('sort_key')}":Session.get('sort_direction')
            )
    
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
            Results.find({model:'tag'})
    
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
                        "#{Session.get('sort_key')}":Session.get('sort_direction')
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
        picked_domain=null
        picked_subreddit=null
        view_nsfw=false
        # searching
        dummy
        )->
    
        self = @
        match = {}
    
        # match.model = $in: ['reddit','wikipedia']
        match.model = 'reddit'
        # if query
        # if view_nsfw
        match.over_18 = view_nsfw
        if picked_tags and picked_tags.length > 0
            match.tags = $all: picked_tags
            limit = 10
        else
            limit = 42
        # else /
            # match.tags = $all: picked_tags
        # if picked_domain
        #     match.domain = picked_domain
        # if picked_subreddit
        #     match.subreddit = picked_subreddit
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
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
    
        tag_cloud.forEach (tag, i) =>
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
                # index: i
        
        # domain_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "domain": 1 }
        #     { $group: _id: "$domain", count: $sum: 1 }
        #     { $match: _id: $ne: picked_domain }
        #     { $match: count: $lt: agg_doc_count }
        #     # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 5 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ], {
        #     allowDiskUse: true
        # }
    
        # domain_cloud.forEach (domain, i) =>
        #     self.added 'results', Random.id(),
        #         name: domain.name
        #         count: domain.count
        #         model:'domain'
        #         # category:key
        #         # index: i
        
        # subreddit_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: "subreddit": 1 }
        #     { $group: _id: "$subreddit", count: $sum: 1 }
        #     { $match: _id: $ne: picked_subreddit }
        #     { $match: count: $lt: agg_doc_count }
        #     # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: 5 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        # ], {
        #     allowDiskUse: true
        # }
    
        # subreddit_cloud.forEach (subreddit, i) =>
        #     self.added 'results', Random.id(),
        #         name: subreddit.name
        #         count: subreddit.count
        #         model:'subreddit'
        #         # category:key
        #         # index: i
        self.ready()
        # else []
    Meteor.publish 'tag_image', (
        term
        picked_tags=[]
        )->
        # console.log 'match term', term
        # console.log 'match picked tags', picked_tags
        if picked_tags.length > 0
            added_tags = picked_tags.push term
        else 
            added_tags = [term]
        match = {model:'reddit'}
        match.thumbnail = $nin:['default','self']
        match.url = { $regex: /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/, $options: 'i' }
        console.log 'looking up added tags', added_tags
        match.tags = $in: added_tags
        found = Docs.findOne match
        console.log "TERM", term
        if found
            # console.log "FOUND THUMBNAIL",found.thumbnail
            Docs.find match,
                limit:1
                sort:ups:1
        else
            backup = 
                Docs.findOne 
                    model:'reddit'
                    thumbnail:$exists:true
                    tags:$in:[term]
            console.log 'BACKUP', backup
            if backup
                Docs.find { 
                    model:'reddit'
                    thumbnail:$exists:true
                    tags:$in:[term]
                }, 
                    limit:1
                    sort:ups:1
    Meteor.publish 'reddit_doc_results', (
        picked_tags=null
        picked_domain=null
        picked_subreddit=null
        view_nsfw=false
        sort_key='_timestamp'
        sort_direction=-1
        # dummy
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
        if picked_subreddit
            match.subreddit = picked_subreddit
        # if view_nsfw
        match.over_18 = view_nsfw
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
                    # "#{sort_key}":sort_direction
                    ups:-1
                limit:20
                fields:
                    # youtube_id:1
                    "rd.media_embed":1
                    "rd.url":1
                    "rd.thumbnail":1
                    subreddit:1
                    thumbnail:1
                    doc_sentiment_label:1
                    doc_sentiment_score:1
                    joy_percent:1
                    sadness_percent:1
                    fear_percent:1
                    disgust_percent:1
                    anger_percent:1
                    url:1
                    ups:1
                    upvoter_ids:1
                    downvoter_ids:1
                    points:1
                    title:1
                    model:1
                    num_comments:1
                    tags:1
                    _timestamp:1
                    domain:1
        # else 
        #     Docs.find match,
        #         sort:_timestamp:-1
        #         limit:10
                
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
                                if typeof(existing_doc.tags) is 'string'
                                    Docs.update existing_doc._id,
                                        $unset: tags: 1
                                Docs.update existing_doc._id,
                                    $addToSet: tags: $each: query
                                    $set:
                                        title:data.title
                                        ups:data.ups
                                        num_comments:data.num_comments
                                        over_18:data.over_18
                                        thumbnail:data.thumbnail
                                        permalink:data.permalink
                                Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                                # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                            unless existing_doc
                                new_reddit_post_id = Docs.insert reddit_post
                                Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                                # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                            return true
                    )
                    Meteor.call 'calc_user_points', ->
    
            # _.each(response.data.data.children, (item)->
            #     # data = item.data
            #     # len = 200
            # )
            
        get_reddit_post: (doc_id, reddit_id, root)->
            # console.log 'getting reddit post', doc_id, reddit_id
            HTTP.get "http://reddit.com/by_id/t3_#{reddit_id}.json", (err,res)->
                if err then console.error err
                else
                    rd = res.data.data.children[0].data
                    # console.log rd
                    result =
                        Docs.update doc_id,
                            $set:
                                rd: rd
                    # console.log rd
                    # if rd.is_video
                    #     # console.log 'pulling video comments watson'
                    #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                    # else if rd.is_image
                    #     # console.log 'pulling image comments watson'
                    #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                    # else
                    #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                    #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                    #     # Meteor.call 'call_visual', doc_id, ->
                    # if rd.selftext
                    #     unless rd.is_video
                    #         # if Meteor.isDevelopment
                    #         #     console.log "self text", rd.selftext
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 body: rd.selftext
                    #         }, ->
                    #         #     Meteor.call 'pull_site', doc_id, url
                    #             # console.log 'hi'
                    # if rd.selftext_html
                    #     unless rd.is_video
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 html: rd.selftext_html
                    #         }, ->
                    #             # Meteor.call 'pull_site', doc_id, url
                    #             # console.log 'hi'
                    # if rd.url
                    #     unless rd.is_video
                    #         url = rd.url
                    #         # if Meteor.isDevelopment
                    #         #     console.log "found url", url
                    #         Docs.update doc_id, {
                    #             $set:
                    #                 reddit_url: url
                    #                 url: url
                    #         }, ->
                    #             # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                    # # update_ob = {}
    
                    Docs.update doc_id,
                        $set:
                            rd: rd
                            url: rd.url
                            thumbnail: rd.thumbnail
                            subreddit: rd.subreddit
                            author: rd.author
                            is_video: rd.is_video
                            ups: rd.ups
                            # downs: rd.downs
                            over_18: rd.over_18
                        # $addToSet:
                        #     tags: $each: [rd.subreddit.toLowerCase()]
                    # console.log Docs.findOne(doc_id)
    
                
    Meteor.publish 'agg_emotions', (
        # group
        picked_tags
        dummy
        # picked_time_tags
        # selected_location_tags
        # selected_people_tags
        # picked_max_emotion
        # picked_timestamp_tags
        )->
        # @unblock()
        self = @
        match = {
            model:'reddit'
            # group:group
            joy_percent:$exists:true
        }
            
        doc_count = Docs.find(match).count()
        if picked_tags.length > 0 then match.tags = $all:picked_tags
        # if picked_max_emotion.length > 0 then match.max_emotion_name = $all:picked_max_emotion
        # if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
        # if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
        # if selected_people_tags.length > 0 then match.people_tags = $all:selected_people_tags
        # if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags
        
        emotion_avgs = Docs.aggregate [
            { $match: match }
            #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
            { $group: 
                _id:null
                avg_sent_score: { $avg: "$doc_sentiment_score" }
                avg_joy_score: { $avg: "$joy_percent" }
                avg_anger_score: { $avg: "$anger_percent" }
                avg_sadness_score: { $avg: "$sadness_percent" }
                avg_disgust_score: { $avg: "$disgust_percent" }
                avg_fear_score: { $avg: "$fear_percent" }
            }
        ]
        emotion_avgs.forEach (res, i) ->
            self.added 'results', Random.id(),
                model:'emotion_avg'
                avg_sent_score: res.avg_sent_score
                avg_joy_score: res.avg_joy_score
                avg_anger_score: res.avg_anger_score
                avg_sadness_score: res.avg_sadness_score
                avg_disgust_score: res.avg_disgust_score
                avg_fear_score: res.avg_fear_score
        self.ready()    
            