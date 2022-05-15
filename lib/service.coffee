if Meteor.isClient
    Router.route '/services', (->
        @layout 'layout'
        @render 'services'
        ), name:'services'
    Router.route '/service/:doc_id/edit', (->
        @layout 'layout'
        @render 'service_edit'
        ), name:'service_edit'
    Router.route '/service/:doc_id', (->
        @layout 'layout'
        @render 'service_view'
        ), name:'service_view'
    Router.route '/service/:doc_id/view', (->
        @layout 'layout'
        @render 'service_view'
        ), name:'service_view_long'
    
    
    # Template.services.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'service', ->
    Template.services.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'member_count'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

    Template.services.onCreated ->
        # @autorun => @subscribe 'model_docs', 'service', ->
        @autorun => @subscribe 'facets',
            'service'
            picked_tags.array()
            # Session.get('limit')
            # Session.get('sort_key')
            # Session.get('sort_direction')
            # Session.get('view_delivery')
            # Session.get('view_pickup')
            # Session.get('view_open')

        @autorun => @subscribe 'doc_results',
            'service'
            picked_tags.array()
            Session.get('group_title_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')

    Template.service_view.onCreated ->
        @autorun => @subscribe 'related_groups',Router.current().params.doc_id, ->

        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.service_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.service_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.services.helpers
        service_docs: ->
            Docs.find {
                model:'service'
            }, sort:_timestamp:-1
                
    Template.services.events
        'click .view_service': -> Router.go "/service/#{@_id}"


    Template.service_edit.events
        'click .delete_service': ->
            Swal.fire({
                title: "delete service?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'service removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/service"
            )

            
