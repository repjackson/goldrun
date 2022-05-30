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
                            Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
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
