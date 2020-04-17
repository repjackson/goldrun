if Meteor.isClient
    Router.route '/alpha', (->
        @layout 'layout'
        @render 'alpha'
        ), name:'alpha'

    Template.alpha.onCreated ->
        @autorun -> Meteor.subscribe 'my_alpha'


    Template.alpha.helpers
        selected_tags: -> selected_tags.list()
        current_alpha: ->
            Docs.findOne
                model:'alpha'
                # _author_id:Meteor.userId()
        global_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()
        single_doc: ->
            alpha = Docs.findOne model:'alpha'
            count = alpha.result_ids.length
            if count is 1 then true else false

    Template.alpha.events
        'click .new_doc': ->
            new_id = Docs.insert({})
            Router.go "/edit/#{new_id}"
        'click .create_alpha': (e,t)->
            Docs.insert
                model:'alpha'
        'click .print_alpha': (e,t)->
            alpha = Docs.findOne model:'alpha'
            console.log alpha
        'click .reset': ->
            alpha = Docs.findOne model:'alpha'
            Meteor.call 'afum', alpha._id, (err,res)->
        'click .delete_alpha': (e,t)->
            alpha = Docs.findOne model:'alpha'
            if alpha
                if confirm "delete  #{alpha._id}?"
                    Docs.remove alpha._id
        'click .select_tag': -> selected_tags.push @name
        'click .unselect_tag': -> selected_tags.remove @valueOf()
        'click #clear_tags': -> selected_tags.clear()
        'keyup #search': (e)->
            switch e.which
                when 13
                    if e.target.value is 'clear'
                        selected_tags.clear()
                        $('#search').val('')
                    else
                        selected_tags.push e.target.value.toLowerCase().trim()
                        $('#search').val('')
                when 8
                    if e.target.value is ''
                        selected_tags.pop()


    Template.afacet.events
        # 'click .ui.accordion': ->
        #     $('.accordion').accordion()

        'click .toggle_selection': ->
            alpha = Docs.findOne model:'alpha'
            facet = Template.currentData()

            Session.set 'loading', true
            if facet.filters and @name in facet.filters
                Meteor.call 'remove_facet_filter', alpha._id, facet.key, @name, ->
                    Session.set 'loading', false
            else
                Meteor.call 'add_facet_filter', alpha._id, facet.key, @name, ->
                    Session.set 'loading', false

        'keyup .add_filter': (e,t)->
            # console.log @
            if e.which is 13
                alpha = Docs.findOne model:'alpha'
                facet = Template.currentData()
                if @field_type is 'number'
                    filter = parseInt t.$('.add_filter').val()
                else
                    filter = t.$('.add_filter').val()
                Session.set 'loading', true
                Meteor.call 'add_facet_filter', alpha._id, facet.key, filter, ->
                    Session.set 'loading', false
                t.$('.add_filter').val('')

    Template.afacet.helpers
        filtering_res: ->
            alpha = Docs.findOne model:'alpha'
            filtering_res = []
            if @key is '_keys'
                @res
            else
                for filter in @res
                    if filter.count < alpha.total
                        filtering_res.push filter
                    else if filter.name in @filters
                        filtering_res.push filter
                filtering_res
        toggle_value_class: ->
            facet = Template.parentData()
            alpha = Docs.findOne model:'alpha'
            if Session.equals 'loading', true
                 'disabled'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else ''



    Template.alpha_result.onRendered ->
        # Meteor.setTimeout ->
        #     $('.progress').popup()
        # , 2000
    Template.alpha_result.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data._id
        @autorun => Meteor.subscribe 'user_from_id', @data._id

    Template.alpha_result.helpers
        template_exists: ->
            current_model = Router.current().params.model_slug
            if Template["#{current_model}_card_template"]
                # console.log 'true'
                return true
            else
                # console.log 'false'
                return false

        model_template: ->
            current_model = Router.current().params.model_slug
            "#{current_model}_card_template"

        toggle_value_class: ->
            facet = Template.parentData()
            alpha = Docs.findOne model:'alpha'
            if Session.equals 'loading', true
                 'disabled'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else ''

        result: ->
            if Docs.findOne @_id
                # console.log 'doc'
                result = Docs.findOne @_id
                if result.private is true
                    if result._author_id is Meteor.userId()
                        result
                else
                    result

            # else if Meteor.users.findOne @_id
            #     # console.log 'user'
            #     Meteor.users.findOne @_id

    Template.alpha_result.events
        # 'click .result': ->
        #     # console.log @
        #     model_slug =  Router.current().params.model_slug
        #     #
        #     if Meteor.user()
        #         Docs.update @_id,
        #             $inc: views: 1
        #             $addToSet:viewer_usernames:Meteor.user().username
        #     # else
        #     #     Docs.update @_id,
        #     #         $inc: views: 1
        #     if @model is 'model'
        #         Router.go "/m/#{@slug}"
        #     else if @model is 'classroom'
        #         Router.go "/classroom/#{@_id}"
        #     else
        #         Router.go "/m/#{model_slug}/#{@_id}/view"

        'click .set_model': ->
            Meteor.call 'set_facets', @slug, Meteor.userId()

        'click .route_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false
            # alpha = Docs.findOne model:'alpha'
            # Docs.update alpha._id,
            #     $set:model_filter:@slug
            #
            # Meteor.call 'fum', alpha._id, (err,res)->



    Template.detect.events
        'click .detect_fields': ->
            # console.log @
            Meteor.call 'detect_fields', @_id

    Template.key_view.helpers
        key: -> @valueOf()
        meta: ->
            key_string = @valueOf()
            parent = Template.parentData()
            parent["_#{key_string}"]
        context: ->
            # console.log @
            {key:@valueOf()}
        field_view: ->
            console.log @
            key_string = @valueOf()
            console.log Template.parentData(1)
            console.log Template.parentData(2)
            console.log Template.parentData(3)
            console.log Template.parentData(4)
            console.log Template.parentData(5)
            meta = Template.parentData(2)["_#{@key}"]
            # console.log meta
            # console.log "#{meta.field}_view"
            if meta.field
                "#{meta.field}_view"






if Meteor.isServer
    Meteor.publish 'my_alpha', ->
        if Meteor.userId()
            Docs.find
                _author_id:Meteor.userId()
                model:'alpha'
        else
            Docs.find
                _author_id:null
                model:'alpha'
