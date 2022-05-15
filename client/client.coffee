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
 

    
Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_leftbar')
    , 3000
    Meteor.setTimeout ->
        $('.ui.rightbar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')
    , 3000
    Meteor.setTimeout ->
        $('.ui.topbar.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_topbar')
    , 2000
    
Template.footer.helpers
    all_users: -> Meteor.users.find()
    all_docs: -> Docs.find()

Template.nav.events
    'click .toggle_rightbar': ->
        $('.ui.rightbar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_rightbar')



Template.rightbar.events
    'click .logout': ->
        Session.set('logging_out', true)
        Meteor.logout ->
            Session.set('logging_out', false)
            
            
    'click .toggle_darkmode': ->
        Meteor.users.update Meteor.userId(),
            $set:darkmode:!Meteor.user().darkmode
        $('body').toast({
            title: "dark mode toggled"
            # message: 'Please see desk staff for key.'
            class : 'info'
            icon:'remove'
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
            
    
Template.rightbar.helpers
    

    
        
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me', ->
    # @autorun -> Meteor.subscribe 'all_users', ->
    # @autorun -> Meteor.subscribe 'model_docs','group', ->
    # @autorun -> Meteor.subscribe 'unread_messages'


$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'


Template.nav.events
    'click .locate': ->
        navigator.geolocation.getCurrentPosition (position) =>
            console.log 'navigator position', position
            Session.set('current_lat', position.coords.latitude)
            Session.set('current_long', position.coords.longitude)

Template.body.events
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
