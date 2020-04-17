# Router.route '/tasks', -> @render 'tasks'
Router.route '/groups/', -> @render 'groups'
Router.route '/group/:doc_id/view', -> @render 'group_view'
Router.route '/group/:doc_id/edit', -> @render 'group_edit'


if Meteor.isClient
    Template.groups.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'group_stats'
        @autorun => Meteor.subscribe 'model_docs', 'group_update'
        @autorun => Meteor.subscribe 'model_comments', 'group'
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'group'

    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.group_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.group_card_template.onCreated ->
        @autorun => Meteor.subscribe 'children', 'group_update', @data._id
    Template.group_card_template.helpers
        updates: ->
            Docs.find
                model:'group_update'
                parent_id: @_id


    Template.group_view.onCreated ->
        @autorun => Meteor.subscribe 'children', 'group_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'ballot_groups', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_options', Router.current().params.doc_id
    Template.group_view.helpers
        options: ->
            Docs.find
                model:'group_option'
        groups: ->
            Docs.find
                model:'group'
                ballot_id: Router.current().params.doc_id
    Template.group_view.events
        'click .group_yes': ->
            my_group = Docs.findOne
                model:'group'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_group
                Docs.update my_group._id,
                    $set:value:'yes'
            else
                Docs.insert
                    model:'group'
                    ballot_id: Router.current().params.doc_id
                    value:'yes'
        'click .group_no': ->
            my_group = Docs.findOne
                model:'group'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_group
                Docs.update my_group._id,
                    $set:value:'no'
            else
                Docs.insert
                    model:'group'
                    ballot_id: Router.current().params.doc_id
                    value:'no'

    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_options', Router.current().params.doc_id
    Template.group_edit.events
        'click .add_option': ->
            Docs.insert
                model:'group_option'
                ballot_id: Router.current().params.doc_id
    Template.group_edit.helpers
        options: ->
            Docs.find
                model:'group_option'


    Template.groups.helpers
        groups: ->
            Docs.find
                model:'group'
        latest_comments: ->
            Docs.find {
                model:'comment'
                parent_model:'group'
            },
                limit:5
                sort:_timestamp:-1
        group_stats_doc: ->
            Docs.findOne
                model:'group_stats'

    Template.groups.events
        'click .add_group': ->
            new_id = Docs.insert
                model:'group'
            Router.go "/group/#{new_id}/edit"

        'click .recalc_groups': ->
            Meteor.call 'recalc_groups', ->

    # Template.latest_group_updates.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'group_update'
    #
    # Template.latest_group_updates.helpers
    #     latest_updates: ->
    #         Docs.find {
    #             model:'group_update'
    #         },
    #             limit:5
    #             sort:_timestamp:-1
    #
    #


    Template.groups_small.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs', 'group'
    Template.groups_small.helpers
        groups: ->
            Docs.find {
                model:'group'
            },
                sort: _timestamp: -1
                limit:5



if Meteor.isServer
    Meteor.publish 'ballot_groups', (ballot_id)->
        Docs.find
            model:'group'
            ballot_id:ballot_id
    Meteor.publish 'group_options', (ballot_id)->
        Docs.find
            model:'group_option'
            ballot_id:ballot_id
    # Meteor.methods
        # recalc_groups: ->
        #     group_stat_doc = Docs.findOne(model:'group_stats')
        #     unless group_stat_doc
        #         new_id = Docs.insert
        #             model:'group_stats'
        #         group_stat_doc = Docs.findOne(model:'group_stats')
        #     console.log group_stat_doc
        #     total_count = Docs.find(model:'group').count()
        #     complete_count = Docs.find(model:'group', complete:true).count()
        #     incomplete_count = Docs.find(model:'group', complete:$ne:true).count()
        #     total_updates_count = Docs.find(model:'group_update').count()
        #     Docs.update group_stat_doc._id,
        #         $set:
        #             total_count:total_count
        #             complete_count:complete_count
        #             incomplete_count:incomplete_count
        #             total_updates_count:total_updates_count
