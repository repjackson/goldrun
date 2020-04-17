if Meteor.isClient
    Template.facet_staff_select.onCreated ->
        @autorun => Meteor.subscribe 'facet_doc', @data.tags

    Template.facet_staff_select.helpers
        facet_doc: ->
            tags = Template.currentData().tags
            split_array = tags.split ','

            Docs.findOne
                tags: split_array

        template_tags: -> Template.currentData().tags

        doc_classes: -> Template.parentData().classes

    Template.facet_staff_select.events
        'click .create_doc': (e,t)->
            tags = t.data.tags
            split_array = tags.split ','
            new_id = Docs.insert
                tags: split_array
            Session.set 'editing_id', new_id

        'blur #staff': ->
            staff = $('#staff').val()
            Docs.update @_id,
                $set: staff: staff





    Template.inline_doc.onCreated ->
        @autorun => Meteor.subscribe 'inline_doc', @data.slug

    Template.inline_doc.helpers
        inline_doc: ->
            slug = Template.instance().data.slug
            Docs.findOne
                model:'inline_doc'
                slug:slug

        doc_classes: ->
            Template.instance().data.classes

    Template.inline_doc.events
        'click .create_doc': (e,t)->
            slug = t.data.slug
            new_id = Docs.insert
                model:'inline_doc'
                slug:slug
            Session.set 'editing_id', new_id

        'blur #body': ->
            body = $('#body').val()
            Docs.update @_id,
                $set: body: body
