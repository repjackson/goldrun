Router.route '/units', -> @render 'units'
Router.route '/unit/:doc_id', -> @render 'unit_view'
Router.route '/unit/:doc_id/edit', -> @render 'unit_edit'


if Meteor.isClient
    Template.units.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'unit', ->
    Template.unit_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.unit_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
            
    Template.unit_owners.onCreated ->
        @autorun => Meteor.subscribe 'unit_owners', Router.current().params.doc_id
    Template.unit_permits.onCreated ->
        @autorun => Meteor.subscribe 'unit_permits', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'unit_units', Router.current().params.unit_code


    Template.units.events
        'click .add_unit': ->
            new_id = 
                Docs.insert 
                    model:'unit'
            Router.go "/unit/#{new_id}/edit"
            
            
    Template.units.helpers
        unit_docs: ->
            Docs.find 
                model:'unit'
                
                
                

                
    Template.unit_owners.helpers
        owners: ->
            unit =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if unit
                Meteor.users.find
                    owner:true
                    # roles:$in:['owner']
                    building_number:unit.building_number
                    unit_number:unit.unit_number

    Template.unit_residents.onCreated ->
        @autorun => Meteor.subscribe 'unit_residents', Router.current().params.doc_id
    Template.unit_residents.helpers
        unit_resident_docs: ->
            unit =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if unit
                Meteor.users.find
                    # roles:$in:['resident','owner']
                    # owner:$ne:true
                    building_number:unit.building_number
                    unit_number:unit.unit_number


    Template.unit_permits.helpers
        permits: ->
            unit =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if unit
                Docs.find
                    model: 'parking_permit'
                    address_number:unit.building_number


    Template.unit_view.helpers
        unit: ->
            Docs.findOne
                model:'unit'
                slug: Router.current().params.unit_code

        units: ->
            Docs.find {
                model:'unit'
            }, sort: unit_number:1
                # unit_slug:Router.current().params.unit_code

    Template.unit_view.events
        'keyup .unit_number': (e,t)->
            if e.which is 13
                unit_number = parseInt $('.unit_number').val().trim()
                unit_number = parseInt $('.unit_number').val()
                unit_label = $('.unit_label').val().trim()
                unit = Docs.findOne model:'unit'
                Docs.insert
                    model:'unit'
                    unit_number:unit_number
                    unit_number:unit.unit_number
                    unit_code:unit.slug



    Template.user_key.onCreated ->
        @autorun => Meteor.subscribe 'user_key', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'unit_key_access'
    Template.user_key.helpers
        key: -> Docs.findOne model:'key'
        viewing_code: -> Session.get 'viewing_code'
        access_log: ->
            Docs.find {
                model:'unit_key_access'
                key_id:Docs.findOne(model:'key')._id
            }, sort:_timestamp:-1
    Template.user_key.events
        'click .view_code': ->
            access = prompt 'admin code'
            if access is '2959'
                Session.set 'viewing_code', true
                Meteor.setTimeout ->
                    Session.set 'viewing_code', false
                , 5000
                new_id = Docs.insert
                    model:'unit_key_access'
                    key_id:Docs.findOne(model:'key')._id
                    owner_user_id:Meteor.users.findOne username:Router.current().params.username
                    owner_username:Router.current().params.username
            else
                alert 'wrong code'










    Template.unit_card.onCreated ->
        @autorun => Meteor.subscribe 'unit_residents', @data._id
        @autorun => Meteor.subscribe 'unit_owners', @data._id
        @autorun => Meteor.subscribe 'unit_permits', @data._id
        # @autorun => Meteor.subscribe 'unit_units', Router.current().params.unit_code

    Template.unit_card.helpers
        owners: ->
            Meteor.users.find
                roles:$in:['owner']
                building_number:@building_number
                unit_number:@unit_number

        residents: ->
            Meteor.users.find
                roles:$in:['resident','owner']
                owner:$ne:true
                building_number:@building_number
                unit_number:@unit_number

        permits: ->
            Docs.find
                model: 'parking_permit'
                address_number:@building_number






if Meteor.isServer
    Meteor.publish 'unit', (unit_code)->
        Docs.find
            model:'unit'
            slug:unit_code


    Meteor.publish 'unit_units', (unit_code)->
        Docs.find
            model:'unit'
            unit_code:unit_code


    Meteor.publish 'unit_owners', (unit_id)->
        unit =
            Docs.findOne
                _id:unit_id
        if unit
            Meteor.users.find
                # roles:$in:['owner']
                owner:true
                building_number:unit.building_number
                unit_number:unit.unit_number

    Meteor.publish 'unit_residents', (unit_id)->
        unit =
            Docs.findOne
                _id:unit_id
        if unit
            Meteor.users.find
                # roles:$in:['resident']
                building_number:unit.building_number
                unit_number:unit.unit_number

    Meteor.publish 'unit_permits', (unit_id)->
        unit =
            Docs.findOne
                _id:unit_id
        Docs.find
            model: 'parking_permit'
            address_number:unit.building_number
    Meteor.publish 'user_key', (unit_id)->
        unit = Docs.findOne unit_id
        Docs.find
            model:'key'
            building_number:unit.building_number
            unit_number:unit.unit_number