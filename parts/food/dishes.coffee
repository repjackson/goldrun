if Meteor.isClient
    Router.route '/dish/:doc_id/view', (->
        @layout 'layout'
        @render 'dish_view'
        ), name:'dish_view'


    Template.dish_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'
        @autorun => Meteor.subscribe 'model_docs', 'meal'
        @autorun => Meteor.subscribe 'users'



if Meteor.isClient
    Router.route '/dish/:doc_id/edit', (->
        @layout 'layout'
        @render 'dish_edit'
        ), name:'dish_edit'

    Template.dish_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'ingredient'


    Template.dish_edit.helpers
        dish_ingredients: ->
            dish = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'ingredient'
                _id: $in:dish.ingredient_ids

        protein_ingredients: ->
            dish = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'ingredient'
                _id: $in:dish.ingredient_ids
                food_category:'protein'

        current_ingredient_query: -> Session.get('current_ingredient_query')
        ingredient_results: -> Session.get('ingredient_results')

    Template.dish_edit.events
        'keyup .search_ingredient': (e,t)->
            val = $('.search_ingredient').val()
            Session.set('current_ingredient_query', val)
            if e.which is 13
                console.log @
                found_ingredient =
                    Docs.findOne
                        model:'ingredient'
                        title:val
                if found_ingredient
                    Docs.update Router.current().params.doc_id,
                        $addToSet:
                            ingredient_ids: found_ingredient._id
                else
                    new_ingredient_id =
                        Docs.insert
                            model:'ingredient'
                            title: Session.get('current_ingredient_query')

                    Docs.update Router.current().params.doc_id,
                        $addToSet:
                            ingredient_ids: new_ingredient_id
                Session.set('current_ingredient_query', null)
                $('.search_ingredient').val('')
            else
                console.log val
                results = Docs.find({
                    title: {$regex:"#{val}", $options: 'i'}
                    model:'ingredient'
                    },{limit:10}).fetch()
                Session.set('ingredient_results', results)


        'click .make_protein': ->
            console.log @
            Docs.update @_id,
                $set:
                    food_category: 'protein'

        'click .select_ingredient': ->
            console.log @
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    ingredient_ids: @_id

        'click .remove_ingredient': ->
            console.log @
            Docs.update Router.current().params.doc_id,
                $pull:
                    ingredient_ids: @_id


        'click .add_new_ingredient': ->
            console.log @
            new_ingredient_id =
                Docs.insert
                    model:'ingredient'
                    title: Session.get('current_ingredient_query')

            Docs.update Router.current().params.doc_id,
                $addToSet:
                    ingredient_ids: new_ingredient_id
            Session.set('current_ingredient_query', null)
            $('.search_ingredient').val('')
