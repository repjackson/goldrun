Router.route '/buildings', -> @render 'buildings'


if Meteor.isClient
    Template.buildings.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'building'
    Template.building.onCreated ->
        @autorun => Meteor.subscribe 'building', Router.current().params.building_code
        @autorun => Meteor.subscribe 'building_units', Router.current().params.building_code

    Template.buildings.onRendered ->

    Template.buildings.helpers
        buildings: ->
            Docs.find {
                model:'building'
            }, sort:slug:1



    Template.building.helpers
        building: ->
            Docs.findOne
                model:'building'
                slug: Router.current().params.building_code

        units: ->
            Docs.find {
                model:'unit'
            }, sort: unit_number:1
                # building_slug:Router.current().params.building_code

    Template.buildings.events
        'mouseenter .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').addClass('raised')
        'mouseleave .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').removeClass('raised')


    Template.building.events
        'keyup .unit_number': (e,t)->
            if e.which is 13
                unit_number = parseInt $('.unit_number').val().trim()
                building_number = parseInt $('.building_number').val()
                building_label = $('.building_label').val().trim()
                building = Docs.findOne model:'building'
                Docs.insert
                    model:'unit'
                    unit_number:unit_number
                    building_number:building_number
                    building_number:building_number
                    building_code:building_label

        'keyup .building_search': (e,t)->
            username_query = $('.username_search').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                if username_query.length > 1
                    # audio = new Audio('wargames.wav');
                    # audio.play();
                    Session.set 'username_query',username_query




if Meteor.isServer
    Meteor.publish 'building', (building_code)->
        Docs.find
            model:'building'
            slug:building_code


    Meteor.publish 'building_units', (building_code)->
        Docs.find
            model:'unit'
            building_code:building_code
