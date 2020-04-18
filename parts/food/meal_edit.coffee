if Meteor.isClient
    Router.route '/meal/:doc_id/edit', (->
        @layout 'layout'
        @render 'meal_edit'
        ), name:'meal_edit'



    Template.meal_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'dish'

    Template.meal_edit.onRendered ->
        Meteor.setTimeout ->
            today = new Date()
            $('#availability')
                .calendar({
                    minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
                    maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
                })
        , 2000

    Template.meal_edit.helpers
        all_dishes: ->
            Docs.find
                model:'dish'
        can_delete: ->
            meal = Docs.findOne Router.current().params.doc_id
            if meal.reservation_ids
                if meal.reservation_ids.length > 1
                    false
                else
                    true
            else
                true


    Template.meal_edit.events
        'click .save_meal': ->
            meal_id = Router.current().params.doc_id
            Meteor.call 'calc_meal_data', meal_id, ->
            Router.go "/meal/#{meal_id}/view"


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





        'click .select_dish': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    dish_id: @_id


        'click .clear_dish': ->
            if confirm 'clear dish?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        dish_id: null



        'click .delete_meal': ->
            if confirm 'refund orders and cancel meal?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"
