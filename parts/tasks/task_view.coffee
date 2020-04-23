if Meteor.isClient
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'log_event'
        @autorun => Meteor.subscribe 'model_docs', 'task_list'
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'time_session'
    Template.task_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.task_view.helpers
        time_sessions: ->
            Docs.find
                model:'time_session'
                task_id:Router.current().params.doc_id
        subtasks: ->
            Docs.find
                model:'task'
                parent_id:Router.current().params.doc_id
        parent: ->
            current = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'task'
                _id:current.parent_id
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id
        can_accept: ->
            # console.log @
            my_answer_session =
                Docs.findOne
                    model:'answer_session'
                    task_id: Router.current().params.doc_id
            if my_answer_session
                # console.log 'false'
                false
            else
                # console.log 'true'
                true

    Template.task_view.events
        'click .new_time_session': ->
            new_id = Docs.insert
                model:'time_session'
                task_id: Router.current().params.doc_id
            Router.go "/m/time_session/#{new_id}/edit"
        'click .new_subtask': ->
            Docs.insert
                model:'task'
                parent_id: Router.current().params.doc_id
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked task complete"

        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:false
            Docs.insert
                model:'log_event'
                parent_id: Router.current().params.doc_id
                text:"#{Meteor.user().username} marked task incomplete"


        'click .goto_tasks': (e,t)->
            $(e.currentTarget).closest('.grid').transition('fade left', 500)
            Meteor.setTimeout =>
                Router.go "/tasks"
            , 500
