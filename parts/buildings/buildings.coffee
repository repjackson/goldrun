Router.route '/buildings', (->
    @layout 'layout'
    @render 'buildings'
    ), name:'buildings'


if Meteor.isClient
    Template.buildings.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'building'


    Template.building_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.building_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id




    Template.buildings.onRendered ->

    Template.buildings.helpers
        buildings: ->
            Docs.find {
                model:'building'
            }, sort:slug:1



    # Template.building_view.helpers
    #     units: ->
    #         Docs.find {
    #             model:'unit'
    #         }, sort: unit_number:1
    #             # building_slug:Router.current().params.building_code

    Template.buildings.events
        'mouseenter .building_card': (e,t)->
            t.$(e.currentTarget).closest('.building_card').addClass('raised')
        'mouseleave .building_card': (e,t)->
            t.$(e.currentTarget).closest('.building_card').removeClass('raised')



if Meteor.isServer
    Meteor.publish 'building', (building_code)->
        Docs.find
            model:'building'
            slug:building_code


    Meteor.publish 'building_units', (building_code)->
        Docs.find
            model:'unit'
            building_code:building_code
