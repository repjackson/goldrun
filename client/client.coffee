@picked_tags = new ReactiveArray []
Template.registerHelper 'emotion_color', () ->
    if @sentiment
        if @sentiment is 'positive' then 'green' else 'red'
    
    # if @max_emotion_name
    #     # console.log @max_emotion_name
    #     switch @max_emotion_name
    #         when 'sadness' then 'blue'
    #         when 'joy' then 'green'
    #         when 'confident' then 'teal'
    #         when 'analytical' then 'orange'
    #         when 'tentative' then 'yellow'
    # else if @doc_sentiment_label
    #     # console.log @doc_sentiment_label
    #     if @doc_sentiment_label is 'positive' then 'green'
    #     else if @doc_sentiment_label is 'negative' then 'red'
# Template.registerHelper 'user_group_memberships', () -> 
#     user = Meteor.users.findOne username:@username
#     Docs.find
#         model:'group'
#         member_ids: $in:[user._id]


Template.registerHelper 'active_term_class', () ->
    found_emotion_avg = 
        Results.findOne 
            model:'emotion_avg'
    if found_emotion_avg
        # console.log 'max', _.max([found_emotion_avg.avg_joy_score,found_emotion_avg.avg_anger_score,found_emotion_avg.avg_sadness_score,found_emotion_avg.avg_disgust_score,found_emotion_avg.avg_fear_score])
        
        if found_emotion_avg.avg_sent_score < 0
            'red'
        else 
            'green'
    # console.log 'found emtion', found_emotion_avg
Template.registerHelper 'above_50', (input) ->
    # console.log input
    input > .5
Template.registerHelper 'has_thumbnail', () ->
    @thumbnail and @thumbnail not in ['self','default']

Template.registerHelper 'hostname', () -> 
    window.location.hostname

Template.registerHelper 'points_to_coins', (input) -> input/100

Template.registerHelper 'all_docs', () -> Docs.find()

Template.registerHelper 'parent', () -> Template.parentData()
Template.registerHelper '_parent_doc', () ->
    Docs.findOne @parent_id
    # Template.parentData()
Template.registerHelper 'sort_label', () -> Session.get('sort_label')
Template.registerHelper 'sort_icon', () -> Session.get('sort_icon')
Template.registerHelper 'current_limit', () -> parseInt(Session.get('limit'))

Template.registerHelper 'current_time', () -> moment().format("h:mm a")
Template.registerHelper 'subs_ready', () -> 
    Template.instance().subscriptionsReady()

Template.registerHelper 'is_connected', () -> Meteor.status().connected

Template.registerHelper 'sorting_up', () ->
    parseInt(Session.get('sort_direction')) is 1

Template.registerHelper 'skv_is', (key,value)->
    Session.equals(key,value)

Template.registerHelper 'is_loading', () -> Session.get 'loading'
Template.registerHelper 'dev', () -> Meteor.isDevelopment
# Template.registerHelper 'is_author', ()-> @_author_id is Meteor.userId()
# Template.registerHelper 'is_grandparent_author', () ->
#     grandparent = Template.parentData(2)
#     grandparent._author_id is Meteor.userId()
# Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed()
Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed(0)
Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
Template.registerHelper 'today', () -> moment(Date.now()).format("dddd, MMMM Do a")
Template.registerHelper 'fixed', (input) ->
    if input
        input.toFixed(2)
Template.registerHelper 'int', (input) -> input.toFixed(0)
Template.registerHelper '_when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
# Template.registerHelper 'logging_out', () -> Session.get 'logging_out'


Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")


Template.registerHelper 'current_doc', () -> Docs.findOne Router.current().params.doc_id

Template.registerHelper 'total_potential_revenue', () ->
    @price_per_serving * @servings_amount

# Template.registerHelper 'servings_available', () ->
#     @price_per_serving * @servings_amount

Template.registerHelper 'session_is', (key, value)-> Session.equals(key, value)
Template.registerHelper 'session_get', (key)-> Session.get(key)

Template.registerHelper 'key_value_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    @["#{key}"] is value

Template.registerHelper 'is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    key is value

Template.registerHelper 'parent_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    # console.log Template.parentData()
    # console.log Template.parentData()
    Template.parentData()["#{key}"] is value
    # key is value

Template.registerHelper 'parent_key_value_is', (key, value)->
    # console.log 'key', key
    # console.log 'value', value
    # console.log 'this', this
    @["#{key}"] is value



# Template.registerHelper 'parent_template', () -> Template.parentData()
    # Session.get 'displaying_profile'

# Template.registerHelper 'checking_in_doc', () ->
#     Docs.findOne
#         model:'healthclub_session'
#         current:true
#      # Session.get('session_document')

# Template.registerHelper 'current_session_doc', () ->
#         Docs.findOne
#             model:'healthclub_session'
#             current:true




Template.registerHelper 'template_parent', () ->
    # console.log Template.parentData()
    Template.parentData()



Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', () ->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

# Template.registerHelper 'data_doc', ->
#     if Router.current().params.doc_id
#         doc = Docs.findOne Router.current().params.doc_id
#         # if doc then doc
#     # else 
#     #     @
# Template.registerHelper 'user_from_user_id_param', () ->
#     found = Meteor.users.findOne _id:Router.current().params.user_id
#     # console.log found
#     found


Template.registerHelper 'in_dev', () -> Meteor.isDevelopment

Template.registerHelper 'calculated_size', (metric) ->
    # console.log metric
    # console.log typeof parseFloat(@relevance)
    # console.log typeof (@relevance*100).toFixed()
    whole = parseInt(@["#{metric}"]*10)
    # console.log whole

    if whole is 2 then 'f2'
    else if whole is 3 then 'f3'
    else if whole is 4 then 'f4'
    else if whole is 5 then 'f5'
    else if whole is 6 then 'f6'
    else if whole is 7 then 'f7'
    else if whole is 8 then 'f8'
    else if whole is 9 then 'f9'
    else if whole is 10 then 'f10'

Template.registerHelper 'unescaped', () ->
    txt = document.createElement("textarea")
    txt.innerHTML = @rd.selftext_html
    return txt.value

        # html.unescape(@rd.selftext_html)
Template.registerHelper 'unescaped_content', () ->
    txt = document.createElement("textarea")
    txt.innerHTML = @rd.media_embed.content
    return txt.value
    
Template.registerHelper 'session_key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    Session.equals key,value

Template.registerHelper 'key_value_is', (key, value) ->
    # console.log 'key', key
    # console.log 'value', value
    @["#{key}"] is value


Template.registerHelper 'template_subs_ready', () ->
    Template.instance().subscriptionsReady()

Template.registerHelper 'global_subs_ready', () ->
    Session.get('global_subs_ready')


Template.registerHelper 'sval', (input)-> Session.get(input)
Template.registerHelper 'is_loading', -> Session.get 'is_loading'
Template.registerHelper 'dev', -> Meteor.isDevelopment
Template.registerHelper 'fixed', (number)->
    # console.log number
    (number*100).toFixed()
Template.registerHelper 'to_percent', (number)->
    # console.log number
    (number*100).toFixed()

Template.registerHelper 'is_image', () ->
    # regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
    # match = @url.match(regExp)
    # # console.log 'image match', match
    # if match then true
    # true
    regExp = /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/
    match = @url.match(regExp)
    # console.log 'image match', match
    if match then true
    # true



Template.registerHelper 'loading_class', ()->
    if Session.get 'loading' then 'disabled' else ''


# Template.reddit_card.onRendered ->
#     console.log @
#     found_doc = @data
#     if found_doc 
#         unless found_doc.doc_sentiment_label
#             Meteor.call 'call_watson',found_doc._id,'title','html',->
#                 console.log 'autoran watson'

    # @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
Template.reddit.onCreated ->
    Session.setDefault('current_search', null)
    Session.setDefault('porn', false)
    Session.setDefault('dummy', false)
    Session.setDefault('is_loading', false)
    @autorun => @subscribe 'doc_by_id', Session.get('full_doc_id'), ->
    @autorun => @subscribe 'agg_emotions',
        picked_tags.array()
        Session.get('dummy')
    @autorun => @subscribe 'reddit_tag_results',
        picked_tags.array()
        Session.get('porn')
        Session.get('dummy')
    @autorun => @subscribe 'reddit_doc_results',
        picked_tags.array()
        Session.get('porn')
        # Session.get('dummy')



Template.agg_tag.onCreated ->
    # console.log @
    @autorun => @subscribe 'tag_image', @data.name, picked_tags.array(),->
Template.agg_tag.helpers
    term_image: ->
        # console.log Template.currentData().name
        found = Docs.findOne {
            model:'reddit'
            tags:$in:[Template.currentData().name]
            "watson.metadata.image":$exists:true
        }, sort:ups:-1
        # console.log 'found image', found
        found
Template.unpick_tag.onCreated ->
    # console.log @
    @autorun => @subscribe 'tag_image', @data, picked_tags.array(),->
Template.unpick_tag.helpers
    flat_term_image: ->
        # console.log Template.currentData()
        found = Docs.findOne {
            model:'reddit'
            tags:$in:[Template.currentData()]
            "watson.metadata.image":$exists:true
        }, sort:ups:-1
        # console.log 'found flat image', found.watson.metadata.image
        found.watson.metadata.image
Template.agg_tag.events
    'click .result': (e,t)->
        # Meteor.call 'log_term', @title, ->
        picked_tags.push @name
        $('#search').val('')
        Session.set('full_doc_id', null)
        
        Session.set('current_search', null)
        Session.set('searching', true)
        Session.set('is_loading', true)
        # Meteor.call 'call_wiki', @name, ->

        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('is_loading', false)
            Session.set('searching', false)
        # Meteor.setTimeout ->
        #     Session.set('dummy',!Session.get('dummy'))
        # , 5000
        

Template.reddit.events
    'click .toggle_porn': ->
        Session.set('porn',!Session.get('porn'))
    'click .select_search': ->
        picked_tags.push @name
        Session.set('full_doc_id', null)

        Meteor.call 'search_reddit', picked_tags.array(), ->
        $('#search').val('')
        Session.set('current_search', null)

Template.reddit_card.helpers
    five_cleaned_tags: ->
        # console.log picked_tags.array()
        # console.log @tags[..5] not in picked_tags.array()
        # console.log _.without(@tags[..5],picked_tags.array())
        if picked_tags.array().length
            _.difference(@tags[..10],picked_tags.array())
        #     @tags[..5] not in picked_tags.array()
        else 
            @tags[..5]
Template.reddit_card_big.events
    'click .minimize': ->
        Session.set('full_doc_id', null)
    'click .pick_flat_tag': -> 
        picked_tags.push @valueOf()
        Session.set('full_doc_id', null)

        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
Template.reddit_card.events
    'click .vote_up': ->
        Docs.update @_id,
            $inc:points:1
    'click .vote_down': ->
        Docs.update @_id,
            $inc:points:-1
    'click .expand': ->
        Session.set('full_doc_id', @_id)
        Session.set('dummy', !Session.get('dummy'))

    'click .pick_flat_tag': (e)-> 
        picked_tags.push @valueOf()
        Session.set('full_doc_id', null)
        $(e.currentTarget).closest('.pick_flat_tag').transition('fly up', 500)

        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
    # 'click .pick_subreddit': -> Session.set('subreddit',@subreddit)
    # 'click .pick_domain': -> Session.set('domain',@domain)
    'click .autotag': (e)->
        console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # if @rd and @rd.selftext_html
        #     dom = document.createElement('textarea')
        #     # dom.innerHTML = doc.body
        #     dom.innerHTML = @rd.selftext_html
        #     # console.log 'innner html', dom.value
        #     # return dom.value
        #     Docs.update @_id,
        #         $set:
        #             parsed_selftext_html:dom.value
        Meteor.call 'get_reddit_post', @_id, (err,res)->

        # doc = Template.parentData()
        # doc = Docs.findOne Template.parentData()._id
        # Meteor.call 'call_watson', Template.parentData()._id, parent.key, @mode, ->
        # if doc 
        # console.log 'calling client watson',doc, 'rd.selftext'
        Meteor.call 'call_watson', @_id, 'rd.selftext', 'html', ->
            # $(e.currentTarget).closest('.button').transition('scale', 500)
            # $('body').toast({
            #     title: "emotions brokedown"
            #     # message: 'Please see desk staff for key.'
            #     class : 'success'
            #     showIcon:'chess'
            #     # showProgress:'bottom'
            #     position:'bottom right'
            #     # className:
            #     #     toast: 'ui massive message'
            #     # displayTime: 5000
            #     transition:
            #       showMethod   : 'zoom',
            #       showDuration : 250,
            #       hideMethod   : 'fade',
            #       hideDuration : 250
            #     })
            # Session.set('dummy', !Session.get('dummy'))
        # Meteor.call 'call_watson', doc._id, @key, @mode, ->
Template.unpick_tag.events
    'click .unpick_tag': ->
        picked_tags.remove @valueOf()
        console.log picked_tags.array()
        if picked_tags.array().length > 0
            Session.set('is_loading', true)
            Meteor.call 'search_reddit', picked_tags.array(), =>
                Session.set('is_loading', false)
            # Meteor.setTimeout ->
            #     Session.set('dummy', !Session.get('dummy'))
            # , 5000
    
Template.reddit.events
    'click .print_me': ->
        console.log @

    # # 'keyup #search': _.throttle((e,t)->
    'click #search': (e,t)->
        if picked_tags.array().length > 0
            Session.set('dummy', !Session.get('dummy'))
    'keydown #search': (e,t)->
        # query = $('#search').val()
        search = $('#search').val().trim().toLowerCase()
        # if query.length > 0
        Session.set('current_search', search)
        # console.log Session.get('current_search')
        if search.length > 0
            if e.which is 13
                if search.length > 0
                    # Session.set('searching', true)
                    picked_tags.push search
                    Session.set('full_doc_id',null)
                    # console.log 'search', search
                    Session.set('is_loading', true)
                    Meteor.call 'search_reddit', picked_tags.array(), ->
                        Session.set('is_loading', false)
                        # Session.set('searching', false)
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 5000
                    $('#search').val('')
                    Session.set('current_search', null)
    # , 200)

    # 'keydown #search': _.throttle((e,t)->
    #     if e.which is 8
    #         search = $('#search').val()
    #         if search.length is 0
    #             last_val = picked_tags.array().slice(-1)
    #             console.log last_val
    #             $('#search').val(last_val)
    #             picked_tags.pop()
    #             Meteor.call 'search_reddit', picked_tags.array(), ->
    # , 1000)

    'click .reconnect': -> Meteor.reconnect()

    'click .toggle_tag': (e,t)-> picked_tags.push @valueOf()
    # 'click .pick_subreddit': -> Session.set('subreddit',@name)
    # 'click .unpick_subreddit': -> Session.set('subreddit',null)
    # 'click .pick_domain': -> Session.set('domain',@name)
    # 'click .unpick_domain': -> Session.set('domain',null)
    'click .print_me': (e,t)->
        console.log @
        
Template.reddit_card.helpers
    unescaped: -> 
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.selftext_html
        return txt.value

        # html.unescape(@rd.selftext_html)
    unescaped_content: -> 
        txt = document.createElement("textarea")
        txt.innerHTML = @rd.media_embed.content
        return txt.value

        # html.unescape(@rd.selftext_html)

    
Template.reddit.helpers
    porn_class: ->
        if Session.get('porn') then 'large red' else 'compact basic'
    full_doc_id: ->
        Session.get('full_doc_id')
    full_doc: ->
        Docs.findOne Session.get('full_doc_id')
    current_bg:->
        # console.log picked_tags.array()
        found = Docs.findOne {
            model:'reddit'
            tags:$in:picked_tags.array()
            "watson.metadata.image":$exists:true
            # thumbnail:$nin:['default','self']
        },sort:ups:-1
        if found
            # console.log 'found bg'
            found.watson.metadata.image
        # else 
        #     console.log 'no found bg'

    emotion_avg_result: ->
        Results.findOne 
            model:'emotion_avg'
    # in_dev: -> Meteor.isDevelopment()
    not_searching: ->
        picked_tags.array().length is 0 and Session.equals('current_search',null)
        
    search_class: ->
        if Session.get('current_search')
            'massive active' 
        else
            if picked_tags.array().length is 0
                'big'
            else 
                'big' 
          
    # domain_results: ->
    #     Results.find 
    #         model:'domain'
    # picked_subreddit: -> Session.get('subreddit')
    # picked_domain: -> Session.get('domain')
    # subreddit_results: ->
    #     Results.find 
    #         model:'subreddit'
                
    curent_date_setting: -> Session.get('date_setting')

    term_icon: ->
        console.log @
    doc_results: ->
        current_docs = Docs.find()
        # if Session.get('selected_doc_id') in current_docs.fetch()
        # console.log current_docs.fetch()
        # Docs.findOne Session.get('selected_doc_id')
        doc_count = Docs.find().count()
        # if doc_count is 1
        Docs.find({model:'reddit'}, 
            limit:20
            sort:
                points:-1
                ups:-1
                # "#{Session.get('sort_key')}":Session.get('sort_direction')
        )

    is_loading: -> Session.get('is_loading')

    tag_result_class: ->
        # ec = omega.emotion_color
        # console.log @
        # console.log omega.total_doc_result_count
        total_doc_result_count = Docs.find({}).count()
        console.log total_doc_result_count
        percent = @count/total_doc_result_count
        # console.log 'percent', percent
        # console.log typeof parseFloat(@relevance)
        # console.log typeof (@relevance*100).toFixed()
        whole = parseInt(percent*10)+1
        # console.log 'whole', whole

        # if whole is 0 then "#{ec} f5"
        if whole is 0 then "f5"
        else if whole is 1 then "f11"
        else if whole is 2 then "f12"
        else if whole is 3 then "f13"
        else if whole is 4 then "f14"
        else if whole is 5 then "f15"
        else if whole is 6 then "f16"
        else if whole is 7 then "f17"
        else if whole is 8 then "f18"
        else if whole is 9 then "f19"
        else if whole is 10 then "f20"


    connection: ->
        # console.log Meteor.status()
        Meteor.status()
    connected: -> Meteor.status().connected

    unpicked_tags: ->
        # # doc_count = Docs.find().count()
        # # console.log 'doc count', doc_count
        # # if doc_count < 3
        # #     Tags.find({count: $lt: doc_count})
        # # else
        # unless Session.get('searching')
        #     unless Session.get('current_search').length > 0
        Results.find({model:'tag'})

    result_class: ->
        if Template.instance().subscriptionsReady()
            ''
        else
            'disabled'

    picked_tags: -> picked_tags.array()

    picked_tags_plural: -> picked_tags.array().length > 1

    searching: ->
        # console.log 'searching?', Session.get('searching')
        Session.get('searching')

    one_post: -> Docs.find().count() is 1

    two_posts: -> Docs.find().count() is 2
    three_posts: -> Docs.find().count() is 3
    four_posts: -> Docs.find().count() is 4
    more_than_four: -> Docs.find().count() > 4
    one_result: ->
        Docs.find().count() is 1

    docs: ->
        # if picked_tags.array().length > 0
        cursor =
            Docs.find {
                model:'reddit'
            },
                sort:
                    "#{Session.get('sort_key')}":Session.get('sort_direction')
        # console.log cursor.fetch()
        cursor


    home_subs_ready: ->
        Template.instance().subscriptionsReady()
        
    #     @autorun => Meteor.subscribe 'current_doc', Router.current().params.doc_id
    #     console.log @
    # Template.array_view.events
    #     'click .toggle_post_filter': ->
    #         console.log @
    #         value = @valueOf()
    #         console.log Template.currentData()
    #         current = Template.currentData()
    #         console.log Template.parentData()
            # match = Session.get('match')
            # key_array = match["#{current.key}"]
            # if key_array
            #     if value in key_array
            #         key_array = _.without(key_array, value)
            #         match["#{current.key}"] = key_array
            #         picked_tags.remove value
            #         Session.set('match', match)
            #     else
            #         key_array.push value
            #         picked_tags.push value
            #         Session.set('match', match)
            #         Meteor.call 'search_reddit', picked_tags.array(), ->
            #         # Meteor.call 'agg_idea', value, current.key, 'entity', ->
            #         console.log @
            #         # match["#{current.key}"] = ["#{value}"]
            # else
            # if value in picked_tags.array()
            #     picked_tags.remove value
            # else
            #     # match["#{current.key}"] = ["#{value}"]
            #     picked_tags.push value
            #     # console.log picked_tags.array()
            # # Session.set('match', match)
            # # console.log picked_tags.array()
            # if picked_tags.array().length > 0
            #     Meteor.call 'search_reddit', picked_tags.array(), ->
            # console.log Session.get('match')

    # Template.array_view.helpers
    #     values: ->
    #         # console.log @key
    #         Template.parentData()["#{@key}"]
    #
    #     post_label_class: ->
    #         match = Session.get('match')
    #         key = Template.parentData().key
    #         doc = Template.parentData(2)
    #         # console.log key
    #         # console.log doc
    #         # console.log @
    #         if @valueOf() in picked_tags.array()
    #             'active'
    #         else
    #             'basic'
    #         # if match["#{key}"]
    #         #     if @valueOf() in match["#{key}"]
    #         #         'active'
    #         #     else
    #         #         'basic'
    #         # else
    #         #     'basic'
    #
    