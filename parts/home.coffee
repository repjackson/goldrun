if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'

    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id


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
