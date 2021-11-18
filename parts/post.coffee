if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'posts'
        ), name:'home'


    Template.post_orders.onCreated ->
        @autorun => @subscribe 'post_orders',Router.current().params.doc_id, ->
    Template.post_orders.helpers
        post_order_docs: ->
            Docs.find 
                model:'order'
                post_id:Router.current().params.doc_id




if Meteor.isClient
    Router.route '/post/:doc_id/', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'
    Router.route '/order/:doc_id/checkout', (->
        @layout 'layout'
        @render 'order_edit'
        ), name:'order_checkout'


    
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.events
        'click .delete_post_item': ->
            if confirm 'delete post?'
                Docs.remove @_id
                Router.go "/posts"

    Template.post_view.helpers
        sold_out: -> @inventory < 1
    Template.post_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
    Template.post_view.events
        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'cart_item'
        #         post_id:@_id
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
        #         post_id:@_id
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
        'click .new_reservation': (e,t)->
            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: @_id
            Router.go "/reservation/#{new_reservation_id}/edit"
        'click .rent_post': (e,t)->
            post = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    # order_type:'rental'
                    post_id:post._id
                    post_title:post.title
                    post_image_id:post.image_id
                    post_daily_rate:post.daily_rate
                    
            Router.go "/order/#{new_order_id}/checkout"
            
            

        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'

        # 'click .buy_post': (e,t)->
        #     post = Docs.findOne Router.current().params.doc_id
        #     new_order_id = 
        #         Docs.insert 
        #             model:'order'
        #             order_type:'post'
        #             post_id:post._id
        #             post_title:post.title
        #             post_price:post.dollar_price
        #             post_image_id:post.image_id
        #             post_point_price:post.point_price
        #             post_dollar_price:post.dollar_price
        #     Router.go "/order/#{new_order_id}/checkout"
            
if Meteor.isClient
    Template.user_posts.onCreated ->
        @autorun => Meteor.subscribe 'user_posts', Router.current().params.username
    Template.user_posts.events
        'click .add_post': ->
            new_id =
                Docs.insert
                    model:'post'
            Router.go "/post/#{new_id}/edit"

    Template.user_posts.helpers
        posts: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'post'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_posts', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'post'
            _author_id: user._id
            
    Meteor.publish 'post_orders', (doc_id)->
        post = Docs.findOne doc_id
        Docs.find
            model:'order'
            post_id:post._id
            