if Meteor.isClient
    Router.route '/products/', (->
        @layout 'layout'
        @render 'products'
        ), name:'products'
    Router.route '/product/:doc_id', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'
    
    Template.product_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.products.onCreated ->
        # @autorun => @subscribe 'model_docs','artist', ->
        @autorun => @subscribe 'product_facets',
            picked_tags.array()
            Session.get('title')
        @autorun => @subscribe 'product_results',
            picked_tags.array()
            Session.get('title')

    Template.product_view.onRendered ->
        # console.log @
        found_doc = Docs.findOne Router.current().params.doc_id
        if found_doc 
            unless found_doc.watson
                Meteor.call 'call_watson',Router.current().params.doc_id,'content','html', ->
                    console.log 'autoran watson'
            unless found_doc.details 
                Meteor.call 'product_details', Router.current().params.doc_id, ->
                    console.log 'pulled product details'
                
    Template.product_view.helpers
        instruction_steps: ->
            console.log @
            console.log @details.analyzedInstructions[0]
            @details.analyzedInstructions[0].steps
            
    Template.product_view.events
        'click .pick_product_tag': ->
            Router.go "/product"
            Meteor.call 'call_product', @valueOf(), ->
        'click .get_details': ->
            Meteor.call 'product_details', @_id, ->
            
    Template.products.helpers
        product_docs: ->
            Docs.find 
                model:'product'
        product_docs: ->
            Docs.find {
                model:'product'
            }, sort:_timestamp:-1
            
        picked_tags: -> picked_tags.array()
        tag_results: ->
            Results.find()
        
    Template.products.events 
        'click .pick_tag': ->
            picked_tags.push @name
        'click .unpick_tag': ->
            picked_tags.remove @valueOf()
        
        'keyup .product_search': (e,t)->
            console.log 'hi'
            query = t.$('.product_search').val()
            Session.set('product_search',query)
            if e.which is 13
                Meteor.call 'call_product', Session.get('product_search'), ->

            
            
if Meteor.isServer
    Meteor.methods 
        product_details: (doc_id)->
            doc = Docs.findOne doc_id
            HTTP.get "https://api.spoonacular.com/products/#{doc.id}/information/?includeNutrition=false&apiKey=e52f2f2ca01a448e944d94194e904775&",(err,res)=>
                console.log res.data
                Docs.update doc_id, 
                    $set:
                        details:res.data
                        
                
        call_product: (search)->
            # console.log 'calling'
            # HTTP.get "https://api.spoonacular.com/mealplanner/generate?apiKey=e52f2f2ca01a448e944d94194e904775&timeFrame=day&targetCalories=#{calories}",(err,res)=>
            HTTP.get "https://api.spoonacular.com/food/products/search?apiKey=e52f2f2ca01a448e944d94194e904775&query=#{search}",(err,res)=>
                console.log res.data
                console.log res.data.products
                for result in res.data.products
                    console.log result.name
                    # if result.name is 'products'
                    products = res.data.products
                    # products = _.where(res.data.products, {name:'products'})
                    for product in products
                        console.log product
                        found_product = 
                            Docs.findOne 
                                model:'product'
                                source:'spoonacular'
                                id:product.id
                        if found_product
                            Docs.update found_product._id, 
                                $inc:hits:1
                        unless found_product
                            new_id = Docs.insert 
                                model:'product'
                                id:product.id
                                source:'spoonacular'
                                title:product.title
                                image:product.image
                                imageType:product.imageType
                                # type:product.type
                                # relevance:product.relevance
                                # content:product.content
                            # Meteor.call 'product_details', new_id, ->

                    # products = res.data.searchResults
                    
                    # console.log response.data.searchResults.results
            
            
if Meteor.isServer
    Meteor.publish 'product_facets', (
        picked_tags=[]
        name_search=''
        )->
    
            self = @
            match = {}
    
            # match.tags = $all: picked_tags
            match.model = $in:['product']
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
            if name_search.length > 1
                match.name = {$regex:"#{name_search}", $options: 'i'}

            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_tags.length > 0 then match.tags = $all: picked_tags
            # if picked_styles.length > 0 then match.strStyle = $all: picked_styles
            # if picked_moods.length > 0 then match.strMood = $all: picked_moods
            # if picked_genres.length > 0 then match.strGenre = $all: picked_genres

            total_count = Docs.find(match).count()
            # console.log 'total count', total_count
            # console.log 'facet match', match
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: '$tags', count: $sum: 1 }
                { $match: _id: $nin: picked_tags }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme tag_cloud, ', tag_cloud
            tag_cloud.forEach (tag, i) ->
                # console.log tag
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'tag'
                    index: i
                    
            self.ready()



    Meteor.publish 'product_results', (
        picked_tags=[]
        name_search=''
        )->
        self = @
        match = {}
        match.model = $in:['product']
        
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        if name_search.length > 1
            match.name = {$regex:"#{name_search}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        # unless Meteor.userId()
        #     match.private = $ne:true
            
        # console.log 'results match', match
        # console.log 'sort_key', sort_key
        # console.log 'sort_direction', sort_direction
        # console.log 'limit', limit
        
        Docs.find match,
            sort:_timestamp:-1
            limit:10
            # fields: 
            #     strArtistFanart:1
            #     strArtistThumb:1
            #     strArtistLogo:1
            #     strArtist:1
            #     strGenre:1
            #     strStyle:1
            #     strMood:1
            #     _timestamp:1
            #     model:1
            #     tags:1
