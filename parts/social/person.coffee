# Router.route '/person/:doc_id/view', -> @render 'person_view'
# Router.route '/person/:doc_id/edit', -> @render 'person_edit'


if Meteor.isClient
    # Template.person_view.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.person_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000


    Template.person_view.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.person_card_template.onCreated ->
        @autorun => Meteor.subscribe 'children', 'person_update', @data._id
    Template.person_card_template.helpers
        updates: ->
            Docs.find
                model:'person_update'
                parent_id: @_id


    Template.person_view.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'person_update', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ballot_persons', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'person_options', Router.current().params.doc_id
    Template.person_view.helpers
        options: ->
            Docs.find
                model:'person_option'
        persons: ->
            Docs.find
                model:'person'
                ballot_id: Router.current().params.doc_id

    # Template.person_edit.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    #     @autorun => Meteor.subscribe 'person_options', Router.current().params.doc_id
    # Template.person_edit.events
    #     'click .add_option': ->
    #         Docs.insert
    #             model:'person_option'
    #             ballot_id: Router.current().params.doc_id
    # Template.person_edit.helpers
    #     options: ->
    #         Docs.find
    #             model:'person_option'


    # Template.latest_person_updates.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'person_update'
    #
    # Template.latest_person_updates.helpers
    #     latest_updates: ->
    #         Docs.find {
    #             model:'person_update'
    #         },
    #             limit:5
    #             sort:_timestamp:-1
    #
    #




if Meteor.isServer
    Meteor.publish 'ballot_persons', (ballot_id)->
        Docs.find
            model:'person'
            ballot_id:ballot_id
    Meteor.publish 'person_options', (ballot_id)->
        Docs.find
            model:'person_option'
            ballot_id:ballot_id
    # Meteor.methods
        # recalc_persons: ->
        #     person_stat_doc = Docs.findOne(model:'person_stats')
        #     unless person_stat_doc
        #         new_id = Docs.insert
        #             model:'person_stats'
        #         person_stat_doc = Docs.findOne(model:'person_stats')
        #     console.log person_stat_doc
        #     total_count = Docs.find(model:'person').count()
        #     complete_count = Docs.find(model:'person', complete:true).count()
        #     incomplete_count = Docs.find(model:'person', complete:$ne:true).count()
        #     total_updates_count = Docs.find(model:'person_update').count()
        #     Docs.update person_stat_doc._id,
        #         $set:
        #             total_count:total_count
        #             complete_count:complete_count
        #             incomplete_count:incomplete_count
        #             total_updates_count:total_updates_count
