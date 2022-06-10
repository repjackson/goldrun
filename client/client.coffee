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
	    if Meteor.userId()
	        Meteor.users.update Meteor.userId(),
	            $set:
	                admin_mode:!Meteor.user().admin_mode
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
Template.registerHelper 'to_percent', (number) -> (Math.floor(number*100)).toFixed(0)
Template.registerHelper 'long_time', (input) -> moment(input).format("h:mm a")
Template.registerHelper 'long_date', (input) -> moment(input).format("dddd, MMMM Do h:mm a")
Template.registerHelper 'short_date', (input) -> moment(input).format("dddd, MMMM Do")
Template.registerHelper 'med_date', (input) -> moment(input).format("MMM D 'YY")
Template.registerHelper 'medium_date', (input) -> moment(input).format("MMMM Do YYYY")
# Template.registerHelper 'medium_date', (input) -> moment(input).format("dddd, MMMM Do YYYY")
Template.registerHelper 'today', () -> moment(Date.now()).format("dddd, MMMM Do a")
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
    (number/100).toFixed()
# Template.registerHelper 'to_percent', (number)->
#     # console.log number
#     (number*100).toFixed()

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



Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0

    
Meteor.users.find(_id:Meteor.userId()).observe({
    changed: (new_doc, old_doc)->
        # console.log 'changed', new_doc.points, old_doc.points
        difference = new_doc.points-old_doc.points
        if difference > 0
            $('body').toast({
                title: "#{new_doc.points-old_doc.points}p earned"
                # message: 'Please see desk staff for key.'
                class : 'success'
                showIcon:'hashtag'
                # showProgress:'bottom'
                position:'bottom right'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })

})
    
    
    
# Docs.find({model:'log',read_user_ids:$nin:[Meteor.userId()]}).observe({
if Meteor.user()
    Docs.find({model:'log',read_user_ids:{$nin:[Meteor.userId()]}}).observe({
        added: (new_doc)->
            console.log 'alert', new_doc
            # difference = new_doc.points-old_doc.points
            # author = Meteor.users.findOne new_doc._author_id
            # Meteor.call "c.get_download_url", author.image_id,(err,download_url) ->
            #     console.log "Upload Error: #{err}"
            #     console.log "#{download_url}"
    
            # if difference > 0
            $('body').toast({
                title: "#{new_doc.body}"
                # showImage:"{{c.url currentUser.image_id width=300 height=300 gravity='face' crop='fill'}}"
                # classImage: 'avatar',
                message: "#{moment(new_doc._timestamp).fromNow()}"
                displayTime: 0,
                class: 'black',
                # classActions: 'ui fluid',
                actions: [{
                    text: 'mark read'
                    class: 'ui fluid green button'
                    click: ()->
                        Docs.update new_doc._id,
                            $addToSet:
                                read_user_ids:Meteor.userId()
    
                        # $('body').toast({message:'You clicked "yes", toast closes by default'})
                }]
                showIcon:'bell'
                # showProgress:'bottom'
                position:'top right'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                    showMethod   : 'zoom',
                    showDuration : 250,
                    hideMethod   : 'zoom',
                    hideDuration : 250
            })
    })
        
    
    
Template.footer.helpers
    all_users: -> Meteor.users.find()
    all_docs: -> Docs.find()
    result_docs: -> Results.find()

