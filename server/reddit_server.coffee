Meteor.publish 'reddit_tag_results', (
    picked_tags=null
    # query
    porn=false
    # searching
    dummy
    )->

    self = @
    match = {}

    # match.model = $in: ['reddit','wikipedia']
    match.model = 'reddit'
    # if query
    # if view_nsfw
    match.over_18 = porn
    if picked_tags and picked_tags.length > 0
        match.tags = $all: picked_tags
        limit = 10
    else
        limit = 20
    # else /
        # match.tags = $all: picked_tags
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
    
    self.ready()
    # else []

Meteor.publish 'tag_image', (
    term=null
    porn=false
    )->
    # added_tags = []
    # console.log 'match term', term
    # console.log 'match picked tags', picked_tags
    # if picked_tags.length > 0
    #     added_tags = picked_tags.push(term)
    match = {
        model:'reddit'
        tags: $in: [term]
        "watson.metadata.image": $exists:true
        $where: "this.watson.metadata.image.length > 1"
    }
    # if porn
    match.over_18 = porn
    # else 
    # added_tags = [term]
    # match = {model:'reddit'}
    # match.thumbnail = $nin:['default','self']
    # match.url = { $regex: /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/, $options: 'i' }
    # console.log "added tags", added_tags
    # console.log 'looking up added tags', added_tags
    # found = Docs.findOne match
    # console.log "TERM", term, found.
    # if found
    #     # console.log "FOUND THUMBNAIL",found.thumbnail
    Docs.find match,{
        limit:1
        sort:
            points:-1
            ups:-1
        fields:
            "watson.metadata.image":1
            model:1
            thumbnail:1
            tags:1
            ups:1
            over_18:1
            url:1
    }
    # else
    #     backup = 
    #         Docs.findOne 
    #             model:'reddit'
    #             thumbnail:$exists:true
    #             tags:$in:[term]
    #     console.log 'BACKUP', backup
    #     if backup
    #         Docs.find { 
    #             model:'reddit'
    #             thumbnail:$exists:true
    #             tags:$in:[term]
    #         }, 
    #             limit:1
    #             sort:ups:1
Meteor.publish 'reddit_doc_results', (
    picked_tags=null
    porn=false
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
    # if picked_subreddit
    #     match.subreddit = picked_subreddit
    # if porn
    match.over_18 = porn
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
                points:-1
                ups:-1
            limit:20
            fields:
                # youtube_id:1
                "rd.media_embed":1
                "rd.url":1
                "rd.thumbnail":1
                "rd.analyzed_text":1
                # subreddit:1
                thumbnail:1
                doc_sentiment_label:1
                doc_sentiment_score:1
                joy_percent:1
                sadness_percent:1
                fear_percent:1
                disgust_percent:1
                anger_percent:1
                over_18:1
                points:1
                upvoter_ids:1
                downvoter_ids:1
                url:1
                ups:1
                "watson.metadata":1
                "watson.analyzed_text":1
                title:1
                model:1
                # num_comments:1
                tags:1
                _timestamp:1
                # domain:1
    # else 
    #     Docs.find match,
    #         sort:_timestamp:-1
    #         limit:10



Meteor.publish 'reddit_mined_overlap', (
    username1
    username2
    picked_tags=null
    # query
    porn=false
    # searching
    dummy
    )->

    self = @
    match = {}
    user1 = Meteor.users.findOne username:username1
    user2 = Meteor.users.findOne username:username2
    # match.model = $in: ['reddit','wikipedia']
    match.model = 'reddit'
    # if query
    # if view_nsfw
    match.upvoter_ids = $in:[user1._id,user2._id]
    # match.over_18 = porn
    if picked_tags and picked_tags.length > 0
        match.tags = $all: picked_tags
        limit = 10
    else
        limit = 20
    console.log 'match overlap', match
    # else /
        # match.tags = $all: picked_tags
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
            model:'overlap_tag'
            # index: i
    
    self.ready()
    # else []
