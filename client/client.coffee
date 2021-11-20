@selected_post_tags = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []


Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0

    Template.nav.events
        'click .add_post': ->
            new_id =
                Docs.insert
                    model:'post'
                    # passcode:passcode
                    published:false
                    daily_rate:1
            Router.go "/post/#{new_id}/edit"
            

    Template.nav.onCreated ->
        Session.setDefault 'limit', 20
        @autorun -> Meteor.subscribe 'me'
        # @autorun -> Meteor.subscribe 'users'
        # @autorun -> Meteor.subscribe 'users_by_role','staff'
        # @autorun -> Meteor.subscribe 'unread_messages'


$.cloudinary.config
    cloud_name:"facet"
# Router.notFound =
    # action: 'not_found'

Template.body.events
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
