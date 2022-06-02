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
    Docs.find {
        model:'reddit'
        tags: $in: [term]
        "watson.metadata.image": $exists:true
        $where: "this.watson.metadata.image.length > 1"
    },{
        limit:1
        sort:
            points:1
            ups:1
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
