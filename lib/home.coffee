if Meteor.isClient
    Template.home.onCreated ->
        Session.setDefault 'limit', 20
        @autorun -> Meteor.subscribe 'public_posts', ->
        # @autorun -> Meteor.subscribe 'model_docs', 'post', ->
        @autorun -> Meteor.subscribe 'model_docs', 'chat_message', ->
        @autorun -> Meteor.subscribe 'model_docs', 'stat', ->
        @autorun -> Meteor.subscribe 'all_users', ->
        @autorun -> Meteor.subscribe 'latest_users', ->
            
    Template.home.onRendered ->
        Meteor.call 'log_homepage_view', ->        
    Template.home.events 
        'keyup .add_public_chat': (e,t)->
            val = t.$('.add_public_chat').val()
            if e.which is 13
                if val.length > 0
                    new_id = 
                        Docs.insert 
                            model:'chat_message'
                            chat_type:'public'
                            body:val
                    val = t.$('.add_public_chat').val('')
                    $('body').toast({
                        title: "message sent"
                        # message: 'Please see desk staff for key.'
                        class : 'success'
                        position:'bottom center'
                        # className:
                        #     toast: 'ui massive message'
                        # displayTime: 5000
                        transition:
                          showMethod   : 'zoom',
                          showDuration : 250,
                          hideMethod   : 'fade',
                          hideDuration : 250
                        })
                        
        'click .remove_comment': ->
            if confirm 'remove comment? cant be undone'
                Docs.remove @_id
        


    Template.latest_activity.helpers
        latest_docs: ->
            Docs.find {
                model:$ne:'chat_message'
                # private:$ne:true
            }, sort:_timestamp:-1
    Template.home.helpers
        homepage_data_doc: ->
            doc = 
                Docs.findOne 
                    model:'stat'
        latest_post_docs: ->
            Docs.find {
                model:'post'
                private:$ne:true
            }, 
                sort:_timestamp:-1
                limit:20
        top_users: ->
            Meteor.users.find {},
                sort:points:-1
                
    Template.latest_users.helpers
        latest_user_docs: ->
            Meteor.users.find {},
                sort:createdAt:-1
                limit:10
    Template.public_chat.helpers
        latest_chat_docs: ->
            Docs.find {
                model:'chat_message'
            }, sort:_timestamp:-1

if Meteor.isServer 
    Meteor.publish 'latest_users', ->
        Meteor.users.find {},
        sort:
            -createdAt:-1