if Meteor.isClient
    Router.route '/food/', (->
        @layout 'layout'
        @render 'food'
        ), name:'food'
    
    Template.food.events
        'click .call_food': ->
            Meteor.call 'call_food', (pizza)->
    Template.food.helpers
        food_docs: ->
            Docs.find 
                model:'food'
if Meteor.isServer
    Meteor.methods 
        call_food: (search)->
            # HTTP.get "https://api.spoonacular.com/mealplanner/generate?apiKey=e52f2f2ca01a448e944d94194e904775&timeFrame=day&targetCalories=#{calories}",(err,response)=>
            HTTP.get "https://api.spoonacular.com/food/search?apiKey=e52f2f2ca01a448e944d94194e904775&query=#{search}&number=2",(err,response)=>
                console.log response
            
