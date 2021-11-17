if Meteor.isClient
    Router.route '/order/:doc_id/edit', (->
        @layout 'layout'
        @render 'order_edit'
        ), name:'order_edit'



    Template.order_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_from_order_id', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'model_docs', 'dish'

    Template.order_edit.helpers
        # all_dishes: ->
        #     Docs.find
        #         model:'dish'
        can_delete: ->
            order = Docs.findOne Router.current().params.doc_id
            if order.reservation_ids
                if order.reservation_ids.length > 1
                    false
                else
                    true
            else
                true
        can_complete: ->
            order = Docs.findOne Router.current().params.doc_id
            order.reservation_cost < Meteor.user().points
            
            
        points_after_purchase: ->
            user_points = Meteor.user().points
            current_order = Docs.findOne Router.current().params.doc_id
            user_points - current_order.post_point_price


    Template.order_edit.events
        'click .complete_order': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
                    completed_timestamp:Date.now()
                    
            $('body').toast(
                showIcon: 'checkmark'
                message: 'order completed'
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom center"
            )
            
            Docs.update @post_id,
                $inc: inventory:-1
            
            post = Docs.findOne @post_id
            $('body').toast(
                message: "post #{post.title} inventory updated to #{post.inventory}"
                icon: 'hashtag'
                # showProgress: 'bottom'
                class: 'info'
                # displayTime: 'auto',
                position: "bottom right"
            )
            Meteor.users.update post._author_id,
                $inc:
                    points:@post_point_price
            $('body').toast(
                showIcon: 'chevron up'
                message: "points debited from #{@_author_username}"
                # showProgress: 'bottom'
                class: 'info'
                # displayTime: 'auto',
                position: "bottom center"
            )
            Meteor.users.update @_author_id,
                $inc:
                    points:-@post_point_price
            $('body').toast(
                showIcon: 'chevron down'
                message: "points credited to #{post._author_username}"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom center"
            )
            Router.go "/order/#{@_id}"


        'click .delete_order': (e,t)->
            if confirm 'cancel order?'
                doc_id = Router.current().params.doc_id
                $(e.currentTarget).closest('.grid').transition('fly right', 500)
                Router.go "/post/#{@post_id}"

                Docs.remove doc_id




if Meteor.isClient
    Router.route '/order/:doc_id/', (->
        @layout 'layout'
        @render 'order_view'
        ), name:'order_view'


    Template.profile_order_item.onCreated ->
        @autorun => Meteor.subscribe 'post_from_order_id', @data._id
    Template.order_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'dish'
        # @autorun => Meteor.subscribe 'model_docs', 'order'
        @autorun => Meteor.subscribe 'post_from_order_id', Router.current().params.doc_id


    Template.order_view.events
        'click .cancel_order': ->
            if confirm 'cancel?'
                Docs.remove @_id


    Template.order_view.helpers
        can_order: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                order_count =
                    Docs.find(
                        model:'order'
                        order_id:@_id
                    ).count()
                if order_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'post_from_order_id', (order_id)->
        order = Docs.findOne order_id
        Docs.find
            _id: order.post_id

    # Meteor.methods
        # order_order: (order_id)->
        #     order = Docs.findOne order_id
        #     Docs.insert
        #         model:'order'
        #         order_id: order._id
        #         order_price: order.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-order.price_per_serving
        #     Meteor.users.update order._author_id,
        #         $inc:credit:order.price_per_serving
        #     Meteor.call 'calc_order_data', order_id, ->



if Meteor.isClient
    Template.user_orders.onCreated ->
        @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'post'
    Template.user_orders.helpers
        orders: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'order'
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_orders', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'order'
            _author_id: user._id
        }, limit:20)