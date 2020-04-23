if Meteor.isClient
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'task_list'
    Template.task_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.task_edit.events
        'click .clear_task_list': ->
            task = Docs.findOne Router.current().params.doc_id
            Docs.update task._id,
                $unset:task_list_id:1
    Template.task_edit.helpers
        task_list: ->
            task = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                _id: task.task_list_id
                model:'task_list'
        choices: ->
            Docs.find
                model:'choice'
                task_id:@_id
    Template.task_edit.events
