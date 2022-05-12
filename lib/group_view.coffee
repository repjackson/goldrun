if Meteor.isClient 
    Template.checkin_widget.onCreated ->
        @autorun => @subscribe 'model_docs', 'checkin', ->
    Template.checkin_widget.events 
        'click .checkin': ->
            Docs.insert 
                model:'checkin'
                active:true
        'click .checkout': ->
            active_doc =
                Docs.findOne 
                    model:'checkin'
                    active:true
            if active_doc
                Docs.update active_doc._id, 
                    $set:
                        active:false
                        checkout_timestamp:Date.now()
                    
                    
    Template.checkin_widget.helpers
        checkin_docs: ->
            Docs.find {
                model:'checkin'
            }, sort:_timestamp:-1
        checked_in: ->
            Docs.findOne 
                model:'checkin'
                _author_id:Meteor.userId()
                active:true
        