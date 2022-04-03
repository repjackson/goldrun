@selected_rental_tags = new ReactiveArray []
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
 

Template.home.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'model_docs', 'post', ->
    @autorun -> Meteor.subscribe 'model_docs', 'chat_message', ->
    @autorun -> Meteor.subscribe 'model_docs', 'stat', ->
    @autorun -> Meteor.subscribe 'all_users', ->
        
Template.home.onRendered ->
    Meteor.call 'log_homepage_view', ->        
Template.home.events 
    'keyup .add_public_chat': (e,t)->
        val = t.$('.add_public_chat').val()
        if e.which is 13
            if val.length > 0
                new_id = 
                    Docs.insert 
                        model:'chat_message'
                        chat_type:'public'
                        body:val
                val = t.$('.add_public_chat').val('')
                $('body').toast({
                    title: "message sent"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    # position:'top center'
                    # className:
                    #     toast: 'ui massive message'
                    # displayTime: 5000
                    transition:
                      showMethod   : 'zoom',
                      showDuration : 250,
                      hideMethod   : 'fade',
                      hideDuration : 250
                    })
                    
                
Template.home.helpers
    homepage_data_doc: ->
        doc = 
            Docs.findOne 
                model:'stat'
    latest_post_docs: ->
        Docs.find {
            model:'post'
        }, sort:_timestamp:-1
    latest_chat_docs: ->
        Docs.find {
            model:'chat_message'
        }, sort:_timestamp:-1
    top_users: ->
        Meteor.users.find {},
            sort:points:-1
            
        
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'users'
    # @autorun -> Meteor.subscribe 'users_by_role','staff'
    # @autorun -> Meteor.subscribe 'unread_messages'


$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

Template.nav.events
    'click .add_rental': ->
        new_id = 
            Docs.insert 
                model:'rental'
        Router.go "/rental/#{new_id}/edit"
    # 'click .locate': ->
    #     navigator.geolocation.getCurrentPosition (position) =>
    #         console.log 'navigator position', position
    #         Session.set('current_lat', position.coords.latitude)
    #         Session.set('current_long', position.coords.longitude)

Template.layout.events
    'click .fly_up': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('slide up', 500)
    'click .fly_left': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fly left', 500)
    'click .fly_right': (e,t)->
        console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
    'click .card_fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.card').transition('fly right', 500)
        
    'click a': ->
        $('.global_container')
        .transition('fade out', 200)
        .transition('fade in', 200)

    'click .log_view': ->
        console.log Template.currentData()
        console.log @
        Docs.update @_id,
            $inc: views: 1


# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'
