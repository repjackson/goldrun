if Meteor.isClient
    Router.route '/food/:doc_id/edit', (->
        @layout 'layout'
        @render 'food_edit'
        ), name:'food_edit'



    Template.food_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'dish'

    Template.food_edit.onRendered ->
        Meteor.setTimeout ->
            today = new Date()
            $('#availability')
                .calendar({
                    inline:true
                    # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
                    # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
                })
        , 2000

    Template.food_edit.helpers
        all_dishes: ->
            Docs.find
                model:'dish'
        can_delete: ->
            food = Docs.findOne Router.current().params.doc_id
            if food.reservation_ids
                if food.reservation_ids.length > 1
                    false
                else
                    true
            else
                true


    Template.food_edit.events
        'click .save_food': ->
            food_id = Router.current().params.doc_id
            Meteor.call 'calc_food_data', food_id, ->
            Router.go "/food/#{food_id}/view"


        'click .save_availability': ->
            doc_id = Router.current().params.doc_id
            availability = $('.ui.calendar').calendar('get date')[0]
            console.log availability
            formatted = moment(availability).format("YYYY-MM-DD[T]HH:mm")
            console.log formatted
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'minutes',true)
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'hours',true)
            Docs.update doc_id,
                $set:datetime_available:formatted





        # 'click .select_dish': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             dish_id: @_id
        #
        #
        # 'click .clear_dish': ->
        #     if confirm 'clear dish?'
        #         Docs.update Router.current().params.doc_id,
        #             $set:
        #                 dish_id: null



        'click .delete_food': ->
            if confirm 'refund orders and cancel food?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"
