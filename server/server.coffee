Docs.allow
    insert: (userId, doc) -> 
        true    
            # doc._author_id is userId
    update: (userId, doc) ->
        doc
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) ->
        true
        # doc._author_id is userId or 'admin' in Meteor.user().roles
# Meteor.users.allow
#     insert: (userId, doc) -> 
#         true    
#             # doc._author_id is userId
#     update: (userId, doc) ->
#         doc
#         # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
#         #     true
#         # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
#         #     true
#         # else
#         #     doc._author_id is userId
#     # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
#     remove: (userId, doc) -> 
#         if Meteor.user() and Meteor.user().admin_mode
#             true
#         else
#             false
#         # doc._author_id is userId or 'admin' in Meteor.user().roles

Meteor.publish 'count', ->
  Counts.publish this, 'product_counter', Docs.find({model:'product'})
  return undefined    # otherwise coffeescript returns a Counts.publish
                      # handle when Meteor expects a Mongo.Cursor object.


Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

# Meteor.publish 'author_from_doc_id', (doc_id)->
#     doc = Docs.findOne doc_id
#     if doc 
#         Docs.find doc._author_id

Meteor.methods    
    global_remove: (keyname)->
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()




    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        console.log 'old count', old_count
        console.log 'new count', new_count
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

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
        limit = 20
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
Meteor.methods
    search_reddit: (query)->
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
        HTTP.get "http://reddit.com/search.json?q=#{query}&sort=top&limit=100&include_facets=false",(err,response)=>
            # console.log response
            if response.data.data.dist > 1
                _.each(response.data.data.children, (item)=>
                    # console.log 'item', item
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
                            # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                            # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                        unless existing_doc
                            new_reddit_post_id = Docs.insert reddit_post
                            # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                            # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                        return true
                )
                Meteor.call 'calc_user_points', ->

        # _.each(response.data.data.children, (item)->
        #     # data = item.data
        #     # len = 200
        # )
        
    get_reddit_post: (doc_id, reddit_id, root)->
        doc = Docs.findOne doc_id
        # console.log 'getting reddit post', doc_id, reddit_id
        if doc.reddit_id
            console.log 'found doc for direct reddit pull', doc.reddit_id
        else
            console.log 'NO found doc for direct reddit pull', doc
            
        HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json", (err,res)->
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
        