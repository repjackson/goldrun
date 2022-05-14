if Meteor.isClient
    Router.route '/invoices', (->
        @layout 'layout'
        @render 'invoices'
        ), name:'invoices'
    Router.route '/invoice/:doc_id/edit', (->
        @layout 'layout'
        @render 'invoice_edit'
        ), name:'invoice_edit'
    Router.route '/invoice/:doc_id', (->
        @layout 'layout'
        @render 'invoice_view'
        ), name:'invoice_view'
    
    
    # Template.invoices.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'invoice', ->
    Template.invoices.onCreated ->
        Session.setDefault 'view_mode', 'cards'
        Session.setDefault 'sort_key', 'points'
        Session.setDefault 'sort_direction', -1
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

    Template.invoices.onCreated ->
        @autorun => @subscribe 'model_docs','stat',->
        @autorun => @subscribe 'results',
            'invoice'
            picked_tags.array()
            Session.get('current_query')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')

    Template.invoice_view.onCreated ->
        @autorun => @subscribe 'related_group',Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.invoice_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.invoice_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->

                
    Template.invoices.helpers
        invoice_stat_doc: ->
            Docs.findOne
                model:'stat'
    Template.invoices.events
        'click .add_invoice': ->
            new_id = 
                Docs.insert 
                    model:'invoice'
            Router.go "/invoice/#{new_id}/edit"
    Template.invoice_card.events
        'click .view_invoice': ->
            Router.go "/invoice/#{@_id}"
    Template.invoice_item.events
        'click .view_invoice': ->
            Router.go "/invoice/#{@_id}"


    Template.invoice_edit.events
        'click .delete_invoice': ->
            Swal.fire({
                title: "delete invoice?"
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
                        title: 'invoice removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/invoices"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish invoice?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_invoice', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'invoice published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish invoice?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_invoice', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'invoice unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.methods 
        calc_stats: ->
            console.log 'calculating stats'
            doc = 
                Docs.findOne 
                    model:'stat'
            unless doc 
                Docs.insert model:'stat'
            total_sent_amount = 0
            sent_invoices = 
                Docs.find(model:'invoice').fetch()
            for invoice in sent_invoices
                if invoice.amount
                    total_sent_amount += invoice.amount
            
            total_paid_amount = 0
            paid_invoices = 
                Docs.find(model:'invoice',paid:true).fetch()
            for invoice in paid_invoices
                if invoice.amount
                    total_paid_amount += invoice.amount
            Docs.update doc._id,
                $set:
                    total_invoice_amount:total_sent_amount
                    total_paid_amount:total_paid_amount
            console.log doc      
                    
                    
                    
                    
                    
                    
    Meteor.publish 'invoice_count', (
        picked_ingredients
        picked_sections
        current_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_ingredients
        self = @
        match = {model:'invoice'}
        if picked_ingredients.length > 0
            match.ingredients = $all: picked_ingredients
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if current_query and current_query.length > 1
            console.log 'searching current_query', current_query
            match.title = {$regex:"#{current_query}", $options: 'i'}
        Counts.publish this, 'invoice_counter', Docs.find(match)
        return undefined
