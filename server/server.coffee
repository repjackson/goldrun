Docs.allow
    insert: (userId, doc) -> doc._author_id is userId
    update: (userId, doc) ->
        doc
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles

Meteor.publish 'count', ->
  Counts.publish this, 'product_counter', Docs.find({model:'product'})
  return undefined    # otherwise coffeescript returns a Counts.publish
                      # handle when Meteor expects a Mongo.Cursor object.


Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.private.cloudinary_key
    api_secret: Meteor.settings.private.cloudinary_secret




# if Meteor.isProduction
#     SyncedCron.start()
Meteor.publish 'model_from_child_id', (child_id)->
    child = Docs.findOne child_id
    Docs.find
        model:'model'
        slug:child.type


Meteor.publish 'model_fields_from_child_id', (child_id)->
    child = Docs.findOne child_id
    model = Docs.findOne
        model:'model'
        slug:child.type
    Docs.find
        model:'field'
        parent_id:model._id

Meteor.publish 'model_docs', (
    model
    limit=10
    )->
    Docs.find {
        model: model
        app:'goldrun'
    }, limit:limit

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug

Meteor.publish 'child_docs', (id)->
    Docs.find
        parent_id:id


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array

Meteor.publish 'latest_posts', (tags)->
    Docs.find({
        model:'post'
    },{
        sort:_timestamp:-1
        limit:10
    })    

Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug



Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    Meteor.users.find user_id

Meteor.publish 'page', (slug)->
    Docs.find
        model:'page'
        slug:slug


Meteor.publish 'results', (
    query=''
    picked_tags=[]
    picked_location_tags=[]
    limit=42
    sort_key='_timestamp'
    sort_direction=-1
    view_delivery
    view_pickup
    view_open
    )->
    console.log picked_tags
    self = @
    match = {}
    match.model = 'post'
    
    match.app = 'goldrun'
    # if view_open
    #     match.open = $ne:false
    # if view_delivery
    #     match.delivery = $ne:false
    # if view_pickup
    #     match.pickup = $ne:false
    # if Meteor.userId()
    #     if Meteor.user().downvoted_ids
    #         match._id = $nin:Meteor.user().downvoted_ids
    if query
        match.title = {$regex:"#{query}", $options: 'i'}
    
    if picked_tags.length > 0
        match.tags = $all: picked_tags
        # sort = 'price_per_serving'
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

    # console.log 'product match', match
    # console.log 'sort key', sort_key
    # console.log 'sort direction', sort_direction
    Docs.find match,
        sort:"#{sort_key}":sort_direction
        # sort:_timestamp:-1
        limit: limit

Meteor.publish 'facets', (
    query=''
    picked_tags=[]
    picked_location_tags=[]
    # picked_timestamp_tags=[]
    limit=10
    sort_key='_timestamp'
    sort_direction=-1
    view_delivery
    view_pickup
    view_open
    )->
        
    # console.log 'dummy', dummy
    # console.log 'query', query
    # console.log 'selected tags', picked_tags

    self = @
    match = {}
    match.model = 'post'
    match.app = 'goldrun'
    # if view_open
    #     match.open = $ne:false

    # if view_delivery
    #     match.delivery = $ne:false
    # if view_pickup
    #     match.pickup = $ne:false
    if picked_tags.length > 0 then match.tags = $all: picked_tags
    if picked_location_tags.length > 0 then match.location_tags = $all: picked_location_tags
    if query
        match.title = {$regex:"#{query}", $options: 'i'}

    tag_cloud = Docs.aggregate [
        { $match: match }
        { $project: "tags": 1 }
        { $unwind: "$tags" }
        { $group: _id: "$tags", count: $sum: 1 }
        # { $nin: _id: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    tag_cloud.forEach (tag, i) =>
        # console.log 'tag result ', tag
        self.added 'results', Random.id(),
            title: tag.title
            count: tag.count
            model:'tag'
            # category:key
            # index: i

    location_cloud = Docs.aggregate [
        { $match: match }
        { $project: "location_tags": 1 }
        { $unwind: "$location_tags" }
        { $group: _id: "$location_tags", count: $sum: 1 }
        # { $nin: _id: picked_location_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, title: '$_id', count: 1 }
    ], {
        allowDiskUse: true
    }

    location_cloud.forEach (location_tag, i) =>
        # console.log 'location_tag result ', location_tag
        self.added 'results', Random.id(),
            title: location_tag.title
            count: location_tag.count
            model:'location_tag'
            # category:key
            # index: i


    self.ready()

