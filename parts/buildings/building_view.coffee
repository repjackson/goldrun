Router.route '/building/:doc_id/view', (->
    @layout 'building_layout'
    @render 'building_dashboard'
    ), name:'building_dashboard'
Router.route '/building/:doc_id/members', (->
    @layout 'building_layout'
    @render 'building_members'
    ), name:'building_members'
Router.route '/building/:doc_id/credit', (->
    @layout 'building_layout'
    @render 'building_credit'
    ), name:'building_credit'
Router.route '/building/:doc_id/meals', (->
    @layout 'building_layout'
    @render 'building_meals'
    ), name:'building_meals'
Router.route '/building/:doc_id/dishes', (->
    @layout 'building_layout'
    @render 'building_dishes'
    ), name:'building_dishes'
Router.route '/building/:doc_id/market', (->
    @layout 'building_layout'
    @render 'building_market'
    ), name:'building_market'
Router.route '/building/:doc_id/events', (->
    @layout 'building_layout'
    @render 'building_events'
    ), name:'building_events'
Router.route '/building/:doc_id/food', (->
    @layout 'building_layout'
    @render 'building_food'
    ), name:'building_food'
Router.route '/building/:doc_id/products', (->
    @layout 'building_layout'
    @render 'building_products'
    ), name:'building_products'
Router.route '/building/:doc_id/services', (->
    @layout 'building_layout'
    @render 'building_services'
    ), name:'building_services'
Router.route '/building/:doc_id/stats', (->
    @layout 'building_layout'
    @render 'building_stats'
    ), name:'building_stats'
Router.route '/building/:doc_id/transactions', (->
    @layout 'building_layout'
    @render 'building_transactions'
    ), name:'building_transactions'
Router.route '/building/:doc_id/messages', (->
    @layout 'building_layout'
    @render 'building_messages'
    ), name:'building_messages'
Router.route '/building/:doc_id/posts', (->
    @layout 'building_layout'
    @render 'building_posts'
    ), name:'building_posts'



if Meteor.isClient
    Template.building_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'children', 'building_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'building_dishes', Router.current().params.building_slug
    Template.building_layout.helpers
        current_building: ->
            Docs.findOne
                model:'building'
                slug: Router.current().params.building_slug

    Template.building_dashboard.events
        'click .refresh_building_stats': ->
            Meteor.call 'calc_building_stats', Router.current().params.building_slug, ->
        # 'click .join': ->
        #     Docs.update
        #         model:'building'
        #         _author_id: Meteor.userId()
        # 'click .building_leave': ->
        #     my_building = Docs.findOne
        #         model:'building'
        #         _author_id: Meteor.userId()
        #         ballot_id: Router.current().params.doc_id
        #     if my_building
        #         Docs.update my_building._id,
        #             $set:value:'no'
        #     else
        #         Docs.insert
        #             model:'building'
        #             ballot_id: Router.current().params.doc_id
        #             value:'no'


if Meteor.isServer
    Meteor.publish 'building_dishes', (building_slug)->
        building = Docs.findOne
            model:'building'
            slug:doc_id
        Docs.find
            model:'dish'
            _id: $in: building.dish_ids
