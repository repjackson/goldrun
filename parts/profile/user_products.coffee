if Meteor.isClient
    Template.user_products.onCreated ->
        @autorun => Meteor.subscribe 'user_products', Router.current().params.username
    Template.user_products.events
        'click .add_product': ->
            new_id =
                Docs.insert
                    model:'product'
            Router.go "/product/#{new_id}/edit"

    Template.user_products.helpers
        products: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'product'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_products', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'product'
            _author_id: user._id
