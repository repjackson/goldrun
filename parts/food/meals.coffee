if Meteor.isClient
    Router.route '/meals', (->
        @layout 'layout'
        @render 'meals'
        ), name:'meals'


    Template.meals.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'meal'

    Template.meals.helpers
        meals: ->
            Docs.find
                model:'meal'

    Template.home.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'meal_sort_key', 'datetime_available'
        Session.setDefault 'meal_sort_label', 'available'
        Session.setDefault 'meal_limit', 5

    # Template.body.events
    #     'keydown':(e,t)->
    #         # console.log e.keyCode
    #         # console.log e.keyCode
    #         if e.keyCode is 27
    #             console.log 'hi'
    #             # console.log 'hi'
    #             Session.set('current_query', null)
    #             selected_tags.clear()
    #             $('#search').val('')
    #             $('#search').blur()
    #
    Template.home.onCreated ->
        @autorun => @subscribe 'model_docs', 'dish'
        # @autorun => @subscribe 'results',
        #     selected_tags.array()
        #     selected_authors.array()
        #     # selected_subreddits.array()
        #     selected_timestamp_tags.array()
        #     Session.get('current_query')
        #     Session.get('meal_limit')
        #     Session.get('meal_sort_key')
        #     Session.get('meal_sort_direction')
        @autorun => @subscribe 'meal_facets',
            selected_ingredients.array()
            Session.get('meal_limit')
            Session.get('meal_sort_key')
            Session.get('meal_sort_direction')

        @autorun => @subscribe 'meal_results',
            selected_ingredients.array()
            Session.get('meal_limit')
            Session.get('meal_sort_key')
            Session.get('meal_sort_direction')



    Template.home.events
        # 'click .toggle_dark': ->
        #     Meteor.users.update Meteor.userId(),
        #         $set: dark_mode: !Meteor.user().dark_mode
        # 'click .toggle_menu': ->
        #     Session.set('view_menu', !Session.get('view_menu'))
        'click .calc_leaderboard': ->
            # console.log @
            # console.log selected_tags.array()
            Meteor.call 'calc_leaders', selected_tags.array(), (err,res)->
                console.log res

        'click .toggle_images': -> Session.set('view_images', !Session.get('view_images'))
        'click .toggle_videos': -> Session.set('view_videos', !Session.get('view_videos'))
        'click .toggle_articles': -> Session.set('view_articles', !Session.get('view_articles'))

        # 'click .result': (event,template)->
        #     # console.log @
        #     Meteor.call 'log_term', @title, ->
        #     selected_tags.push @title
        #     $('#search').val('')
        #     Session.set('current_query', null)
        #     Session.set('searching', false)
        #     Meteor.call 'search_reddit', selected_tags.array(), ->
        'click .ingredient_result': -> selected_ingredients.push @title
        'click .unselect_ingredient': ->
            selected_ingredients.remove @valueOf()
            # console.log selected_ingredients.array()
            # if selected_ingredients.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if selected_ingredients.array().length > 0
                # Meteor.call 'search_reddit', selected_ingredients.array(), ->

        'click .clear_selected_ingredients': ->
            Session.set('current_query',null)
            selected_ingredients.clear()

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    selected_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_meal_count': ->
            Meteor.call 'calc_meal_count', ->

        # 'click .create_redditor': ->
        #     Meteor.call 'create_redditor', @title, ->

        # 'click .calc_redditor': ->
        #     Meteor.call 'calc_redditor_stats', @handle, ->

        'click .calc_post': ->
            console.log @
            # Meteor.call 'get_reddit_post', (@_id)->


        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = selected_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             selected_tags.pop()
        #             Meteor.call 'search_reddit', selected_tags.array(), ->
        # , 1000)

        'click .reconnect': ->
            Meteor.reconnect()


        'click .set_sort_direction': ->
            if Session.get('meal_sort_direction') is -1
                Session.set('meal_sort_direction', 1)
            else
                Session.set('meal_sort_direction', -1)


    Template.home.helpers
        quickbuying_meal: ->
            Docs.findOne Session.get('quickbuying_id')

        sorting_up: ->
            parseInt(Session.get('meal_sort_direction')) is 1

        view_images_class: -> if Session.get('view_images') then 'white' else 'grey'
        view_videos_class: -> if Session.get('view_videos') then 'white' else 'grey'
        view_articles_class: -> if Session.get('view_articles') then 'white' else 'grey'
        view_tweets_class: -> if Session.get('view_tweets') then 'white' else 'grey'
        connection: ->
            console.log Meteor.status()
            Meteor.status()
        connected: ->
            Meteor.status().connected
        invert_class: ->
            if Meteor.user()
                if Meteor.user().dark_mode
                    'invert'
        view_menu: -> Session.get('view_menu')
        tags: ->
            # if Session.get('current_query') and Session.get('current_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            meal_count = Docs.find().count()
            # console.log 'meal count', meal_count
            if meal_count < 3
                Tags.find({count: $lt: meal_count})
            else
                Tags.find()

        ingredients: ->
            # if Session.get('current_query') and Session.get('current_query').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            meal_count = Docs.find().count()
            # console.log 'meal count', meal_count
            if meal_count < 3
                Ingredients.find({count: $lt: meal_count})
            else
                Ingredients.find()

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        selected_ingredients: -> selected_ingredients.array()
        selected_ingredients_plural: -> selected_ingredients.array().length > 1
        searching: -> Session.get('searching')

        one_post: ->
            Docs.find().count() is 1
        meals: ->
            # if selected_ingredients.array().length > 0
            Docs.find {
                model:'meal'
            },
                sort: "#{Session.get('meal_sort_key')}":parseInt(Session.get('meal_sort_direction'))
                limit:Session.get('meal_limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()

        home_subs_ready: ->
            if Template.instance().subscriptionsReady()
                Session.set('global_subs_ready', true)
            else
                Session.set('global_subs_ready', false)

        users: ->
            # if selected_tags.array().length > 0
            Meteor.users.find {
            },
                sort: count:-1
                # limit:1


        timestamp_tags: ->
            # if selected_tags.array().length > 0
            Timestamp_tags.find {
                # model:'reddit'
            },
                sort: count:-1
                # limit:1




        meal_limit: ->
            Session.get('meal_limit')

        current_meal_sort_label: ->
            Session.get('meal_sort_label')


        result_cloud: ->
            console.log @

    Template.set_meal_limit.events
        'click .set_limit': ->
            console.log @
            Session.set('meal_limit', @amount)

    Template.set_meal_sort_key.events
        'click .set_sort': ->
            console.log @
            Session.set('meal_sort_key', @key)
            Session.set('meal_sort_label', @label)

    Template.session_edit_value_button.events
        'click .set_session_value': ->
            # console.log @key
            # console.log @value
            Session.set(@key, @value)

    Template.session_edit_value_button.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @classes
                res += @classes
            if Session.equals(@key,@value)
                res += ' active'
            # console.log res
            res



    Template.session_boolean_toggle.events
        'click .toggle_session_key': ->
            console.log @key
            Session.set(@key, !Session.get(@key))

    Template.session_boolean_toggle.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @classes
                res += @classes
            if Session.get(@key)
                res += ' blue'
            else
                res += ' basic'

            # console.log res
            res
