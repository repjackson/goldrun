if Meteor.isClient
    Router.route '/meal/:doc_id/view', (->
        @layout 'layout'
        @render 'meal_view'
        ), name:'meal_view'


    Template.meal_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'dish_from_meal_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'orders_from_meal_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ingredients_from_meal_id', Router.current().params.doc_id


    Template.meal_view.events
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
                    Meteor.users.update @_author_id,
                        $inc:credit:@order_price
                    Swal.fire(
                        'refund processed',
                        ''
                        'success'
                    Meteor.call 'calc_meal_data', @meal_id
                    Docs.remove @_id
                    )
            )


    Template.meal_view.helpers
        can_order: -> @cook_user_id isnt Meteor.userId()

        meal_order_class: ->
            if @waitlist then 'blue' else 'green'

    Template.order_button.onCreated ->
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        if StripeCheckout
            Template.instance().checkout = StripeCheckout.configure(
                key: pub_key
                image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/wc_logo.png'
                locale: 'auto'
                # zipCode: true
                token: (token) ->
                    product = Docs.findOne Router.current().params.doc_id
                    charge =
                        amount: 1*100
                        currency: 'usd'
                        source: token.id
                        description: token.description
                        # receipt_email: token.email
                    Meteor.call 'STRIPE_single_charge', charge, product, (error, response) =>
                        if error then alert error.reason, 'danger'
                        else
                            alert 'Payment received.', 'success'
                            Docs.insert
                                model:'transaction'
                                # product_id:product._id
                            Meteor.users.update Meteor.userId(),
                                $inc: credit:10

        	)

    Template.order_button.helpers

    Template.order_button.events
        'click .join_waitlist': ->
            Swal.fire({
                title: 'confirm wait list join',
                text: 'this will charge your account if orders cancel'
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    Docs.insert
                        model:'order'
                        waitlist:true
                        meal_id: Router.current().params.doc_id
                    Swal.fire(
                        'wait list joined',
                        "you'll be alerted if accepted"
                        'success'
                    )
            )

        'click .order_meal': ->
            if Meteor.user().credit >= @price_per_serving
                if @serving_unit
                    serving_text = @serving_unit
                else
                    serving_text = 'serving'
                Swal.fire({
                    title: "confirm buy #{serving_text}"
                    text: "this will charge you #{@price_per_serving} credits"
                    icon: 'question'
                    showCancelButton: true,
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                }).then((result) =>
                    if result.value
                        Meteor.call 'order_meal', @_id, (err, res)->
                            if err
                                Swal.fire(
                                    'err'
                                    'error'
                                )
                                console.log err
                            else
                                Swal.fire(
                                    'order and payment processed'
                                    ''
                                    'success'
                                )
            )
            else
                alert 'need more credit'
                # deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
                # stripe_charge = parseFloat(deposit_amount)*100*1.02+20
                stripe_charge = 1000
                # stripe_charge = parseInt(deposit_amount*1.02+20)

                # if confirm "add #{deposit_amount} credit?"
                Template.instance().checkout.open
                    name: 'credit deposit'
                    # email:Meteor.user().emails[0].address
                    description: 'wc top up'
                    amount: stripe_charge


if Meteor.isServer
    Meteor.publish 'dish_from_meal_id', (meal_id)->
        meal = Docs.findOne meal_id
        Docs.find
            model:'dish'
            _id:meal.dish_id

    Meteor.publish 'orders_from_meal_id', (meal_id)->
        # meal = Docs.findOne meal_id
        Docs.find
            model:'order'
            meal_id:meal_id

    Meteor.publish 'ingredients_from_meal_id', (meal_id)->
        meal = Docs.findOne meal_id
        dish = Docs.findOne meal.dish_id
        Docs.find
            model:'ingredient'
            _id:$in:dish.ingredient_ids
