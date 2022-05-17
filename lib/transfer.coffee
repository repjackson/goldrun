if Meteor.isClient
    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'all_users'
        
    Template.transfer_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'product_from_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        Docs.find 
            _id:transfer.product_id
if Meteor.isClient
    Template.transfer_edit.onCreated ->
        @autorun => Meteor.subscribe 'target_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id, ->', Router.current().params.doc_id, ->

    Template.transfer_view.helpers
        target: ->
            transfer = Docs.findOne Router.current().params.doc_id
            if transfer and transfer.target_user_id
                Meteor.users.findOne
                    _id: transfer.target_user_id

    Template.transfer_edit.helpers
        # terms: ->
        #     Terms.find()
        suggestions: ->
            Results.find(model:'tag')
        target: ->
            transfer = Docs.findOne Router.current().params.doc_id
            if transfer and transfer.target_user_id
                Meteor.users.findOne
                    _id: transfer.target_user_id
        members: ->
            transfer = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                # levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
            }, {
                sort:points:1
                limit:10
                })
        # subtotal: ->
        #     transfer = Docs.findOne Router.current().params.doc_id
        #     transfer.amount*transfer.target_user_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            transfer = Docs.findOne Router.current().params.doc_id
            transfer.amount and transfer.target_user_id
    Template.transfer_edit.events
        'click .add_target': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    target_user_id:@_id
        'click .remove_target': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    target_user_id:1
        'keyup .new_tag': _.throttle((e,t)->
            query = $('.new_tag').val()
            if query.length > 0
                Session.set('searching', true)
            else
                Session.set('searching', false)
            Session.set('current_query', query)
            
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                picked_tags.push element_val
                Meteor.call 'log_term', element_val, ->
                Session.set('searching', false)
                Session.set('current_query', '')
                Session.set('dummy', !Session.get('dummy'))
                t.$('.new_tag').val('')
        , 1000)

        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            picked_tags.remove element
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
            Session.set('dummy', !Session.get('dummy'))
    
    
        'click .select_term': (e,t)->
            # picked_tags.push @title
            Docs.update Router.current().params.doc_id,
                $addToSet:tags:@title
            picked_tags.push @title
            $('.new_tag').val('')
            Session.set('current_query', '')
            Session.set('searching', false)
            Session.set('dummy', !Session.get('dummy'))

    
        'click .cancel_transfer': ->
            Docs.remove @_id
            Router.go '/docs'
            
        'click .submit': ->
            Meteor.call 'send_transfer', @_id, =>
                $('body').toast({
                    title: "dark mode toggled"
                    # message: 'Please see desk staff for key.'
                    class : 'info'
                    icon:'remove'
                    position:'bottom right'
                    # className:
                    #     toast: 'ui massive message'
                    # displayTime: 5000
                    transition:
                      showMethod   : 'zoom',
                      showDuration : 250,
                      hideMethod   : 'fade',
                      hideDuration : 250
                    })
                Router.go "/doc/#{@_id}"



if Meteor.isServer
    Meteor.publish 'target_from_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        if transfer
            Meteor.users.findOne transfer.target_user_id
    Meteor.methods
        send_transfer: (transfer_id)->
            transfer = Docs.findOne transfer_id
            target = Meteor.users.findOne transfer.target_user_id
            transferer = Meteor.users.findOne transfer._author_id

            console.log 'sending transfer', transfer
            Meteor.call 'recalc_one_stats', target._id, ->
            Meteor.call 'recalc_one_stats', transfer._author_id, ->
    
            Docs.update transfer_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
            return