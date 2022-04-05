if Meteor.isClient
    Template.view_key.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
        @autorun -> Meteor.subscribe('key_checkouts', Router.current().params.doc_id)

    Template.view_key.helpers
        key: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id

        checkouts: ->
            if Session.get 'editing_id'
                Docs.find
                    _id: Session.get('editing_id')
            else
                Docs.find
                    model: 'key_checkout'

        checkout_cal: -> moment(@checkout_dt).calendar()
        checkin_cal: -> moment(@checkin_dt).calendar()

        is_editing: -> Session.equals 'editing_id', @_id

    Template.view_key.events
        'click #log_checkout': ->
            swal {
                title: "Checkout #{@building_code} ##{@apartment_number} Key?"
                model: 'info'
                animation: true
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Check Out'
                confirmButtonColor: '#da5347'
            }, =>
                new_id = Docs.insert
                    building_code: @building_code
                    apartment_number: @apartment_number
                    checkout_dt: Date.now()
                    model: 'key_checkout'
                Docs.update Router.current().params.doc_id,
                    $set: checked_out: true
                Session.set 'editing_id', new_id

        'click .edit_checkout': -> Session.set 'editing_id', @_id
        'click .stop_editing': -> Session.set 'editing_id', null

        'click #delete_checkout': ->
            swal {
                title: "Delete Checkout?"
                model: 'warning'
                animation: true
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, =>
                Docs.remove @_id
                Session.set 'editing_id', null

        'click .check_in_key': ->
            swal {
                title: "Check In #{@building_code} ##{@apartment_number} Key for #{@name}?"
                model: 'info'
                animation: true
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Check In'
                confirmButtonColor: '#da5347'
            }, =>
                Docs.update @_id,
                    $set: checkin_dt: Date.now()
                Docs.update Router.current().params.doc_id,
                    $set: checked_out: false
                swal "Checked In Key at #{Date.now()}", "",'success'



if Meteor.isServer
    Meteor.publish 'key_checkouts', (doc_id)->

        key = Docs.findOne doc_id

        self = @
        match = {}
        match.type = 'key_checkout'
        match.building_code = key.building_code
        match.apartment_number = key.apartment_number
        # if not @userId or not Roles.userIsInRole(@userId, ['admin'])
        #     match.published = true

        Docs.find match