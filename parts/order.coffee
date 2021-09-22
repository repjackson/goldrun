if Meteor.isClient
    Router.route '/order/:doc_id/edit', (->
        @layout 'layout'
        @render 'order_edit'
        ), name:'order_edit'



    Template.order_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'

    Template.order_edit.helpers
        all_dishes: ->
            Docs.find
                model:'dish'
        can_delete: ->
            order = Docs.findOne Router.current().params.doc_id
            if order.reservation_ids
                if order.reservation_ids.length > 1
                    false
                else
                    true
            else
                true


    Template.order_edit.events
        'click .select_dish': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    dish_id: @_id


        'click .delete_order': ->
            if confirm 'refund orders and cancel order?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"




if Meteor.isClient
    Router.route '/order/:doc_id/view', (->
        @layout 'layout'
        @render 'order_view'
        ), name:'order_view'


    Template.order_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'dish'
        # @autorun => Meteor.subscribe 'model_docs', 'order'
        @autorun => Meteor.subscribe 'food_by_order_id', Router.current().params.doc_id


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
    Meteor.publish 'food_by_order_id', (order_id)->
        order = Docs.findOne order_id
        Docs.find
            _id: order.food_id

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
