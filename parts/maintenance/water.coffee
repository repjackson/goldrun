Router.route '/readings',-> @render 'readings'
# Router.route '/readings/lower', -> @render 'lower_hot_tub_readings'
# Router.route '/readings/upper', -> @render 'upper_hot_tub_readings'
# Router.route '/readings/pool', -> @render 'pool_readings'
Router.route '/pool_reading/edit/:doc_id', -> @render 'edit_pool_reading'
Router.route '/lower_hot_tub_reading/edit/:doc_id', -> @render 'edit_lower_hot_tub_reading'
Router.route '/upper_hot_tub_reading/edit/:doc_id', -> @render 'edit_upper_hot_tub_reading'


if Meteor.isClient
    Template.readings.onRendered ->
        # Meteor.setTimeout (->
        #     $('table').tablesort()
        # ), 500

    Template.readings.onCreated ->
        @autorun -> Meteor.subscribe('users_by_role','staff')

        @autorun -> Meteor.subscribe('lower_hot_tub_readings')
        @autorun -> Meteor.subscribe('upper_hot_tub_readings')
        @autorun -> Meteor.subscribe('pool_readings')
    Template.lower_hot_tub_readings.onCreated ->
        @autorun -> Meteor.subscribe('lower_hot_tub_readings')
    Template.upper_hot_tub_readings.onCreated ->
        @autorun -> Meteor.subscribe('upper_hot_tub_readings')
    Template.pool_readings.onCreated ->
        @autorun -> Meteor.subscribe('pool_readings')
    Template.edit_pool_reading.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
    Template.edit_lower_hot_tub_reading.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)
    Template.edit_upper_hot_tub_reading.onCreated ->
        @autorun -> Meteor.subscribe('doc', Router.current().params.doc_id)

    Template.lower_hot_tub_readings.helpers
        lower_hot_tub_readings: ->
            Docs.find {
                model:'lower_hot_tub_reading'
            }, sort:_timestamp:-1

    Template.upper_hot_tub_readings.helpers
        upper_hot_tub_readings: ->
            Docs.find {
                model:'upper_hot_tub_reading'
            }, sort:_timestamp:-1

    Template.pool_readings.helpers
        pool_readings: ->
            Docs.find {
                model: 'pool_reading'
            }, sort:_timestamp:-1

    Template.readings.events
        'click #add_pool_reading': ->
            id = Docs.insert
                model: 'pool_reading'
            Router.go "/pool_reading/edit/#{id}"
        'click #add_upper_hot_tub_reading': ->
            id = Docs.insert
                model: 'upper_hot_tub_reading'
            Router.go "/upper_hot_tub_reading/edit/#{id}"
        'click #add_lower_hot_tub_reading': ->
            id = Docs.insert
                model: 'lower_hot_tub_reading'
            Router.go "/lower_hot_tub_reading/edit/#{id}"



    Template.ph.events
        'blur #ph': (e,t)->
            ph = parseFloat $(e.currentTarget).closest('#ph').val()
            Docs.update @_id,
                $set: ph: ph
            ph_message =
                switch
                    when ph < 6.5 then 'add 3/4 tb soda ash.  retest in one hour.'
                    when ph < 6.7 then 'add 3/4 tb soda ash.'
                    when ph < 6.9 then 'add 1/2 tb soda ash.'
                    when ph < 7.1 then 'add 1/4 tb soda ash.  retest in one hour.'
                    when ph < 7.4 then 'no adjustment neccessary.'
                    when ph < 7.6 then 'add 1/4tb muriatic acid'
                    when ph < 7.8 then 'add 1/2tb muriatic acid.'
                    when ph < 8.0 then 'add 3/4tb muriatic acid.'
                    when ph >= 8.0 then 'close hot tub until drained and refilled.'
                    else ''
            Docs.update @_id,
                $set: ph_message: ph_message

    Template.indoor_ph.events
        'blur #ph': (e,t)->
            ph = parseFloat $(e.currentTarget).closest('#ph').val()
            Docs.update @_id,
                $set: ph: ph
            ph_message =
                switch
                    when ph < 6.5 then 'add 8oz soda ash.  retest in one hour.'
                    when ph < 6.7 then 'add 6oz soda ash.'
                    when ph < 6.9 then 'add 4oz soda ash.'
                    when ph < 7.1 then 'add 2oz soda ash.  retest in one hour.'
                    when ph < 7.4 then 'no adjustment needed.'
                    when ph < 7.6 then 'add 1tb muriatic acid'
                    when ph < 7.8 then 'add 2tb muriatic acid.'
                    when ph < 8.0 then 'add 3tb muriatic acid.'
                    when ph >= 8.0 then 'add 3tb muriatic acid, retest in 1 hour.'
                    else ''
            Docs.update @_id,
                $set: ph_message: ph_message


    Template.pool_ph.events
        'blur #ph': (e,t)->
            ph = parseFloat $(e.currentTarget).closest('#ph').val()
            Docs.update @_id,
                $set: ph: ph
            ph_message =
                switch
                    when ph < 6.5 then 'add 36oz soda ash, close pool, retest in one hour'
                    when ph < 6.7 then 'add 36oz soda ash'
                    when ph < 6.9 then 'add 24oz soda ash'
                    when ph < 7.1 then 'add 12oz soda ash, retest in one hour'
                    when ph < 7.4 then 'no adjustment needed'
                    when ph < 7.6 then 'add 12oz muriatic acid'
                    when ph < 7.8 then 'add 24oz muriatic acid'
                    when ph < 8.0 then 'add 36oz muriatic acid'
                    when ph >= 8.0 then 'add 36oz muriatic acid, close pool, retest in two hours'
                    else ''
            Docs.update @_id,
                $set: ph_message: ph_message



    Template.pool_chlorine.events
        'blur #chlorine': (e,t)->
            chlorine = parseFloat $(e.currentTarget).closest('#chlorine').val()
            Docs.update @_id,
                $set: chlorine: chlorine
            chlorine_message =
                switch
                    when chlorine <= 1 then 'add 10 ounces chlorine granules.  retest in one hour.'
                    when chlorine < 2 then 'add 5 ounces chlorine granules'
                    when chlorine < 4.9 then 'no adjustment neccessary'
                    when chlorine >= 5 then 'close pool. retest in two hours'
                    else ''
            Docs.update @_id,
                $set: chlorine_message: chlorine_message



    Template.chlorine.events
        'blur #chlorine': (e,t)->
            chlorine = parseFloat $(e.currentTarget).closest('#chlorine').val()
            Docs.update @_id,
                $set: chlorine: chlorine
            chlorine_message =
                switch
                    when chlorine <= 1 then 'add 1/2tb chlorine granules.  retest in one hour.'
                    when chlorine < 2 then 'add 1/4 ounces chlorine granules'
                    when chlorine < 4.9 then 'no adjustment needed'
                    when chlorine >= 5 then 'close hot tub. uncover and turn on jets, retest in two hours'
                    else ''
            Docs.update @_id,
                $set: chlorine_message: chlorine_message



    Template.indoor_chlorine.events
        'blur #chlorine': (e,t)->
            chlorine = parseFloat $(e.currentTarget).closest('#chlorine').val()
            Docs.update @_id,
                $set: chlorine: chlorine
            chlorine_message =
                switch
                    when chlorine <= 1 then 'add 1.5tb chlorine granules, retest in 1hr'
                    when chlorine < 2 then 'add 3/4 ounces chlorine granules, retest in 1hr'
                    when chlorine < 4.9 then 'no adjustment needed'
                    when chlorine >= 5 then 'close hot tub, turn on jets to circulate, retest in two hours'
                    else ''
            Docs.update @_id,
                $set: chlorine_message: chlorine_message





    Template.temperature.events
        'blur #temperature': (e,t)->
            temperature = parseFloat $(e.currentTarget).closest('#temperature').val()
            Docs.update @_id,
                $set: temperature: temperature


    Template.delete_reading_button.events
        'click #delete_reading': (e,t)->
            swal {
                title: 'Delete Reading?'
                # text: 'Confirm delete?'
                model: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove Router.current().params.doc_id, ->
                    Router.go "/readings"







if Meteor.isServer
    Meteor.publish 'upper_hot_tub_readings', ()->
        self = @
        match = {}
        Docs.find {model:'upper_hot_tub_reading'},
            limit: 10
            sort:
                _timestamp: -1

    Meteor.publish 'lower_hot_tub_readings', ()->
        self = @
        match = {}
        Docs.find {model:'lower_hot_tub_reading'},
            limit: 10
            sort:
                _timestamp: -1

    Meteor.publish 'pool_readings', ()->
        self = @
        match = {}
        Docs.find {model:'pool_reading'},
            limit: 10
            sort:
                _timestamp: -1
