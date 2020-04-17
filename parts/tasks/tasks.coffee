if Meteor.isClient
    Router.route '/tasks', (->
        @layout 'layout'
        @render 'tasks'
        ), name:'tasks'
    Router.route '/task/:doc_id/edit', (->
        @layout 'layout'
        @render 'task_edit'
        ), name:'task_edit'
    Router.route '/task/:doc_id/view', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'



    Template.tasks.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'task'
        @autorun -> Meteor.subscribe('tasks',
            selected_tags.array()
            Session.get('view_complete')
            Session.get('view_incomplete')
            )
        @autorun => Meteor.subscribe 'model_docs', 'tasks_stats'
        @autorun => Meteor.subscribe 'current_tasks'
    Template.tasks.events
        'click .toggle_complete': ->
            Session.set('view_complete', !Session.get('view_complete'))
        'click .new_task': (e,t)->
            new_task_id =
                Docs.insert
                    model:'task'
            Session.set('editing_task', true)
            Session.set('selected_task_id', new_task_id)
        'click .unselect_task': ->
            Session.set('selected_task_id', null)

    Template.tasks.helpers
        view_complete_class: ->
            if Session.get('view_complete') then 'blue' else ''
        selected_task_doc: ->
            Docs.findOne Session.get('selected_task_id')
        current_tasks: ->
            Docs.find
                model:'task'
                current:true
        tasks_stats_doc: ->
            Docs.findOne
                model:'tasks_stats'
        tasks: ->
            Docs.find
                model:'task'




    Template.selected_task.events
        'click .delete_task': ->
            if confirm 'delete task?'
                Docs.remove @_id
                Session.set('selected_task_id', null)
        'click .save_task': ->
            Session.set('editing_task', false)
        'click .edit_task': ->
            Session.set('editing_task', true)
        'click .goto_task': (e,t)->
            console.log @
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/task/#{@_id}/view"
            , 500

    Template.selected_task.helpers
        editing_task: -> Session.get('editing_task')










    Template.task_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.task_card_template.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'log_events'
    Template.task_card_template.events
        'click .add_task_item': ->
            new_mi_id = Docs.insert
                model:'task_item'
            Router.go "/task/#{_id}/edit"
    Template.task_card_template.helpers
        task_segment_class: ->
            classes=''
            if @complete
                classes += ' green'
            if Session.equals('selected_task_id', @_id)
                classes += ' inverted blue'
            classes
        task_list: ->
            # console.log @
            Docs.findOne
                model:'task_list'
                _id: @task_list_id


    Template.task_card_template.events
        'click .select_task': ->
            if Session.equals('selected_task_id',@_id)
                Session.set 'selected_task_id', null
            else
                Session.set 'selected_task_id', @_id
        'click .goto_task': (e,t)->
            console.log @
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/task/#{@_id}/view"
            , 500







if Meteor.isServer
    Meteor.methods
        refresh_task_stats: (task_id)->
            task = Docs.findOne task_id
            # console.log task
            reservations = Docs.find({model:'reservation', task_id:task_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_task_hours = 0
            average_task_duration = 0

            # shortask_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_task_hours += parseFloat(res.hour_duration)

            average_task_cost = total_earnings/reservation_count
            average_task_duration = total_task_hours/reservation_count

            Docs.update task_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_task_hours: total_task_hours.toFixed(0)
                    average_task_cost: average_task_cost.toFixed(0)
                    average_task_duration: average_task_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header task ranking #reservations
            # .ui.small.header task ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg task time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
    Meteor.publish 'tasks', (
        selected_tags
        view_complete
        )->
        # user = Meteor.users.findOne @userId
        # console.log selected_tags
        # console.log filter
        self = @
        match = {}
        if view_complete
            match.complete = true
        # if Meteor.user()
        #     unless Meteor.user().roles and 'dev' in Meteor.user().roles
        #         match.view_roles = $in:Meteor.user().roles
        # else
        #     match.view_roles = $in:['public']

        # if filter is 'shop'
        #     match.active = true
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # if filter then match.model = filter
        match.model = 'task'

        Docs.find match, sort:_timestamp:-1
