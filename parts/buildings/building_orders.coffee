if Meteor.isClient
    Template.building_orders.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'order'
        @autorun => Meteor.subscribe 'model_docs', 'meal'


    Template.building_orders.helpers
        orders: ->
            Docs.find {
                model:'order'
            }, sort:slug:1


    Template.building_orders.events



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
