Template.registerHelper 'emotion_color', () ->
    if @max_emotion_name
        # console.log @max_emotion_name
        switch @max_emotion_name
            when 'sadness' then 'blue'
            when 'joy' then 'green'
            when 'confident' then 'teal'
            when 'analytical' then 'orange'
            when 'tentative' then 'yellow'
    else if @doc_sentiment_label
        # console.log @doc_sentiment_label
        if @doc_sentiment_label is 'positive' then 'green'
        else if @doc_sentiment_label is 'negative' then 'red'


Template.registerHelper 'darkmode_class', () -> if Meteor.user().darkmode then 'invert' else ''



Template.registerHelper 'all_docs', () -> Docs.find()
Template.registerHelper 'one_result', () -> Docs.find().count() is 1
Template.registerHelper 'two_results', () -> Docs.find().count() is 2


Template.registerHelper 'parent', () -> Template.parentData()
Template.registerHelper 'parent_doc', () ->
    Docs.findOne @parent_id
    # Template.parentData()
Template.registerHelper 'sort_label', () -> Session.get('sort_label')
Template.registerHelper 'sort_icon', () -> Session.get('sort_icon')
Template.registerHelper 'current_limit', () -> parseInt(Session.get('limit'))

Template.registerHelper 'subs_ready', () -> 
    Template.instance().subscriptionsReady()

Template.registerHelper 'related_group_doc', () -> 
    Docs.findOne 
        model:'group'
        _id:@group_id

Template.registerHelper 'user_model_docs', (model) -> 
    username = Router.current().params.username
    Meteor.users.findOne username:username
    Docs.find {
        model:model
        _author_username:username
    }, sort:_timestamp:-1
    
    
    
Template.registerHelper 'connected', () -> Meteor.status().connected

Template.registerHelper 'is_author', () -> 
    @_author_id is Meteor.userId()
Template.registerHelper 'current_lat', () -> 
    Session.get('current_lat')
Template.registerHelper 'current_long', () -> 
    Session.get('current_long')
# Template.registerHelper 'current_username', () ->
#     Router.current().params.username

Template.registerHelper 'rental', () ->
    Docs.findOne @rental_id
    # Template.parentData()


Template.registerHelper '_target', () ->
    if @target_user_id
        Meteor.users.findOne
            _id: @target_user_id
    else if @recipient_id
        Meteor.users.findOne
            _id: @recipient_id

Template.registerHelper 'sorting_up', () ->
    parseInt(Session.get('sort_direction')) is 1

Template.registerHelper 'user_from_id', (id)->
    Docs.findOne id
    
    
Template.registerHelper 'skv_is', (key,value)->
    Session.equals(key,value)


Template.registerHelper 'group_doc', () ->
    Docs.findOne 
        model:'group'
        _id:@group_id

Template.registerHelper 'gs', () ->
    Docs.findOne
        model:'global_settings'
Template.registerHelper 'display_mode', () -> Session.get('display_mode',true)
Template.registerHelper 'is_loading', () -> Session.get 'loading'
Template.registerHelper 'dev', () -> Meteor.isDevelopment
# Template.registerHelper 'is_author', ()-> @_author_id is Meteor.userId()
# Template.registerHelper 'is_grandparent_author', () ->
#     grandparent = Template.parentData(2)
#     grandparent._author_id is Meteor.userId()
Template.registerHelper 'to_percent', (number) -> (number*100).toFixed()
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
Template.registerHelper 'when', () -> moment(@_timestamp).fromNow()
Template.registerHelper 'from_now', (input) -> moment(input).fromNow()
Template.registerHelper 'cal_time', (input) -> moment(input).calendar()
# Template.registerHelper 'logging_out', () -> Session.get 'logging_out'
Template.registerHelper 'upvote_class', () ->
    if Meteor.userId()
        if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else 'outline'
    else ''
Template.registerHelper 'downvote_class', () ->
    if Meteor.userId()
        if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else 'outline'
    else ''

Template.registerHelper 'current_month', () -> moment(Date.now()).format("MMMM")
Template.registerHelper 'current_day', () -> moment(Date.now()).format("DD")


Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'

Template.registerHelper 'total_potential_revenue', () ->
    @price_per_serving * @servings_amount

# Template.registerHelper 'servings_available', () ->
#     @price_per_serving * @servings_amount

Template.registerHelper 'session_is', (key, value)->
    Session.equals(key, value)

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



# Template.registerHelper 'checkin_guest_docs', () ->
#     Docs.findOne Router.current().params.doc_id
#     session_document = Docs.findOne Router.current().params.doc_id
#     # console.log session_document.guest_ids
#     Docs.find
#         _id:$in:session_document.guest_ids


Template.registerHelper '_author', () -> Meteor.users.findOne @_author_id
Template.registerHelper 'is_text', () ->
    # console.log @field_type
    @field_type is 'text'

Template.registerHelper 'template_parent', () ->
    # console.log Template.parentData()
    Template.parentData()



Template.registerHelper 'nl2br', (text)->
    nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
    new Spacebars.SafeString(nl2br)


Template.registerHelper 'loading_class', () ->
    if Session.get 'loading' then 'disabled' else ''

Template.registerHelper 'in_list', (key) ->
    if Meteor.userId()
        if @["#{key}"]
            if Meteor.userId() in @["#{key}"] then true else false


Template.registerHelper 'current_user', () ->  Meteor.users.findOne username:Router.current().params.username
Template.registerHelper 'order_rental', -> 
    Docs.findOne 
        _id:@rental_id
    
    
Template.registerHelper 'can_edit', () ->
    # Session.equals('current_username',@_author_username)
    # Meteor.user()
    Meteor.userId() is @_author_id or 'admin' in Meteor.user().roles

Template.registerHelper 'publish_when', () -> moment(@publish_date).fromNow()

Template.registerHelper 'current_doc', ->
    if Router.current().params.doc_id
        doc = Docs.findOne Router.current().params.doc_id
        if doc then doc
    else 
        @

Template.registerHelper 'user_from_username_param', () ->
    found = Meteor.users.findOne username:Router.current().params.username
    # console.log found
    found
Template.registerHelper 'field_value', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5
        if parent5._id
            parent = Template.parentData(5)
    else if parent6
        if parent6._id
            parent = Template.parentData(6)
    if parent
        parent["#{@key}"]


Template.registerHelper 'sorted_field_values', () ->
    # console.log @
    parent = Template.parentData()
    parent5 = Template.parentData(5)
    parent6 = Template.parentData(6)


    if @direct
        parent = Template.parentData()
    else if parent5._id
        parent = Template.parentData(5)
    else if parent6._id
        parent = Template.parentData(6)
    if parent
        _.sortBy parent["#{@key}"], 'number'


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



Template.registerHelper 'in_dev', () -> Meteor.isDevelopment

Template.registerHelper 'is_current_user', (key, value)->
    if Meteor.user()
        Meteor.user().username is Router.current().params.username
