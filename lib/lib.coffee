@Docs = new Meteor.Collection 'docs'
@Results = new Meteor.Collection 'results'
# @Markers = new Meteor.Collection 'markers'
@Tags = new Meteor.Collection 'tags'



Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'not_found'
    loadingTemplate: 'splash'
    trackPageView: false

force_loggedin =  ()->
    if !Meteor.userId()
        @render 'login'
    else
        @next()

# Router.onBeforeAction(force_loggedin, {
#   # only: ['admin']
#   # except: ['register', 'forgot_password','reset_password','front','delta','doc_view','verify-email']
#   except: [
#     'food'
#     'register'
#     'users'
#     'services'
#     'service_view'
#     'products'
#     'product_view'
#     'posts'
#     'post_view'
#     'home'
#     'forgot_password'
#     'reset_password'
#     'user_orders'
#     'user_food'
#     'user_finance'
#     'user_dashboard'
#     'verify-email'
#     'food_view'
#   ]
# });



Router.route '*', -> @render 'reddit'
Router.route '/', -> @render 'reddit'

Router.route '/user/:username/m/:type', -> @render 'user_layout', 'user_section'
Router.route '/forgot_password', -> @render 'forgot_password'

# Router.route "/food/:food_id", -> @render 'food_doc'

Router.route '/login', -> @render 'login'



Docs.before.insert (userId, doc)->
    # doc._author_id = Meteor.userId()
    timestamp = Date.now()
    doc._timestamp = timestamp
    doc._timestamp_long = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')

    hour = moment(timestamp).format('h')
    minute = moment(timestamp).format('m')
    ap = moment(timestamp).format('a')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    # date_array = [ap, "hour #{hour}", "min #{minute}", weekday, month, date, year]
    date_array = [ap, weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        # console.log date_array
        doc._timestamp_tags = date_array
    # unless doc._author_id
    #     if Meteor.user()
    #         doc._author_id = Meteor.userId()
    #         doc._author_username = Meteor.user().username
    doc.app = 'goldrun'
    # doc.points = 0
    # doc.downvoters = []
    # doc.upvoters = []
    return

# if Meteor.isClient
#     # console.log $
#     $.cloudinary.config
#         cloud_name:"facet"

# if Meteor.isServer
#     Cloudinary.config
#         cloud_name: 'facet'
#         api_key: Meteor.settings.cloudinary_key
#         api_secret: Meteor.settings.cloudinary_secret




# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true


# Meteor.users.helpers
#     name: ->
#         if @display_name
#             "#{@display_name}"
#         else if @first_name
#             "#{@first_name}"
#             if @last_name 
#                 "#{@first_name} #{@last_name}"
#         else
#             "#{@username}"
#     shortname: ->
#         if @nickname
#             "#{@nickname}"
#         else if @first_name
#             "#{@first_name}"
#         else
#             "#{@username}"
#     email_address: -> if @emails and @emails[0] then @emails[0].address
#     email_verified: -> if @emails and @emails[0] then @emails[0].verified
#     five_tags: -> if @tags then @tags[..5]
#     seven_tags: -> if @tags then @tags[..7]
#     ten_tags: -> if @tags then @tags[..10]
#     has_points: -> @points > 0
#     # is_tech_admin: ->
#     #     @_id in ['vwCi2GTJgvBJN5F6c','Dw2DfanyyteLytajt','LQEJBS6gHo3ibsJFu','YFPxjXCgjhMYEPADS','RWPa8zfANCJsczDcQ']
Docs.helpers
    _author: -> Meteor.users.findOne @_author_id

    _when: -> moment(@_timestamp).fromNow()
    three_tags: -> if @tags then @tags[..2]
    five_tags: -> if @tags then @tags[..4]
    seven_tags: -> if @tags then @tags[..7]
    ten_tags: -> if @tags then @tags[..10]
    is_visible: -> @published in [0,1]
    is_published: -> @published is 1
    is_anonymous: -> @published is 0
    is_private: -> @published is -1
    # from_user: ->
    #     if @from_user_id
    #         Docs.findOne @from_user_id
    # to_user: ->
    #     if @to_user_id
    #         Docs.findOne @to_user_id