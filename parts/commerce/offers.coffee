if Meteor.isClient
    Template.user_offers.onCreated ->
        @autorun => Meteor.subscribe 'user_offers', Router.current().params.username
    Template.user_offers.helpers
        offers: ->
            Docs.find
                model:'offer'
                target_username: Router.current().params.username
    Template.user_offers.events
        'click .new_offer': (e,t)->
            target = Meteor.users.findOne username:Router.current().params.username
            new_offer_id =
                Docs.insert
                    model:'offer'
                    target_id: target._id
                    target_username: target.username
            Router.go "/m/offer/#{new_offer_id}/edit"



if Meteor.isServer
    Meteor.publish 'user_offers', (username)->
        current_user = Meteor.users.findOne username:username
        Docs.find
            model:'offer'
            target_username: username
