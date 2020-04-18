if Meteor.isClient
    Template.meal_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'meal'
    Template.meal_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_meal': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',200)
            # $('.global_container').transition('scale', 500)
            Router.go("/meal/#{@_id}/view")
            # Meteor.setTimeout =>
            # , 100

        'click .view_card': ->
            $('.container_')

    Template.meal_card.helpers
        meal_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        meals: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'meal'
            }, sort:title:1
