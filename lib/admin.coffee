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


    Router.route '/search', -> @render 'search'
    Template.search.onCreated ->
        @autorun ->  Meteor.subscribe 'search_results', Session.get('global_query'), ->
    Template.search.events
        'keyup .global_search': (e,t)->
            query = $('.global_search').val()
            Session.set('global_query',query)
    Template.search.helpers
        current_search: -> Session.get('global_query')
        result_docs: ->
            Docs.find {
                title: {$regex:"#{Session.get('global_query')}",$options:'i'}
            }, 
            
if Meteor.isServer 
    Meteor.publish 'search_results', (global_query)->
        Docs.find {
            title: {$regex:"#{global_query}",$options:'i'}
        }, 
            limit:10
            sort:points:-1

if Meteor.isClient            
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
    