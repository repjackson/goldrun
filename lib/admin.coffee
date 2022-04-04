if Meteor.isClient
    # Router.route '/admin', -> @render 'admin'
    Router.route '/admin', -> @render 'admin'
    Router.route '/add', -> @render 'add'
    
    Template.user_table.onCreated ->
        @autorun ->  Meteor.subscribe 'users'


    Template.add_button_big.events
        'click .add_model': ->
            new_id = 
                Docs.insert 
                    model:@model
            Router.go "/#{@model}/#{new_id}/edit"



    Template.user_table.helpers
        users: -> Meteor.users.find {}


    Template.user_table.events
        'click #add_user': ->

    Template.user_role_toggle.helpers
        is_in_role: ->
            Template.parentData().roles and @role in Template.parentData().roles

    Template.user_role_toggle.events
        'click .add_role': ->
            parent_user = Template.parentData()
            Meteor.users.update parent_user._id,
                $addToSet:roles:@role

        'click .remove_role': ->
            parent_user = Template.parentData()
            Meteor.users.update parent_user._id,
                $pull:roles:@role



    # Template.article_list.onCreated ->
    #     @autorun ->  Meteor.subscribe 'type', 'article'
    #
    #
    # Template.article_list.helpers
    #     articles: ->
    #         Docs.find
    #             model:'article'
    #
    # Template.article_list.events
    #     'click .add_article': ->
    #         Docs.insert
    #             model:'article'
    #
    #     'click .delete_article': ->
    #         if confirm 'Delete article?'
    #             Docs.remove @_id
if Meteor.isServer
    Meteor.publish 'users', (limit)->
        if limit
            Meteor.users.find({},limit:limit)
        else
            Meteor.users.find()
    