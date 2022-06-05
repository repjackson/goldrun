if Meteor.isClient
    Router.route '/food/', (->
        @layout 'layout'
        @render 'food'
        ), name:'food'
    Router.route '/food/:doc_id', (->
        @layout 'layout'
        @render 'food_page'
        ), name:'food_page'
    
    Template.food_page.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.food.onCreated ->
        # @autorun => @subscribe 'model_docs','artist', ->
        @autorun => @subscribe 'food_facets',
            picked_tags.array()
            Session.get('title')
            # picked_tags.array()
            # picked_styles.array()
            # picked_moods.array()
            # picked_genres.array()
            # Session.get('artist_search')
            # picked_timestamp_tags.array()
        @autorun => @subscribe 'food_results',
            picked_tags.array()
            Session.get('title')
            # picked_tags.array()
            # picked_styles.array()
            # picked_moods.array()
            # picked_genres.array()
            # Session.get('artist_search')
            # Session.get('sort_key')
            # Session.get('sort_direction')
            # Session.get('limit')
    
    
    Template.food_page.events
        'click .pick_food_tag': ->
            Router.go "/food"
            Meteor.call 'call_food', @valueOf(), ->
    Template.food.events
        'keyup .food_search': (e,t)->
            console.log 'hi'
            query = t.$('.food_search').val()
            Session.set('food_search',query)
            if e.which is 13
                Meteor.call 'call_food', Session.get('food_search'), ->
            
    Template.food.helpers
        food_docs: ->
            Docs.find 
                model:'food'
        recipe_docs: ->
            Docs.find {
                model:'recipe'
            }, sort:_timestamp:-1
            
        picked_tags: -> picked_tags.array()
        tag_results: ->
            Results.find()
        
    Template.food.events 
        'click .pick_tag': ->
            picked_tags.push @name
        'click .unpick_tag': ->
            picked_tags.remove @valueOf()
        
    Template.delete_button.events 
        'click .delete_this': ->
            if confirm 'delete?'
                Docs.remove @_id
            
            
            
if Meteor.isServer
    Meteor.methods 
        call_food: (search)->
            # console.log 'calling'
            # HTTP.get "https://api.spoonacular.com/mealplanner/generate?apiKey=e52f2f2ca01a448e944d94194e904775&timeFrame=day&targetCalories=#{calories}",(err,response)=>
            HTTP.get "https://api.spoonacular.com/food/search?apiKey=e52f2f2ca01a448e944d94194e904775&query=#{search}&number=2",(err,response)=>
                console.log response.data.searchResults
                for result in response.data.searchResults
                    # console.log result.name
                    # if result.name is 'Recipes'
                    recipes = _.where(response.data.searchResults, {name:'Recipes'})
                    for recipe in recipes[0].results
                        console.log recipe
                        found_recipe = 
                            Docs.findOne 
                                model:'recipe'
                                id:recipe.id
                        if found_recipe
                            Docs.update found_recipe._id, 
                                $inc:hits:1
                        unless found_recipe
                            Docs.insert 
                                model:'recipe'
                                id:recipe.id
                                name:recipe.name
                                image:recipe.image
                                link:recipe.link
                                type:recipe.type
                                relevance:recipe.relevance
                                content:recipe.content
                        
                    # recipes = response.data.searchResults
                    
                    # console.log response.data.searchResults.results
            
            
if Meteor.isServer
    Meteor.publish 'food_facets', (
        picked_tags=[]
        name_search=''
        )->
    
            self = @
            match = {}
    
            # match.tags = $all: picked_tags
            match.model = $in:['recipe']
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



    Meteor.publish 'food_results', (
        picked_tags=[]
        name_search=''
        )->
        self = @
        match = {}
        match.model = $in:['recipe']
        
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
