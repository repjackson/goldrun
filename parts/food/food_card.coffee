if Meteor.isClient
    Template.food_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.food_card.events
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

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',200)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}/")
            # Meteor.setTimeout =>
            # , 100

        'click .view_card': ->
            $('.container_')

    Template.food_card.helpers
        food_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
