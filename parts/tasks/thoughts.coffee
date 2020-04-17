if Meteor.isClient
    Router.route '/thoughts', (->
        @layout 'layout'
        @render 'thoughts'
        ), name:'thoughts'

    Template.thoughts.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'thought'
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'thought')
        @autorun => Meteor.subscribe 'model_docs', 'thoughts_stats'
        @autorun => Meteor.subscribe 'current_thoughts'
    Template.thoughts.events
        'click .refresh_thoughts_stats': ->
            Meteor.call 'refresh_thoughts_stats', ->
        'click .refresh_my_thoughts_stats': ->
            Meteor.call 'refresh_my_thoughts_stats', ->
        'click .select_thought': ->
            if Session.equals('selected_thought_id',@_id)
                Session.set 'selected_thought_id', null
            else
                Session.set 'selected_thought_id', @_id
        'click .new_thought': (e,t)->
            new_thought_id =
                Docs.insert
                    model:'thought'

            Session.set('editing_thought', true)
            Session.set('selected_thought_id', new_thought_id)
        'click .unselect_thought': ->
            Session.set('selected_thought_id', null)

    Template.selected_thought.events
        'click .delete_thought': ->
            if confirm 'delete thought?'
                Docs.remove @_id
                Session.set('selected_thought_id', null)
        'click .save_thought': ->
            Session.set('editing_thought', false)
        'click .edit_thought': ->
            Session.set('editing_thought', true)

    Template.selected_thought.helpers
        editing_thought: -> Session.get('editing_thought')

    Template.thoughts.helpers
        thought_segment_class: ->
            if Session.equals('selected_thought_id', @_id) then 'inverted blue' else ''
        selected_thought_doc: ->
            Docs.findOne Session.get('selected_thought_id')
        current_thoughts: ->
            Docs.find
                model:'thought'
                current:true
        thoughts_stats_doc: ->
            Docs.findOne
                model:'thoughts_stats'
        thoughts: ->
            Docs.find
                model:'thought'


if Meteor.isServer
    Meteor.publish 'thoughts_stats', ->
        Docs.find
            model: 'thoughts_stats'

    Meteor.publish 'current_thoughts', ->
        Docs.find
            model: 'thought'
            current:true

    Meteor.methods
        refresh_my_thoughts_stats: ->
            site_thought_cursor =
                Docs.find(
                    model:'thought'
                )
            site_thought_count = site_thought_cursor.count()
            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            all_thoughts_count =
                Docs.find({
                    model:'thought'
                    }).count()
            daily_sessions =
                Docs.find({
                    model:'thought'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_24_hours
                    })

            daily_hours = 0
            console.log 'my daily hours', daily_hours
            console.log 'my daily session count', daily_sessions.count()

            week_thoughts_count =
                Docs.find({
                    model:'thought'
                    _author_id: Meteor.userId()
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_thoughts_count =
                Docs.find({
                    model:'thought'
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



        refresh_thoughts_stats: ->
            site_thought_cursor =
                Docs.find(
                    model:'thought'
                )
            site_thought_count = site_thought_cursor.count()

            site_user_cursor =
                Meteor.users.find(
                )
            site_user_count = site_user_cursor.count()

            now = Date.now()
            past_24_hours = now-(24*60*60*1000)
            past_week = now-(7*24*60*60*1000)
            past_month = now-(30*7*24*60*60*1000)
            console.log past_24_hours
            all_thoughts_count =
                Docs.find({
                    model:'thought'
                    }).count()
            day_thoughts_count =
                Docs.find({
                    model:'thought'
                    _timestamp:
                        $gt:past_24_hours
                    }).count()
            week_thoughts_count =
                Docs.find({
                    model:'thought'
                    _timestamp:
                        $gt:past_week
                    }).count()
            month_thoughts_count =
                Docs.find({
                    model:'thought'
                    _timestamp:
                        $gt:past_month
                    }).count()


            daily_sessions =
                Docs.find({
                    model:'thought'
                    _timestamp:
                        $gt:past_24_hours
                    })


            thoughts_stats_doc =
                Docs.findOne
                    model:'thoughts_stats'
            unless thoughts_stats_doc
                gs_id = Docs.insert
                    model:'thoughts_stats'
                thoughts_stats_doc = Docs.findOne gs_id

            Docs.update thoughts_stats_doc._id,
                $set:
                    total_thoughts: all_thoughts_count
                    day_thoughts_count:day_thoughts_count
                    week_thoughts_count:week_thoughts_count
                    month_thoughts_count:month_thoughts_count
