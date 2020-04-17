if Meteor.isClient
    Router.route '/time', (->
        @layout 'layout'
        @render 'time'
        ), name:'time'

    Template.time.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'time_session'
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'time_session')

        @autorun => Meteor.subscribe 'model_docs', 'time_stats'
        @autorun => Meteor.subscribe 'current_sessions'
    Template.time.events
        'click .refresh_time_stats': ->
            Meteor.call 'refresh_time_stats', ->
        'click .refresh_my_time_stats': ->
            Meteor.call 'refresh_my_time_stats', ->
        'click .start_session': (e,t)->
            Docs.insert
                model:'time_session'
                start_timestamp: Date.now()
                current:true

        'click .end_session': (e,t)->
            Docs.update @_id,
                $set:
                    current:false
                    end_timestamp: Date.now()

        'click .cancel_session': ->
            if confirm 'cancel session?'
                Docs.remove @_id
    Template.time.helpers
        my_current_session: ->
            Docs.findOne
                model:'time_session'
                _author_id:Meteor.userId()
                current:true

        current_sessions: ->
            Docs.find
                model:'time_session'
                current:true

        time_stats_doc: ->
            Docs.findOne
                model:'time_stats'
        time_sessions: ->
            Docs.find
                model:'time_session'


if Meteor.isServer
    Meteor.publish 'time_stats', ->
        Docs.find
            model: 'time_stats'

    Meteor.publish 'current_sessions', ->
        Docs.find
            model: 'time_session'
            current:true

    Meteor.methods
        refresh_my_time_stats: ->
            site_time_session_cursor =
                Docs.find(
                    model:'time_session'
                )
            site_time_session_count = site_time_session_cursor.count()
            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            all_time_sessions_count =
                Docs.find({
                    model:'time_session'
                    _author_id: Meteor.userId()
                    }).count()
            daily_sessions =
                Docs.find({
                    model:'time_session'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_24_hours
                    })

            daily_hours = 0
            for session in daily_sessions.fetch()
                start_moment = moment(session.start_datetime)
                end_moment = moment(session.end_datetime)
                hour_difference = end_moment.diff(start_moment, 'hours')
                Docs.update session._id,
                    $set:
                        hour_difference:hour_difference
                daily_hours += hour_difference

            console.log 'my daily hours', daily_hours
            console.log 'my daily session count', daily_sessions.count()

            week_time_sessions_count =
                Docs.find({
                    model:'time_session'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_time_sessions_count =
                Docs.find({
                    model:'time_session'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_month
                    }).count()

            Meteor.users.update Meteor.userId(),
                $set:
                    daily_hours: daily_hours
                    # weekly_hours: weekly_hours
                    daily_sessions:daily_sessions.count()
                    # weekly_sessions:weekly_sessions.count()



        refresh_time_stats: ->
            site_time_session_cursor =
                Docs.find(
                    model:'time_session'
                )
            site_time_session_count = site_time_session_cursor.count()

            site_user_cursor =
                Meteor.users.find(
                )
            site_user_count = site_user_cursor.count()

            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            console.log past_24_hours
            all_time_sessions_count =
                Docs.find({
                    model:'time_session'
                    }).count()
            day_time_sessions_count =
                Docs.find({
                    model:'time_session'
                    _timestamp:
                        $gt:past_24_hours
                    }).count()
            week_time_sessions_count =
                Docs.find({
                    model:'time_session'
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_time_sessions_count =
                Docs.find({
                    model:'time_session'
                    _timestamp:
                        $gt:past_month
                    }).count()





            daily_sessions =
                Docs.find({
                    model:'time_session'
                    _timestamp:
                        $gt:past_24_hours
                    })

            total_hours_today = 0
            for session in daily_sessions.fetch()
                start_moment = moment(session.start_datetime)
                end_moment = moment(session.end_datetime)
                hour_difference = end_moment.diff(start_moment, 'hours')
                Docs.update session._id,
                    $set:
                        hour_difference:hour_difference
                total_hours_today += hour_difference

            # console.log 'my daily hours', daily_hours
            # console.log 'my daily session count', daily_sessions.count()




            time_stats_doc =
                Docs.findOne
                    model:'time_stats'
            unless time_stats_doc
                gs_id = Docs.insert
                    model:'time_stats'
                time_stats_doc = Docs.findOne gs_id

            Docs.update time_stats_doc._id,
                $set:
                    global_average_correct_percent:global_average_correct_percent.toFixed()
                    total_sessions: all_time_sessions_count
                    user_count:site_user_count
                    total_hours_today: daily_hours
                    day_time_sessions_count:day_time_sessions_count
                    week_time_sessions_count:week_time_sessions_count
                    month_time_sessions_count:month_time_sessions_count
