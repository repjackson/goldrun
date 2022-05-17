if Meteor.isClient
    Template.task_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->
    Template.task_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->

    Template.task_card.events
        'click .view_task': ->
            Router.go "/doc/#{@_id}"
    Template.task_item.events
        'click .view_task': ->
            Router.go "/doc/#{@_id}"

    
    
    Template.task_edit.events
        'click .delete_task': ->
            Docs.remove @_id
            Router.go "/docs"



if Meteor.isClient
    Template.task_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.task_card.events
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
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.task_card.helpers
        task_card_class: ->
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
            