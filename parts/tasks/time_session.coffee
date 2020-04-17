if Meteor.isClient
    Template.time_session_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000

    Template.time_session_card_template.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'log_events'
    Template.time_session_card_template.events
        'click .add_time_session_item': ->
            new_mi_id = Docs.insert
                model:'time_session_item'
            Router.go "/time_session/#{_id}/edit"
    Template.time_session_card_template.helpers
        result: ->
            if Docs.findOne @_id
                # console.log 'doc'
                result = Docs.findOne @_id
                if result.private is true
                    if result._author_id is Meteor.userId()
                        result
                else
                    result
            else if Meteor.users.findOne @_id
                # console.log 'user'
                Meteor.users.findOne @_id

        time_session_list: ->
            console.log @
            Docs.findOne
                model:'time_session_list'
                _id: @time_session_list_id


    Template.time_session_card_template.events




    Template.time_session_edit.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'log_events'
        @autorun => Meteor.subscribe 'model_docs', 'time_session_list'
    Template.time_session_edit.events
        'click .clear_time_session_list': ->
            time_session = Docs.findOne Router.current().params.doc_id
            Docs.update time_session._id,
                $unset:time_session_list_id:1
    Template.time_session_edit.helpers
        time_session_list: ->
            time_session = Docs.findOne Router.current().params.doc_id
            Docs.findOne
                _id: time_session.time_session_list_id
                model:'time_session_list'
        choices: ->
            Docs.find
                model:'choice'
                time_session_id:@_id
    Template.time_session_edit.events




    Template.time_session_view.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'log_event'
        @autorun => Meteor.subscribe 'child_docs', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'parent_doc', Router.current().params.doc_id
    Template.time_session_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000

    Template.time_session_view.helpers
        subtime_sessions: ->
            Docs.find
                model:'time_session'
                parent_id:Router.current().params.doc_id
        parent: ->
            current = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'time_session'
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
                    time_session_id: Router.current().params.doc_id
            if my_answer_session
                # console.log 'false'
                false
            else
                # console.log 'true'
                true

    Template.time_session_view.events
        'click .goto_task': (e,t)->
            time_session = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.grid').transition('fade up', 500)
            Meteor.setTimeout ->
                Router.go "/m/task/#{time_session.task_id}/view"
            , 400

        # 'click .new_time_session': ->
        #     new_id = Docs.insert
        #         model:'time_session'
        #         time_session_id: Router.current().params.doc_id
        #     Router.go "/m/time_session/#{new_id}/edit"
        # 'click .mark_complete': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             complete:true
        #     Docs.insert
        #         model:'log_event'
        #         parent_id: Router.current().params.doc_id
        #         text:"#{Meteor.user().username} marked time_session complete"
        #
        # 'click .mark_incomplete': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             complete:false
        #     Docs.insert
        #         model:'log_event'
        #         parent_id: Router.current().params.doc_id
        #         text:"#{Meteor.user().username} marked time_session incomplete"






if Meteor.isServer
    Meteor.methods
        refresh_time_session_stats: (time_session_id)->
            time_session = Docs.findOne time_session_id
            # console.log time_session
            reservations = Docs.find({model:'reservation', time_session_id:time_session_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_time_session_hours = 0
            average_time_session_duration = 0

            # shortime_session_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_time_session_hours += parseFloat(res.hour_duration)

            average_time_session_cost = total_earnings/reservation_count
            average_time_session_duration = total_time_session_hours/reservation_count

            Docs.update time_session_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_time_session_hours: total_time_session_hours.toFixed(0)
                    average_time_session_cost: average_time_session_cost.toFixed(0)
                    average_time_session_duration: average_time_session_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header time_session ranking #reservations
            # .ui.small.header time_session ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg time_session time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
