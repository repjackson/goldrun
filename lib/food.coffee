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
        @autorun => @subscribe 'model_docs', 'recipe', ->
        # @autorun => @subscribe 'model_docs', 'recipe', ->
    
    
    Template.food.events
        'keyup .food_search': (e,t)->
            query = t.$('.food_search').val()
            Session.set('food_search',query)
            if e.which is 13
                Meteor.call 'call_food', Session.get('food_search'), ->
            
    Template.food.helpers
        food_docs: ->
            Docs.find 
                model:'food'
        recipe_docs: ->
            Docs.find 
                model:'recipe'
if Meteor.isServer
    Meteor.methods 
        call_food: (search)->
            # HTTP.get "https://api.spoonacular.com/mealplanner/generate?apiKey=e52f2f2ca01a448e944d94194e904775&timeFrame=day&targetCalories=#{calories}",(err,response)=>
            HTTP.get "https://api.spoonacular.com/food/search?apiKey=e52f2f2ca01a448e944d94194e904775&query=#{search}&number=2",(err,response)=>
                # console.log response.data.searchResults
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
                                name:recipe.name
                                image:recipe.image
                                link:recipe.link
                                type:recipe.type
                                relevance:recipe.relevance
                                content:recipe.content
                        
                    # recipes = response.data.searchResults
                    
                    # console.log response.data.searchResults.results
            
