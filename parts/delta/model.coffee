if Meteor.isClient
    Template.model_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_actions', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
    Template.model_edit.events
        'click .save_model': (e,t)->
            model = Docs.findOne Router.current().params.doc_id
            $(e.currentTarget).closest('.button').transition('zoom', 500)
            $(e.currentTarget).closest('.grid').transition('scale', 500)
            Meteor.setTimeout ->
                Router.go "/m/#{model.slug}"
            , 500

        'click #delete_model': (e,t)->
            if confirm 'delete model?'
                Docs.remove Router.current().params.doc_id, ->
                    Router.go "/"
        'click .add_field': ->
            field_count = Docs.find(
                model:'field'
                parent_id: Router.current().params.doc_id
            ).count()
            Docs.insert
                model:'field'
                parent_id: Router.current().params.doc_id
                view_roles: ['dev', 'admin', 'student', 'public']
                edit_roles: ['dev', 'admin', 'student']
                rank: field_count*10
        'click .add_action': ->
            action_count = Docs.find(
                model:'action'
                parent_id: Router.current().params.doc_id
            ).count()
            Docs.insert
                model:'action'
                parent_id: Router.current().params.doc_id
                view_roles: ['dev', 'admin', 'student', 'public']
                edit_roles: ['dev', 'admin', 'student']
                rank: action_count*10




    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

    # Template.model_edit.events
    #     'click #delete_model': ->
    #         if confirm 'Confirm delete doc'
    #             Docs.remove @_id
    #             Router.go "/m/model"

    Template.delta_field_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.delta_field_edit.helpers
        is_ref: -> @field_type in ['single_doc', 'multi_doc','children']
        is_user_ref: -> @field_type in ['single_user', 'multi_user']


    Template.model_doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_actions', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_docs', 'action'
        @autorun -> Meteor.subscribe 'model_docs', 'action_type'
        # console.log Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'upvoters', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'downvoters', Router.current().params.doc_id
    Template.model_doc_view.helpers
        template_exists: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            if Template["#{current_model}_edit"]
                # console.log 'true'
                return true
            else
                # console.log 'false'
                return false
        model_template: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            "#{current_model}_view"
        actions: ->
            Docs.find
                model:"action"
        action_types: ->
            Docs.find
                model:"action_type"


    Template.model_doc_view.events
        'click .back_to_model': (e,t)->
            Session.set 'loading', true
            current_model = Router.current().params.model_slug
            Meteor.call 'set_facets', current_model, ->
                Session.set 'loading', false
            $(e.currentTarget).closest('.grid').transition('fade left', 500)
            Meteor.setTimeout ->
                Router.go "/m/#{current_model}"
            , 500




    Template.model_doc_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
    Template.model_doc_edit.helpers
        template_exists: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            if Template["#{current_model}_edit"]
                return true
            else
                return false
        model_template: ->
            current_model = Docs.findOne(Router.current().params.doc_id).model
            "#{current_model}_edit"
    Template.model_doc_edit.events
        'click #delete_doc': ->
            if confirm 'Confirm delete doc'
                Docs.remove @_id
                Router.go "/m/#{@model}"











if Meteor.isClient
    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), Router.current().params.model_slug
    Template.model_view.helpers
        model: ->
            Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
        model_docs: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            Docs.find
                model:model.slug
        model_doc: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            "#{model.slug}_view"
        fields: ->
            Docs.find { model:'field' }, sort:rank:1
                # parent_id: Router.current().params.doc_id
    Template.model_view.events
        'click .add_child': ->
            model = Docs.findOne slug:Router.current().params.model_slug
            console.log model
            # new_id = Docs.insert
            #     model: Router.current().params.model_slug
            # Router.go "/edit/#{new_id}"

    Template.model_edit.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'child_docs', Router.current().params.doc_id
    Template.model_edit.helpers
        model: ->
            doc_id = Router.current().params.doc_id
            # console.log doc_id
            Docs.findOne doc_id
        fields: ->
            Docs.find {
                model:'field'
                parent_id: Router.current().params.doc_id
            }, sort:rank:1
        actions: ->
            Docs.find {
                model:'action'
                parent_id: Router.current().params.doc_id
            }, sort:rank:1




if Meteor.isServer
    Meteor.publish 'model', (slug)->
        Docs.find
            model:'model'
            slug:slug
    Meteor.publish 'model_fields', (slug)->
        model = Docs.findOne
            model:'model'
            slug:slug
        if model
            Docs.find
                model:'field'
                parent_id:model._id
    Meteor.publish 'model_actions', (slug)->
        model = Docs.findOne
            model:'model'
            slug:slug
        if model
            Docs.find
                model:'action'
                parent_id:model._id
