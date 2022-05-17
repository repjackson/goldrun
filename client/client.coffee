@picked_tags = new ReactiveArray []
@picked_user_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0
    #   'click .refresh_gps': ->
    #         navigator.geolocation.getCurrentPosition (position) =>
    #             console.log 'navigator position', position
    #             Session.set('current_lat', position.coords.latitude)
    #             Session.set('current_long', position.coords.longitude)
                
    #             console.log 'saving long', position.coords.longitude
    #             console.log 'saving lat', position.coords.latitude
            
    #             pos = Geolocation.currentLocation()
    #             Docs.update Router.current().params.doc_id, 
    #                 $set:
    #                     lat:position.coords.latitude
    #                     long:position.coords.longitude
 

    
    
Template.footer.helpers
    all_users: -> Meteor.users.find()
    all_docs: -> Docs.find()
    result_docs: -> Results.find()

Template.nav.events
    'click .add': ->
        new_id = Docs.insert {}
        Router.go "/doc/#{new_id}/edit"
        
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me', ->
    @autorun -> Meteor.subscribe 'all_users', ->
    # @autorun -> Meteor.subscribe 'model_docs','group', ->
    # @autorun -> Meteor.subscribe 'unread_messages'


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
        console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .card_fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.card').transition('fade right', 500)
        
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
Router.route '/', (->
    @layout 'layout'
    @render 'docs'
    ), name:'home'


Router.route '/docs', (->
    @layout 'layout'
    @render 'docs'
    ), name:'docs'
    

Router.route '/doc/:doc_id/edit', (->
    @layout 'layout'
    @render 'doc_edit'
    ), name:'doc_edit'
Template.doc_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
Template.doc_edit.helpers
    model_template: -> "#{@model}_edit"
    doc_data: -> 
        # console.log 'hi'
        Docs.findOne Router.current().params.doc_id

Router.route '/doc/:doc_id/', (->
    @layout 'layout'
    @render 'doc_view'
    ), name:'doc_view'
    
    
Template.doc_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
Template.doc_view.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
Template.doc_view.helpers
    model_template: -> "#{@model}_view"
    # current_doc: -> Docs.findOne Router.current().params.doc_id
    doc_data: -> 
        # console.log 'hi'
        Docs.findOne Router.current().params.doc_id
    
Template.doc_card.helpers
    card_template: -> "#{@model}_card"
Template.doc_item.helpers
    item_template: -> "#{@model}_item"
    
Template.docs.onCreated ->
    # @autorun => @subscribe 'model_docs', 'post', ->
    @autorun => @subscribe 'facet_sub',
        Session.get('model')
        picked_tags.array()
        Session.get('current_search')

    @autorun => @subscribe 'doc_results',
        Session.get('model')
        picked_tags.array()
        Session.get('current_search')
        Session.get('sort_key')
        Session.get('sort_direction')
        Session.get('limit')


Template.docs.helpers
    current_model: -> Session.get('model')
    result_docs: ->
        Docs.find {
            model:Session.get('model')
        }, 
            sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
            limit:Session.get('limit')        
            
