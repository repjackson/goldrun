if Meteor.isClient
    Template.building_food.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'


    Template.building_food.helpers
        meals: ->
            Docs.find {
                model:'meal'
            }, sort:slug:1


    Template.building_food.events



# if Meteor.isServer
    # Meteor.publish 'building', (building_code)->
    #     Docs.find
    #         model:'building'
    #         slug:building_code
    #
    #
    # Meteor.publish 'building_units', (building_code)->
    #     Docs.find
    #         model:'unit'
    #         building_code:building_code
