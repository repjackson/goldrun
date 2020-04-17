if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'

    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'schema', Router.current().params.doc_id


    Template.detect.events
        'click .detect_fields': ->
            # console.log @
            Meteor.call 'detect_fields', @_id

    Template.home.events
        'click .calc_similar': ->
            console.log @
            Meteor.call 'calc_similar', @_id

        'click .gt_tasks': (e,t)->
            $(e.currentTarget).closest('.card').transition('zoom', 500)
            $(e.currentTarget).closest('.cards').transition('scale', 500)
            Meteor.setTimeout ->
                Router.go "/tasks"
            , 500


    # Template.key_view.helpers
    #     key: -> @valueOf()
    #
    #     meta: ->
    #         key_string = @




    Template.revenue_calculator.onCreated ->
        @autorun => Meteor.subscribe 'member_revenue_calculator_doc', Router.current().params.username
    Template.revenue_calculator.helpers
        calculator_doc: ->
            Docs.findOne
                model:'calculator_doc'
                member_username:Router.current().params.username
        calculated_daily_revenue: ->
            cd =
                Docs.findOne
                    model:'calculator_doc'
                    member_username:Router.current().params.username
            cd.rental_amount*cd.average_hourly*cd.daily_hours_rented
        calculated_weekly_revenue: ->
            cd =
                Docs.findOne
                    model:'calculator_doc'
                    member_username:Router.current().params.username
            cd.rental_amount*cd.average_hourly*cd.daily_hours_rented*7
