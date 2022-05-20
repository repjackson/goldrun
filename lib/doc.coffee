if Meteor.isClient
    Router.route '/doc/:doc_id/edit', (->
        @layout 'layout'
        @render 'doc_edit'
        ), name:'doc_edit'
    Template.doc_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_from_doc_id', Router.current().params.doc_id, ->
    Template.doc_edit.helpers
        model_template: -> "#{@model}_edit"
        doc_data: -> 
            # console.log 'hi'
            Docs.findOne Router.current().params.doc_id
    
    Router.route '/doc/:doc_id/', (->
        @layout 'layout'
        @render 'doc_view'
        ), name:'doc_view'
        
        
    Template.doc_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.doc_view.onCreated ->
        @autorun => Meteor.subscribe 'current_viewers', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'group_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_by_id', Router.current().params.doc_id, ->
    Template.doc_view.helpers
        model_template: -> "#{@model}_view"
        # current_doc: -> Docs.findOne Router.current().params.doc_id
        doc_data: -> 
            # console.log 'hi'
            Docs.findOne Router.current().params.doc_id
    Template.doc_view.events 
        'click .pick_flat_tag':(e)->
            doc = Docs.findOne Router.current().params.doc_id
            picked_tags.clear()
            picked_tags.push @valueOf()
            $(e.currentTarget).closest('.grid').transition('fly right', 500)
            
            Router.go "/docs"
            Session.set('model',doc.model)
        
    # Template.doc_card.helpers
    #     card_template: -> "#{@model}_card"
    Template.doc_card.helpers
        item_template: -> "#{@model}_item"
        
    Template.docs.onCreated ->
        Session.setDefault('model','post')
        Session.setDefault('limit',10)
        Session.setDefault('sort_key','_timestamp')
        # @autorun => @subscribe 'model_docs', 'post', ->
        @autorun => @subscribe 'user_info_min',
        @autorun => @subscribe 'facet_sub',
            Session.get('model')
            picked_tags.array()
            Session.get('current_search')
    
        @autorun => @subscribe 'doc_results',
            Session.get('model')
            picked_tags.array()
            Session.get('current_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
    
    
    Template.docs.helpers
        current_model: -> Session.get('model')
        result_docs: ->
            Docs.find {
                model:Session.get('model')
            }, 
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                limit:Session.get('limit')        
                
if Meteor.isServer
    Meteor.publish 'group_from_doc_id', (doc_id)->
        doc = Docs.findOne doc_id 
        Docs.find 
            model:'group'
            _id:doc.group_id