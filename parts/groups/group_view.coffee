Router.route '/group/:doc_id', (->
    @layout 'group_layout'
    @render 'group_dashboard'
    ), name:'group_dashboard'
Router.route '/group/:doc_id/members', (->
    @layout 'group_layout'
    @render 'group_members'
    ), name:'group_members'
Router.route '/group/:doc_id/credit', (->
    @layout 'group_layout'
    @render 'group_credit'
    ), name:'group_credit'
Router.route '/group/:doc_id/meals', (->
    @layout 'group_layout'
    @render 'group_meals'
    ), name:'group_meals'
Router.route '/group/:doc_id/dishes', (->
    @layout 'group_layout'
    @render 'group_dishes'
    ), name:'group_dishes'
Router.route '/group/:doc_id/voting', (->
    @layout 'group_layout'
    @render 'group_voting'
    ), name:'group_voting'
Router.route '/group/:doc_id/events', (->
    @layout 'group_layout'
    @render 'group_events'
    ), name:'group_events'
Router.route '/group/:doc_id/food', (->
    @layout 'group_layout'
    @render 'group_food'
    ), name:'group_food'
Router.route '/group/:doc_id/products', (->
    @layout 'group_layout'
    @render 'group_products'
    ), name:'group_products'
Router.route '/group/:doc_id/services', (->
    @layout 'group_layout'
    @render 'group_services'
    ), name:'group_services'
Router.route '/group/:doc_id/stats', (->
    @layout 'group_layout'
    @render 'group_stats'
    ), name:'group_stats'
Router.route '/group/:doc_id/transactions', (->
    @layout 'group_layout'
    @render 'group_transactions'
    ), name:'group_transactions'
Router.route '/group/:doc_id/messages', (->
    @layout 'group_layout'
    @render 'group_messages'
    ), name:'group_messages'
Router.route '/group/:doc_id/posts', (->
    @layout 'group_layout'
    @render 'group_posts'
    ), name:'group_posts'
Router.route '/group/:doc_id/settings', (->
    @layout 'group_layout'
    @render 'group_settings'
    ), name:'group_settings'



if Meteor.isClient
    Template.group_layout.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'children', 'group_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'members', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_dishes', Router.current().params.doc_id
    Template.group_layout.helpers
        current_group: ->
            Docs.findOne
                model:'group'
                slug: Router.current().params.doc_id

    Template.group_dashboard.events
        'click .refresh_group_stats': ->
            Meteor.call 'calc_group_stats', Router.current().params.doc_id, ->
        # 'click .join': ->
        #     Docs.update
        #         model:'group'
        #         _author_id: Meteor.userId()
        # 'click .group_leave': ->
        #     my_group = Docs.findOne
        #         model:'group'
        #         _author_id: Meteor.userId()
        #         ballot_id: Router.current().params.doc_id
        #     if my_group
        #         Docs.update my_group._id,
        #             $set:value:'no'
        #     else
        #         Docs.insert
        #             model:'group'
        #             ballot_id: Router.current().params.doc_id
        #             value:'no'


if Meteor.isServer
    Meteor.publish 'group_dishes', (doc_id)->
        group = Docs.findOne
            model:'group'
            slug:doc_id
        Docs.find
            model:'dish'
            _id: $in: group.dish_ids




Router.route '/group/:doc_id/edit', -> @render 'group_edit'

if Meteor.isClient
    Template.group_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'group_options', Router.current().params.doc_id
    Template.group_edit.events
        'click .add_option': ->
            Docs.insert
                model:'group_option'
                ballot_id: Router.current().params.doc_id
    Template.group_edit.helpers
        options: ->
            Docs.find
                model:'group_option'