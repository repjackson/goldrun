@picked_tags = new ReactiveArray []
@picked_user_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []



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

globalHotkeys = new Hotkeys();

globalHotkeys.add({
	combo : "ctrl+4",
	eventType: "keydown",
	callback : ()->
		alert("You pressed ctrl+4");
})

globalHotkeys.add({
	combo : "r a",
	callback : ()->
	    Session.set('admin_mode',!Session.get('admin_mode'))
# 		alert("admin mode toggle")
})

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
    @autorun => @subscribe 'tag_image', @data.name, Session.get('porn'),->
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
    @autorun => @subscribe 'tag_image', @data, Session.get('porn'),->
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
Template.flat_tag_picker.events
    'click .remove_tag': ->
        console.log @
        parent = Template.parentData()
        console.log parent
        if confirm "remove #{@valueOf()} tag?"
            Docs.update parent._id,
                $pull:
                    tags:@valueOf()
    'click .pick_flat_tag': -> 
        picked_tags.push @valueOf()
        Session.set('full_doc_id', null)

        Session.set('loading',true)
        Meteor.call 'search_reddit', picked_tags.array(), ->
            Session.set('loading',false)
Template.reddit_card_big.events
    'click .minimize': ->
        Session.set('full_doc_id', null)
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
    