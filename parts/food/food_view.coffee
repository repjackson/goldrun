if Meteor.isClient
    Router.route '/food/:doc_id/', (->
        @layout 'layout'
        @render 'food_view'
        ), name:'food_view'


    Template.food_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'dish_from_food_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'orders_from_food_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ingredients_from_food_id', Router.current().params.doc_id


    Template.food_view.events
        'click .mark_ready': ->
            if confirm 'mark food ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:true
                        ready_timestamp:Date.now()

        'click .unmark_ready': ->
            if confirm 'unmark food ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:false
                        ready_timestamp:null

        'click .cancel_order': ->
            Swal.fire({
                title: 'confirm cancel'
                text: "this will refund you #{@order_price} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    food = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:@order_price
                    Meteor.users.update food.cook_user_id,
                        $inc:credit:@order_price
                    Swal.fire(
                        'refund processed',
                        ''
                        'success'
                    Meteor.call 'calc_food_data', food._id
                    Docs.remove @_id
                    )
            )


    Template.food_view.helpers
        can_cancel: ->
            food = Docs.findOne Router.current().params.doc_id
            if Meteor.userId() is food._author_id
                if food.ready
                    false
                else
                    true
            else if Meteor.userId() is @_author_id
                if food.ready
                    false
                else
                    true


        can_order: ->
            if Meteor.user().roles and 'admin' in Meteor.user().roles
                true
            else
                @cook_user_id isnt Meteor.userId()

        food_order_class: ->
            if @waitlist then 'blue' else 'green'

    Template.order_button.onCreated ->

    Template.order_button.helpers

    Template.order_button.events
        # 'click .join_waitlist': ->
        #     Swal.fire({
        #         title: 'confirm wait list join',
        #         text: 'this will charge your account if orders cancel'
        #         icon: 'question'
        #         showCancelButton: true,
        #         confirmButtonText: 'confirm'
        #         cancelButtonText: 'cancel'
        #     }).then((result) =>
        #         if result.value
        #             Docs.insert
        #                 model:'order'
        #                 waitlist:true
        #                 food_id: Router.current().params.doc_id
        #             Swal.fire(
        #                 'wait list joined',
        #                 "you'll be alerted if accepted"
        #                 'success'
        #             )
        #     )

        'click .order_food': ->
            if Meteor.user().credit >= @price_per_serving
                Docs.insert
                    model:'order'
                    status:'pending'
                    complete:false
                    product_id: Router.current().params.doc_id
            #     if @serving_unit
            #         serving_text = @serving_unit
            #     else
            #         serving_text = 'serving'
            #     Swal.fire({
            #         title: "confirm buy #{serving_text}"
            #         text: "this will charge you #{@price_per_serving} credits"
            #         icon: 'question'
            #         showCancelButton: true,
            #         confirmButtonText: 'confirm'
            #         cancelButtonText: 'cancel'
            #     }).then((result) =>
            #         if result.value
            #             Meteor.call 'order_food', @_id, (err, res)->
            #                 if err
            #                     Swal.fire(
            #                         'err'
            #                         'error'
            #                     )
            #                     console.log err
            #                 else
            #                     Swal.fire(
            #                         'order and payment processed'
            #                         ''
            #                         'success'
            #                     )
            # )

if Meteor.isServer
    Meteor.publish 'orders_from_food_id', (food_id)->
        # food = Docs.findOne food_id
        Docs.find
            model:'order'
            food_id:food_id
