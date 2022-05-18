if Meteor.isClient
    Router.route '/mail/inbox', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'inbox'
    Router.route 'mail/drafts', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'drafts'
    Router.route 'mail/sent', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'sent'
    Router.route 'mail/archive', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'archive'

    Template.inbox.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'message', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'my_received_messages', ->
        @autorun => Meteor.subscribe 'my_sent_messages', ->
        # @autorun => Meteor.subscribe 'inbox', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'stat', ->

if Meteor.isServer 
    Meteor.publish 'my_received_messages', ->
        Docs.find 
            model:'message'
            target_user_id:Meteor.userId()
    Meteor.publish 'my_sent_messages', ->
        Docs.find 
            model:'message'
            _author_id:Meteor.userId()

if Meteor.isClient
    Template.inbox.events
        'click .add_message': ->
            new_message_id =
                Docs.insert
                    model:'message'
                    cost:10
                    sent:false
            Router.go "/message/#{new_message_id}/edit"

    Template.recent_logs.onCreated ->
        @autorun => @subscribe 'recent_logs', ->
            
            
    Template.log_item.helpers
        read_class: ->
            if @read_user_ids and Meteor.userId() in @read_user_ids then 'small' else 'large raised'
            
            
if Meteor.isServer
    Meteor.publish 'recent_logs', ->
        Docs.find 
            model:'log'
            
if Meteor.isClient            
    Template.recent_logs.helpers
        unread_log_count: ->
            Docs.find(
                model:'log'
                read_user_ids:$nin:[Meteor.userId()]
            ).count()

        logs: ->
            Docs.find {
                model:'log'
            }, sort:_timestamp:-1
    Template.inbox.helpers
        my_sent_messages: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'message'
                _author_id: Meteor.userId()
                # target: target_user._id
            },
                sort:_timestamp:-1

        my_received_messages: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'message'
                target_user_id: Meteor.userId()
                # target: target_user._id
            },
                sort:_timestamp:-1

    Template.toggle_view_icon.helpers
        has_read: ->
            @read_user_ids and Meteor.userId() in @read_user_ids
    Template.toggle_view_icon.events
        'click .mark_read': ->
            Meteor.call 'mark_read', @_id, ->
        'click .mark_unread': ->
            Meteor.call 'mark_unread', @_id, ->
            

if Meteor.isClient
    Router.route '/messages/', (->
        @layout 'layout'
        @render 'messages'
        ), name:'messages'
    

    Router.route '/message/:doc_id', (->
        @layout 'layout'
        @render 'message_view'
        ), name:'message_view'

    Template.message_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_message_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        
    Template.message_view.onRendered ->



            
if Meteor.isClient
    Router.route '/message/:doc_id/edit', (->
        @layout 'layout'
        @render 'message_edit'
        ), name:'message_edit'
        
        
    Template.message_edit.onCreated ->
        @autorun => Meteor.subscribe 'target_from_message_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->


    Template.message_edit.helpers
        _target: ->
            message = Docs.findOne Router.current().params.doc_id
            if message.target_user_id
                Meteor.users.findOne
                    _id: message.target_user_id
        available_targets: ->
            message = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                # levels: $in: ['member']
                _id: $ne: Meteor.userId()
        # subtotal: ->
        #     message = Docs.findOne Router.current().params.doc_id
        #     message.amount*message.target_user_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_send: ->
            true
            message = Docs.findOne Router.current().params.doc_id
            message.description and message.target_user_id
            
            
    Template.message_edit.events
        'click .add_target': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    target_user_id:@_id
        'click .remove_target': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    target_user_id:1
        'keyup .new_element': (e,t)->
            if e.which is 13
                element_val = t.$('.new_element').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                t.$('.new_element').val('')
    
        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_element').focus()
            t.$('.new_element').val(element)
    
    
        # 'click .result': (e,t)->
        #     Meteor.call 'log_term', @title, ->
        #     picked_tags.push @title
        #     $('#search').val('')
        #     Meteor.call 'call_wiki', @title, ->
        #     Meteor.call 'calc_term', @title, ->
        #     Meteor.call 'omega', @title, ->
        #     Session.set('current_query', '')
        #     Session.set('searching', false)
    
        #     Meteor.call 'search_reddit', picked_tags.array(), ->
        #     # Meteor.setTimeout ->
        #     #     Session.set('dummy', !Session.get('dummy'))
        #     # , 7000

    
        # 'blur .edit_description': (e,t)->
        #     textarea_val = t.$('.edit_textarea').val()
        #     Docs.update Router.current().params.doc_id,
        #         $set:description:textarea_val
    
    
        # 'blur .edit_text': (e,t)->
        #     val = t.$('.edit_text').val()
        #     Docs.update Router.current().params.doc_id,
        #         $set:"#{@key}":val
    
    


if Meteor.isClient
    Template.message_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'target_from_message_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    Template.message_edit.onRendered ->


    Template.message_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Swal.fire({
                title: "confirm send message?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'send_message', @_id, =>
                        Swal.fire(
                            title:"message sent"
                            icon:'success'
                            # showClass:
                            #     popup: 'swal2-noanimation',
                            #     backdrop: 'swal2-noanimation'
                            # hideClass:
                            #     popup: '',
                            #     backdrop: ''
                            showConfirmButton: false
                            timer: 1000
                        )
                        Router.go "/message/#{@_id}"
            )


    Template.message_edit.helpers
    Template.message_edit.events

if Meteor.isServer
    Meteor.methods
        send_message: (message_id)->
            message = Docs.findOne message_id
            target = Meteor.users.findOne message.target_user_id
            sender = Meteor.users.findOne message._author_id

            console.log 'sending message', message
            Meteor.users.update sender._id,
                $inc:
                    unread_message_count:1
            Docs.update message_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update message_id,
                $set:
                    submitted:true
            