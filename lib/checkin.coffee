Router.route '/checkins', -> @render 'checkins'
Router.route '/checkin/:doc_id', -> @render 'checkin_view'
Router.route '/checkin/:doc_id/edit', -> @render 'checkin_edit'


if Meteor.isClient
    Template.checkins.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'checkin', ->
    Template.checkin_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.checkin_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            

    Template.checkins.events
        'click .add_checkin': ->
            new_id = 
                Docs.insert 
                    model:'checkin'
            Router.go "/checkin/#{new_id}/edit"
            
            
    Template.checkins.helpers
        checkin_docs: ->
            Docs.find 
                model:'checkin'
                
                
                

    Template.checkin_view.helpers
        checkin: ->
            Docs.findOne
                model:'checkin'
                slug: Router.current().params.checkin_code

        checkins: ->
            Docs.find {
                model:'checkin'
            }, sort: checkin_number:1
                # checkin_slug:Router.current().params.checkin_code

    Template.checkin_view.events
        'keyup .checkin_number': (e,t)->
            if e.which is 13
                checkin_number = parseInt $('.checkin_number').val().trim()
                checkin_number = parseInt $('.checkin_number').val()
                checkin_label = $('.checkin_label').val().trim()
                checkin = Docs.findOne model:'checkin'
                Docs.insert
                    model:'checkin'
                    checkin_number:checkin_number
                    checkin_number:checkin.checkin_number
                    checkin_code:checkin.slug




    Template.checkin_card.onCreated ->
        @autorun => Meteor.subscribe 'checkin_residents', @data._id
        @autorun => Meteor.subscribe 'checkin_owners', @data._id
        @autorun => Meteor.subscribe 'checkin_permits', @data._id
        # @autorun => Meteor.subscribe 'checkin_checkins', Router.current().params.checkin_code

    Template.checkin_card.helpers
        owners: ->
            Meteor.users.find
                roles:$in:['owner']
                building_number:@building_number
                checkin_number:@checkin_number

        residents: ->
            Meteor.users.find
                roles:$in:['resident','owner']
                owner:$ne:true
                building_number:@building_number
                checkin_number:@checkin_number

        permits: ->
            Docs.find
                model: 'parking_permit'
                address_number:@building_number






if Meteor.isServer
    Meteor.publish 'checkin', (checkin_code)->
        Docs.find
            model:'checkin'
            slug:checkin_code



    Meteor.publish 'checkin_residents', (checkin_id)->
        checkin =
            Docs.findOne
                _id:checkin_id
        if checkin
            Meteor.users.find
                roles:$in:['resident']
                building_number:checkin.building_number
                checkin_number:checkin.checkin_number