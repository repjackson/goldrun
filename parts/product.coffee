if Meteor.isClient
    Router.route '/products', (->
        @layout 'layout'
        @render 'shop'
        ), name:'shop'

    Router.route '/', (->
        @layout 'layout'
        @render 'shop'
        ), name:'home'


    Template.product_orders.onCreated ->
        @autorun => @subscribe 'product_orders',Router.current().params.doc_id, ->
    Template.product_orders.helpers
        product_order_docs: ->
            Docs.find 
                model:'order'
                product_id:Router.current().params.doc_id




if Meteor.isClient
    Router.route '/product/:doc_id/', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'
    Router.route '/order/:doc_id/checkout', (->
        @layout 'layout'
        @render 'order_edit'
        ), name:'order_checkout'


    
    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.product_edit.events
        'click .delete_product_item': ->
            if confirm 'delete product?'
                Docs.remove @_id
                Router.go "/products"

    Template.product_view.helpers
        sold_out: -> @inventory < 1
    Template.product_view.events
        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'cart_item'
        #         product_id:@_id
        #     $('body').toast({
        #         title: "#{@title} added to cart."
        #         # message: 'Please see desk staff for key.'
        #         class : 'green'
        #         # position:'top center'
        #         # className:
        #         #     toast: 'ui massive message'
        #         displayTime: 5000
        #         transition:
        #           showMethod   : 'zoom',
        #           showDuration : 250,
        #           hideMethod   : 'fade',
        #           hideDuration : 250
        #         })

        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'order'
        #         product_id:@_id
        #     $('body').toast({
        #         title: "#{@title} added to cart."
        #         # message: 'Please see desk staff for key.'
        #         class : 'green'
        #         # position:'top center'
        #         # className:
        #         #     toast: 'ui massive message'
        #         displayTime: 5000
        #         transition:
        #           showMethod   : 'zoom',
        #           showDuration : 250,
        #           hideMethod   : 'fade',
        #           hideDuration : 250
        #         })

        'click .buy_product': (e,t)->
            product = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    product_id:product._id
                    product_title:product.title
                    product_price:product.dollar_price
                    product_image_id:product.image_id
                    product_point_price:product.point_price
                    product_dollar_price:product.dollar_price
            Router.go "/order/#{new_order_id}/checkout"
            
            
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
            
    Meteor.publish 'product_orders', (doc_id)->
        product = Docs.findOne doc_id
        Docs.find
            model:'order'
            product_id:product._id
            