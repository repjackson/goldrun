if Meteor.isClient
    Template.post_view.onCreated ->
        @autorun => @subscribe 'related_group',Router.current().params.doc_id, ->
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
                    amount:@amount
                    transfer_type:'tip'
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
    # Template.posts.helpers
    #     post_docs: ->
    #         Docs.find {
    #             model:'post'
    #         }, 
    #             sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
    #             limit:Session.get('limit')        
                
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
                    Router.go "/docs"
            )
