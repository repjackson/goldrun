if Meteor.isClient 
    Template.checkin_widget.onCreated ->
        @autorun => @subscribe 'child_docs', 'checkin', Router.current().params.doc_id, ->
    Template.checkin_widget.events 
        'click .checkin': ->
            Docs.insert 
                model:'checkin'
                active:true
                group_id:Router.current().params.doc_id
                parent_id:Router.current().params.doc_id
        'click .checkout': ->
            active_doc =
                Docs.findOne 
                    model:'checkin'
                    active:true
                    parent_id:Router.current().params.doc_id
            if active_doc
                Docs.update active_doc._id, 
                    $set:
                        active:false
                        checkout_timestamp:Date.now()
                    
                    
    Template.checkin_widget.helpers
        checkin_docs: ->
            Docs.find {
                model:'checkin'
                parent_id:Router.current().params.doc_id
            }, sort:_timestamp:-1
        checked_in: ->
            Docs.findOne 
                model:'checkin'
                _author_id:Meteor.userId()
                active:true
        
        
