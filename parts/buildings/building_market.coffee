if Meteor.isClient
    Template.building_market.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'children', 'building_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'building_docs', Router.current().params.doc_id, 'product'
        @autorun => Meteor.subscribe 'building_docs', Router.current().params.doc_id, 'service'

    Template.building_market.helpers
        building_products: ->
            Docs.find
                model:'product'
        building_services: ->
            Docs.find
                model:'service'

    Template.building_market.events
        'click .add_product': ->
            new_id =
                Docs.insert
                    model:'product'
                    building_id: Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"

        'click .add_service': ->
            new_id =
                Docs.insert
                    model:'service'
                    building_id: Router.current().params.doc_id
            Router.go "/service/#{new_id}/edit"

if Meteor.isServer
    Meteor.publish 'building_docs', (building_id, model)->
        Docs.find
            model:model
            building_id:building_id
