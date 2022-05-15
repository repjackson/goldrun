if Meteor.isClient
    Router.route '/posts', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'
    Router.route '/post/:doc_id', (->
        @layout 'post_layout'
        @render 'post_home'
        ), name:'post_home'
    Router.route '/post/:doc_id/emotion', (->
        @layout 'post_layout'
        @render 'post_emotion'
        ), name:'post_emotion'
    Router.route '/post/:doc_id/stats', (->
        @layout 'post_layout'
        @render 'post_stats'
        ), name:'post_stats'
    Router.route '/post/:doc_id/tips', (->
        @layout 'post_layout'
        @render 'post_tips'
        ), name:'post_tips'
    Router.route '/post/:doc_id/comments', (->
        @layout 'post_layout'
        @render 'post_comments'
        ), name:'post_comments'
    
    
    # Template.posts.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'post', ->
    Template.posts.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', '_timestamp'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'sort_direction', 1
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

    Template.posts.onCreated ->
        # @autorun => @subscribe 'model_docs', 'post', ->
        @autorun => @subscribe 'facets',
            'post'
            picked_tags.array()
            Session.get('current_search')
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')

        @autorun => @subscribe 'results',
            'post'
            picked_tags.array()
            Session.get('current_search')
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')

    Template.post_layout.onCreated ->
        @autorun => @subscribe 'related_group',Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.post_layout.onCreated ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->

    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.post_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.post_tips.onCreated ->
        @autorun => @subscribe 'post_tips',Router.current().params.doc_id, ->
    Template.post_tips.events 
        'click .tip_post': ->
            # console.log 'hi'
            new_id = 
                Docs.insert 
                    model:'transfer'
                    post_id:Router.current().params.doc_id
                    complete:true
                    amount:10
                    tags:['tip']
            Meteor.call 'calc_user_points', ->
    Template.post_tips.helpers 
        post_tip_docs: ->
            Docs.find 
                model:'transfer'
                
                
if Meteor.isServer 
    Meteor.publish 'post_tips', (post_id)->
        Docs.find 
            model:'transfer'
            post_id:post_id
                
if Meteor.isClient
    Template.posts.helpers
        post_docs: ->
            Docs.find {
                model:'post'
            }, sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
            # }, sort:_timestamp:-1
        
                
    Template.posts.events
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
            Router.go "/post/#{new_id}/edit"
    Template.post_card.events
        'click .view_post': ->
            Router.go "/post/#{@_id}"
    Template.post_card_med.events
        'click .view_post': ->
            Router.go "/post/#{@_id}"
    Template.post_item.events
        'click .view_post': ->
            Router.go "/post/#{@_id}"

    Template.post_layout.events
        'click .add_post_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    post_ids:[@_id]
            Router.go "/recipe/#{new_id}/edit"

    
    
    Template.post_edit.events
        'click .delete_post': ->
            Swal.fire({
                title: "delete post?"
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
                        title: 'post removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/posts"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish post?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_post', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'post published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish post?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_post', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'post unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            

if Meteor.isClient
    Template.post_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.post_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.post_card.helpers
        post_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
            