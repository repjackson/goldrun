# Router.route '/tasks', -> @render 'tasks'
Router.route '/votes/', -> @render 'votes'
Router.route '/vote/:doc_id/view', -> @render 'vote_view'
Router.route '/vote/:doc_id/edit', -> @render 'vote_edit'


if Meteor.isClient
    Template.votes.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'vote_stats'
        @autorun => Meteor.subscribe 'model_docs', 'vote_update'
        @autorun => Meteor.subscribe 'model_comments', 'vote'
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'vote'

    Template.vote_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id

    Template.vote_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.vote_card_template.onCreated ->
        @autorun => Meteor.subscribe 'children', 'vote_update', @data._id
    Template.vote_card_template.helpers
        updates: ->
            Docs.find
                model:'vote_update'
                parent_id: @_id


    Template.vote_view.onCreated ->
        @autorun => Meteor.subscribe 'children', 'vote_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'ballot_votes', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'vote_options', Router.current().params.doc_id
    Template.vote_view.helpers
        options: ->
            Docs.find
                model:'vote_option'
        votes: ->
            Docs.find
                model:'vote'
                ballot_id: Router.current().params.doc_id
    Template.vote_view.events
        'click .vote_yes': ->
            my_vote = Docs.findOne
                model:'vote'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_vote
                Docs.update my_vote._id,
                    $set:value:'yes'
            else
                Docs.insert
                    model:'vote'
                    ballot_id: Router.current().params.doc_id
                    value:'yes'
        'click .vote_no': ->
            my_vote = Docs.findOne
                model:'vote'
                _author_id: Meteor.userId()
                ballot_id: Router.current().params.doc_id
            if my_vote
                Docs.update my_vote._id,
                    $set:value:'no'
            else
                Docs.insert
                    model:'vote'
                    ballot_id: Router.current().params.doc_id
                    value:'no'

    Template.vote_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'vote_options', Router.current().params.doc_id
    Template.vote_edit.events
        'click .add_option': ->
            Docs.insert
                model:'vote_option'
                ballot_id: Router.current().params.doc_id
    Template.vote_edit.helpers
        options: ->
            Docs.find
                model:'vote_option'


    Template.votes.helpers
        votes: ->
            Docs.find
                model:'vote'
        latest_comments: ->
            Docs.find {
                model:'comment'
                parent_model:'vote'
            },
                limit:5
                sort:_timestamp:-1
        vote_stats_doc: ->
            Docs.findOne
                model:'vote_stats'

    Template.votes.events
        'click .add_vote': ->
            new_id = Docs.insert
                model:'vote'
            Router.go "/vote/#{new_id}/edit"

        'click .recalc_votes': ->
            Meteor.call 'recalc_votes', ->

    Template.latest_vote_updates.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'vote_update'

    Template.latest_vote_updates.helpers
        latest_updates: ->
            Docs.find {
                model:'vote_update'
            },
                limit:5
                sort:_timestamp:-1






if Meteor.isServer
    Meteor.publish 'current_poll', ()->
        Docs.find
            model:'vote'
            # current:true
    Meteor.publish 'ballot_votes', (ballot_id)->
        Docs.find
            model:'vote'
            ballot_id:ballot_id
    Meteor.publish 'vote_options', (ballot_id)->
        Docs.find
            model:'vote_option'
            ballot_id:ballot_id
    # Meteor.methods
        # recalc_votes: ->
        #     vote_stat_doc = Docs.findOne(model:'vote_stats')
        #     unless vote_stat_doc
        #         new_id = Docs.insert
        #             model:'vote_stats'
        #         vote_stat_doc = Docs.findOne(model:'vote_stats')
        #     console.log vote_stat_doc
        #     total_count = Docs.find(model:'vote').count()
        #     complete_count = Docs.find(model:'vote', complete:true).count()
        #     incomplete_count = Docs.find(model:'vote', complete:$ne:true).count()
        #     total_updates_count = Docs.find(model:'vote_update').count()
        #     Docs.update vote_stat_doc._id,
        #         $set:
        #             total_count:total_count
        #             complete_count:complete_count
        #             incomplete_count:incomplete_count
        #             total_updates_count:total_updates_count
