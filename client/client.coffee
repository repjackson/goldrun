@picked_tags = new ReactiveArray []
@picked_user_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0

    
    
Template.footer.helpers
    all_users: -> Meteor.users.find()
    all_docs: -> Docs.find()
    result_docs: -> Results.find()

Template.nav.helpers
    is_connected: -> 
        # console.log Meteor.status().connected
        Meteor.status().connected
    unread_count: ->
        Docs.find(
            model:'log'
            read_user_ids:$nin:[Meteor.userId()]
        ).count()
Template.nav_item.helpers
    nav_item_class: (model)->
        # console.log model
        if Router.current().params.model is model then 'active' else ''
Template.nav.events
    'click .refresh_gps': ->
        navigator.geolocation.getCurrentPosition (position) =>
            console.log 'navigator position', position
            Session.set('current_lat', position.coords.latitude)
            Session.set('current_long', position.coords.longitude)
            
            console.log 'saving long', position.coords.longitude
            console.log 'saving lat', position.coords.latitude
        
            pos = Geolocation.currentLocation()
            Docs.update Router.current().params.doc_id, 
                $set:
                    lat:position.coords.latitude
                    long:position.coords.longitude

    'click .reconnect': -> Meteor.reconnect()
    'click .clear_search': ->
        Session.set('current_search',null)
        picked_tags.clear()
        Session.set('limit',10)
    'click .add': ->
        new_id = Docs.insert {}
        Router.go "/doc/#{new_id}/edit"
        
        
Template.nav_item.events 
    'click .go_route': -> 
        Session.set('model',@key)
        picked_tags.clear()
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me', ->
    # @autorun -> Meteor.subscribe 'all_users', ->
    # @autorun -> Meteor.subscribe 'model_docs','group', ->
    @autorun -> Meteor.subscribe 'unread_logs'


$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'


Template.nav.events
    'click .add_doc': ->
        new_id = 
            Docs.insert {model:Session.get('model')}
        Router.go "/doc/#{new_id}/edit"
    'click .locate': ->
        navigator.geolocation.getCurrentPosition (position) =>
            console.log 'navigator position', position
            Session.set('current_lat', position.coords.latitude)
            Session.set('current_long', position.coords.longitude)

Template.nav.events
    'click .tada': (e,t)-> $(e.currentTarget).closest('.icon').transition('bounce', 1000)
Template.nav_item.events
    'click .tada': (e,t)-> $(e.currentTarget).closest('.icon').transition('bounce', 1000)
Template.layout.events
    'click .fly_down': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade down', 500)
    'click .fly_up': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade up', 500)
    'click .fly_left': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade left', 500)
    'click .fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .card_fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.card').transition('fade right', 500)
    'click .zoom': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .flip': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('flip', 500)
        
    # 'click a': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)


# Template.layout.helpers
#     usersOnline:()->
#         Meteor.users.find({ "status.online": true })

# Template.user_pill.helpers
#     labelClass:->
#         if @status.idle 
#             "yellow"
#         else if @status.online
#             "green"
#         else
#             ""

# Meteor.users.find({ "status.online": true }).observe({
#     added: (id)->
#         console.log id, 'just came online'
#     removed: (id)->
#         console.log id, 'just went offline'
# })


# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
# Router.route '/', (->
#     @layout 'layout'
#     @render 'docs'
#     ), name:'home'
Router.route '/', (->
    @redirect('/music');
    ), name:'home'
Router.route '/docs', (->
    @redirect('/m/post');
    ), name:'docs'

Router.route '/m/:model', (->
    @layout 'layout'
    @render 'docs'
    ), name:'model'


# Router.route '/docs', (->
#     @layout 'layout'
#     @render 'docs'
#     ), name:'docs'
    
