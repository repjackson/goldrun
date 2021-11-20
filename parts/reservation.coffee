if Meteor.isClient
    Router.route '/reservation/:doc_id/', (->
        @render 'reservation_view'
        ), name:'reservation_view'
    Template.reservation_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_by_res_id', Router.current().params.doc_id


    # Template.post_view_reservations.onCreated ->
    #     @autorun -> Meteor.subscribe 'post_reservations',
    #         Template.currentData()
    #         Session.get 'res_view_mode'
    #         Session.get 'date_filter'
    # Template.post_view_reservations.helpers
    #     reservations: ->
    #         Docs.find {
    #             model:'reservation'
    #         }, sort: start_datetime:-1
    #     view_res_cards: -> Session.equals 'res_view_mode', 'cards'
    #     view_res_segments: -> Session.equals 'res_view_mode', 'segments'
    # Template.post_view_reservations.events
    #     'click .set_card_view': -> Session.set 'res_view_mode', 'cards'
    #     'click .set_segment_view': -> Session.set 'res_view_mode', 'segments'

    Template.reservation_events.onCreated ->
        @autorun => Meteor.subscribe 'log_events', Router.current().params.doc_id
    Template.reservation_events.helpers
        log_events: ->
            Docs.find
                model:'log_event'
                parent_id: Router.current().params.doc_id

    # Template.post_stats.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1000

    # Template.post_view_reservations.onRendered ->
    #     Session.setDefault 'view_mode', 'cards'


    # Template.set_date_filter.events
    #     'click .set_date_filter': -> Session.set 'date_filter', @key
    #
    # Template.set_date_filter.helpers
    #     date_filter_class: ->
    #         if Session.equals('date_filter', @key) then 'active' else ''


if Meteor.isServer
    Meteor.publish 'post_reservations', (post, view_mode, date_filter)->
        console.log view_mode
        console.log date_filter
        Docs.find
            model:'reservation'
            post_id: post._id


    Meteor.publish 'log_events', (parent_id)->
        Docs.find
            model:'log_event'
            parent_id:parent_id

    Meteor.publish 'reservations_by_product_id', (product_id)->
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'post_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        if reservation
            Docs.find
                model:'post'
                _id: reservation.post_id

    Meteor.publish 'owner_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        post =
            Docs.findOne
                model:'post'
                _id: reservation.post_id

        Docs.find
            _id: post.owner_username

    Meteor.publish 'handler_by_res_id', (res_id)->
        reservation = Docs.findOne res_id
        post =
            Docs.findOne
                model:'post'
                _id: reservation.post_id

        Docs.find
            _id: post.handler_username

    Meteor.methods
        calc_reservation_stats: ->
            reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            unless reservation_stat_doc
                new_id = Docs.insert
                    model:'reservation_stats'
                reservation_stat_doc = Docs.findOne(model:'reservation_stats')
            console.log reservation_stat_doc
            total_count = Docs.find(model:'reservation').count()
            submitted_count = Docs.find(model:'reservation', submitted:true).count()
            current_count = Docs.find(model:'reservation', current:true).count()
            unsubmitted_count = Docs.find(model:'reservation', submitted:$ne:true).count()
            Docs.update reservation_stat_doc._id,
                $set:
                    total_count:total_count
                    submitted_count:submitted_count
                    current_count:current_count



if Meteor.isClient
    Router.route '/reservation/:doc_id/edit', (->
        @render 'reservation_edit'
        ), name:'reservation_edit'

    Template.reservation_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_by_res_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'owner_by_res_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'handler_by_res_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'user_by_username', 'deb_sclar'
    # Template.reservation_edit.onRendered =>
    #     if Meteor.user()
    #         Meteor.call 'calc_user_points', Meteor.user().username, ->



    Template.reservation_edit.helpers
        post: -> Docs.findOne model:'post'
        now_button_class: -> if @now then 'active' else ''
        sel_hr_class: -> if @duration_type is 'hour' then 'active' else ''
        sel_day_class: -> if @duration_type is 'day' then 'active' else ''

        is_paying: -> Session.get 'paying'

        can_buy: ->
            Meteor.user().credit > @total_cost

        need_credit: ->
            Meteor.user().credit < @total_cost


        submit_button_class: ->
            if @start_datetime and @end_datetime then '' else 'disabled'

        member_balance_after_reservation: ->
            post = Docs.findOne @post_id
            if post
                current_balance = Meteor.user().credit
                (current_balance-@total_cost).toFixed(2)

        # diff: -> moment(@end_datetime).diff(moment(@start_datetime),'hours',true)

    Template.reservation_edit.events
        'click .add_credit': ->
            deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
            stripe_charge = parseFloat(deposit_amount)*100*1.02+20
            # stripe_charge = parseInt(deposit_amount*1.02+20)

            # if confirm "add #{deposit_amount} credit?"
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: stripe_charge

        'click .trigger_recalc': ->
            Meteor.call 'recalc_reservation_cost', Router.current().params.doc_id
            $('.handler')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })
            $('.result')
              .transition({
                animation : 'pulse'
                duration  : 500
                interval  : 200
              })


        'click .cancel_reservation': ->
            if confirm 'delete reservation?'
                Docs.remove @_id
                Router.go "/post/#{@post_id}/"


        #     post = Docs.findOne @post_id
        #     # console.log @
        #     Docs.update @_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #     Meteor.call 'pay_for_reservation', @_id, =>
        #         Router.go "/reservation/#{@_id}/"



if Meteor.isServer
    Meteor.methods
        recalc_reservation_cost: (res_id)->
            res = Docs.findOne res_id
            # console.log res
            post = Docs.findOne res.post_id
            hour_duration = moment(res.end_datetime).diff(moment(res.start_datetime),'hours',true)
            cost = parseFloat hour_duration*post.hourly_dollars
            total_cost = cost
            taxes_payout = parseFloat((cost*.05))
            owner_payout = parseFloat((cost*.5))
            handler_payout = parseFloat((cost*.45))
            if post.security_deposit_required
                total_cost += post.security_deposit_amount
            if res.res_start_dropoff_selected
                total_cost += post.res_start_dropoff_fee
                handler_payout += post.res_start_dropoff_fee
            if res.res_end_pickup_selected
                total_cost += post.res_end_pickup_fee
                handler_payout += post.res_end_pickup_fee
            # console.log diff
            Docs.update res._id,
                $set:
                    hour_duration: hour_duration.toFixed(2)
                    cost: cost.toFixed(2)
                    total_cost: total_cost.toFixed(2)
                    taxes_payout: taxes_payout.toFixed(2)
                    owner_payout: owner_payout.toFixed(2)
                    handler_payout: handler_payout.toFixed(2)

        pay_for_reservation: (res_id)->
            res = Docs.findOne res_id
            # console.log res
            post = Docs.findOne res.post_id

            Meteor.call 'send_payment', Meteor.user().username, post.owner_username, res.owner_payout, 'owner_payment', res_id
            Docs.insert
                model:'log_event'
                log_type: 'payment'

            Meteor.call 'send_payment', Meteor.user().username, post.handler_username, res.handler_payout, 'handler_payment', res_id
            Meteor.call 'send_payment', Meteor.user().username, 'dev', res.taxes_payout, 'taxes_payment', res_id

            Docs.insert
                model:'log_event'
                parent_id:res_id
                res_id: res_id
                post_id: res.post_id
                log_type:'reservation_submission'
                text:"reservation submitted by #{Meteor.user().username}"

        send_payment: (from_username, to_username, amount, reason, reservation_id)->
            console.log 'sending payment from', from_username, 'to', to_username, 'for', amount, reason, reservation_id
            res = reservation_id
            sender = Docs.findOne username:from_username
            recipient = Docs.findOne username:to_username


            console.log 'sender', sender._id
            console.log 'recipient', recipient._id
            console.log typeof amount
            #
            amount  = parseFloat amount

            Docs.update sender._id,
                $inc: credit: -amount

            Docs.update recipient._id,
                $inc: credit: amount

            Docs.insert
                model:'payment'
                sender_username: from_username
                sender_id: sender._id
                recipient_username: to_username
                recipient_id: recipient._id
                amount: amount
                reservation_id: reservation_id
                post_id: res.post_id
                reason:reason
            Docs.insert
                model:'log_event'
                log_type: 'payment'
                sender_username: from_username
                recipient_username: to_username
                amount: amount
                recipient_id: recipient._id
                text:"#{from_username} paid #{to_username} #{amount} for #{reason}."
                sender_id: sender._id
            return






if Meteor.isClient
    
    Router.route '/reservations', (->
        @layout 'layout'
        @render 'reservations'
        ), name:'reservations'
    
    Template.reservations.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'daily_rate'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true
        @autorun => @subscribe 'count', ->
        @autorun => @subscribe 'reservation_facets',
            Session.get('query')
            picked_tags.array()
            picked_location_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_reservation')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'reservation_results',
            Session.get('query')
            picked_tags.array()
            picked_location_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_reservation')
            Session.get('view_pickup')
            Session.get('view_open')

    
    # Template.reservation_card.events
    #     'click .downvote':->
    #         Docs.update Meteor.userId(),
    #             $addToSet:downvoted_ids:@_id
    #         Docs.update @_id, 
    #             $addToSet:downvoter_ids:Meteor.userId()
    #         $('body').toast({
    #             title: "#{@title} downvoted and hidden"
    #             # message: 'Please see desk staff for key.'
    #             class : 'success'
    #             # position:'top center'
    #             # className:
    #             #     toast: 'ui massive message'
    #             displayTime: 5000
    #             transition:
    #               showMethod   : 'zoom',
    #               showDuration : 250,
    #               hideMethod   : 'fade',
    #               hideDuration : 250
    #             })
                

    Template.reservations.events
        'click .request_reservation': ->
            title = prompt "different title than #{Session.get('query')}"
            new_id = 
                Docs.insert 
                    model:'request'
                    title:Session.get('query')


        # 'click .toggle_reservation': -> Session.set('view_reservation', !Session.get('view_reservation'))
        # 'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        # 'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .tag_result': -> picked_tags.push @title
        'click .unselect_tag': ->
            picked_tags.remove @valueOf()
            # console.log picked_tags.array()
            # if picked_tags.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if picked_tags.array().length > 0
                # Meteor.call 'search_reddit', picked_tags.array(), ->

        'click .clear_picked_tags': ->
            Session.set('query',null)
            picked_tags.clear()

        'keyup .query': _.throttle((e,t)->
            query = $('.query').val()
            Session.set('query', query)
            # console.log Session.get('query')
            if e.which is 13
                search = $('.query').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('.query').val('')
                    Session.set('query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_reservation_count': ->
            Meteor.call 'calc_reservation_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)

    Template.reservations.helpers
        query_requests: ->
            Docs.find
                model:'request'
                title:Session.get('query')
            
        counter: -> Counts.get('reservation_counter')
        tags: -> Results.find({model:'tag', title:$nin:picked_tags.array()})
        location_tags: -> Results.find({model:'location_tag',title:$nin:picked_location_tags.array()})
        authors: -> Results.find({model:'author'})

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_reservation: ->
            Docs.find().count() is 1
        reservation_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model: 'reservation'
                # downvoter_ids:$nin:[Meteor.userId()]
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()


if Meteor.isServer 
    Meteor.publish 'reservation_results', (
        query=''
        picked_tags=[]
        picked_location_tags=[]
        limit=20
        sort_key='_timestamp'
        sort_direction=-1
        view_delivery
        view_pickup
        view_open
        )->
        console.log picked_tags
        self = @
        match = {}
        match.model = 'reservation'
        
        match.app = 'goldrun'
        # if view_open
        #     match.open = $ne:false
        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        # if Meteor.userId()
        #     if Meteor.user().downvoted_ids
        #         match._id = $nin:Meteor.user().downvoted_ids
        if query
            match.title = {$regex:"#{query}", $options: 'i'}
        
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            # sort = 'price_per_serving'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false
    
        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array
    
        # console.log 'product match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit

if Meteor.isClient
    Template.reservation_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'post_from_reservation_id', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'model_docs', 'dish'

    Template.reservation_edit.helpers
        # all_dishes: ->
        #     Docs.find
        #         model:'dish'
        can_delete: ->
            reservation = Docs.findOne Router.current().params.doc_id
            if reservation.reservation_ids
                if reservation.reservation_ids.length > 1
                    false
                else
                    true
            else
                true
        can_complete: ->
            reservation = Docs.findOne Router.current().params.doc_id
            reservation.post_daily_rate < Meteor.user().points and reservation.reservation_date
            
            
        points_after_purchase: ->
            user_points = Meteor.user().points
            current_reservation = Docs.findOne Router.current().params.doc_id
            Meteor.user().points - current_reservation.post_daily_rate


    Template.reservation_edit.events
        'click .complete_reservation': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
                    completed_timestamp:Date.now()
                    
            $('body').toast(
                showIcon: 'checkmark'
                message: 'reservation completed'
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom center"
            )
            
            Docs.update @post_id,
                $inc: inventory:-1
            
            post = Docs.findOne @post_id
            $('body').toast(
                message: "post #{post.title} inventory updated to #{post.inventory}"
                icon: 'hashtag'
                # showProgress: 'bottom'
                class: 'info'
                # displayTime: 'auto',
                position: "bottom right"
            )
            Docs.update post._author_id,
                $inc:
                    points:@post_point_price
            $('body').toast(
                showIcon: 'chevron up'
                message: "points debited from #{@_author_username}"
                # showProgress: 'bottom'
                class: 'info'
                # displayTime: 'auto',
                position: "bottom center"
            )
            Docs.update @_author_id,
                $inc:
                    points:-@post_point_price
            $('body').toast(
                showIcon: 'chevron down'
                message: "points credited to #{post._author_username}"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom center"
            )
            Router.go "/reservation/#{@_id}"


        'click .delete_reservation': (e,t)->
            if confirm 'cancel reservation?'
                doc_id = Router.current().params.doc_id
                $(e.currentTarget).closest('.grid').transition('fly right', 500)
                Router.go "/post/#{@post_id}"

                Docs.remove doc_id




if Meteor.isClient
    Template.profile_reservation_item.onCreated ->
        @autorun => Meteor.subscribe 'post_from_reservation_id', @data._id
    Template.reservation_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'dish'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'post_from_reservation_id', Router.current().params.doc_id


    Template.reservation_view.events
        'click .cancel_reservation': ->
            if confirm 'cancel?'
                Docs.remove @_id


    Template.reservation_view.helpers
        can_reservation: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                reservation_count =
                    Docs.find(
                        model:'reservation'
                        reservation_id:@_id
                    ).count()
                if reservation_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'post_from_reservation_id', (reservation_id)->
        reservation = Docs.findOne reservation_id
        Docs.find
            _id: reservation.post_id

    # Meteor.methods
        # reservation_reservation: (reservation_id)->
        #     reservation = Docs.findOne reservation_id
        #     Docs.insert
        #         model:'reservation'
        #         reservation_id: reservation._id
        #         reservation_price: reservation.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Docs.update Meteor.userId(),
        #         $inc:credit:-reservation.price_per_serving
        #     Docs.update reservation._author_id,
        #         $inc:credit:reservation.price_per_serving
        #     Meteor.call 'calc_reservation_data', reservation_id, ->



if Meteor.isClient
    Template.user_reservations.onCreated ->
        @autorun => Meteor.subscribe 'user_reservations', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'post'
    Template.user_reservations.helpers
        reservations: ->
            current_user = Docs.findOne username:Router.current().params.username
            Docs.find {
                model:'reservation'
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_reservations', (username)->
        user = Docs.findOne username:username
        Docs.find({
            model:'reservation'
            _author_id: user._id
        }, limit:20)