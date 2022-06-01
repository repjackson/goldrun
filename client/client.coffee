@picked_tags = new ReactiveArray []
@picked_user_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []


# Tracker.autorun ->
#     current = Router.current()
#     Tracker.afterFlush ->
#         $(window).scrollTop 0

    
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
# Router.route '/', (->
#     @render 'reddit'
#     # @redirect('/reddit');
#     ), name:'home'
