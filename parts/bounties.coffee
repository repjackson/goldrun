if Meteor.isClient
    Router.route '/bounties', (->
        @layout 'layout'
        @render 'bounties'
        ), name:'bounties'
    Router.route '/bounty/:doc_id/edit', (->
        @layout 'layout'
        @render 'bounty_edit'
        ), name:'bounty_edit'
    Router.route '/bounty/:doc_id/view', (->
        @layout 'layout'
        @render 'bounty_view'
        ), name:'bounty_view'



    Template.bounties.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'bounty'
        @autorun -> Meteor.subscribe('bounties',
            selected_tags.array()
            Session.get('view_complete')
            Session.get('view_incomplete')
            )
        @autorun => Meteor.subscribe 'model_docs', 'bounties_stats'
        @autorun => Meteor.subscribe 'current_bounties'
    Template.bounties.events
        'click .toggle_complete': ->
            Session.set('view_complete', !Session.get('view_complete'))
        'click .new_bounty': (e,t)->
            new_bounty_id =
                Docs.insert
                    model:'bounty'
            Session.set('editing_bounty', true)
            Session.set('selected_bounty_id', new_bounty_id)
        'click .unselect_bounty': ->
            Session.set('selected_bounty_id', null)

    Template.bounties.helpers
        view_complete_class: ->
            if Session.get('view_complete') then 'blue' else ''
        selected_bounty_doc: ->
            Docs.findOne Session.get('selected_bounty_id')
        current_bounties: ->
            Docs.find
                model:'bounty'
                current:true
        bounties_stats_doc: ->
            Docs.findOne
                model:'bounties_stats'
        bounties: ->
            Docs.find
                model:'bounty'




    Template.selected_bounty.events
        'click .delete_bounty': ->
            if confirm 'delete bounty?'
                Docs.remove @_id
                Session.set('selected_bounty_id', null)
        'click .save_bounty': ->
            Session.set('editing_bounty', false)
        'click .edit_bounty': ->
            Session.set('editing_bounty', true)
        'click .goto_bounty': (e,t)->
            console.log @
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/bounty/#{@_id}/view"
            , 500

    Template.selected_bounty.helpers
        editing_bounty: -> Session.get('editing_bounty')










    Template.bounty_card_template.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.bounty_card_template.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'log_events'
    Template.bounty_card_template.events
        'click .add_bounty_item': ->
            new_mi_id = Docs.insert
                model:'bounty_item'
            Router.go "/bounty/#{_id}/edit"
    Template.bounty_card_template.helpers
        bounty_segment_class: ->
            classes=''
            if @complete
                classes += ' green'
            if Session.equals('selected_bounty_id', @_id)
                classes += ' inverted blue'
            classes
        bounty_list: ->
            # console.log @
            Docs.findOne
                model:'bounty_list'
                _id: @bounty_list_id


    Template.bounty_card_template.events
        'click .select_bounty': ->
            if Session.equals('selected_bounty_id',@_id)
                Session.set 'selected_bounty_id', null
            else
                Session.set 'selected_bounty_id', @_id
        'click .goto_bounty': (e,t)->
            console.log @
            $(e.currentTarget).closest('.grid').transition('fade right', 500)
            Meteor.setTimeout =>
                Router.go "/bounty/#{@_id}/view"
            , 500







if Meteor.isServer
    Meteor.methods
        refresh_bounty_stats: (bounty_id)->
            bounty = Docs.findOne bounty_id
            # console.log bounty
            reservations = Docs.find({model:'reservation', bounty_id:bounty_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_bounty_hours = 0
            average_bounty_duration = 0

            # shorbounty_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_bounty_hours += parseFloat(res.hour_duration)

            average_bounty_cost = total_earnings/reservation_count
            average_bounty_duration = total_bounty_hours/reservation_count

            Docs.update bounty_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_bounty_hours: total_bounty_hours.toFixed(0)
                    average_bounty_cost: average_bounty_cost.toFixed(0)
                    average_bounty_duration: average_bounty_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header bounty ranking #reservations
            # .ui.small.header bounty ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg bounty time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date
    Meteor.publish 'bounties', (
        selected_tags
        view_complete
        )->
        # user = Meteor.users.findOne @userId
        # console.log selected_tags
        # console.log filter
        self = @
        match = {}
        if view_complete
            match.complete = true
        # if Meteor.user()
        #     unless Meteor.user().roles and 'dev' in Meteor.user().roles
        #         match.view_roles = $in:Meteor.user().roles
        # else
        #     match.view_roles = $in:['public']

        # if filter is 'shop'
        #     match.active = true
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        # if filter then match.model = filter
        match.model = 'bounty'

        Docs.find match, sort:_timestamp:-1
