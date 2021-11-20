if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'posts'
        ), name:'home'


    Template.post_reservations.onCreated ->
        @autorun => @subscribe 'post_reservations',Router.current().params.doc_id, ->
    Template.post_reservations.helpers
        post_reservation_docs: ->
            Docs.find 
                model:'reservation'
                post_id:Router.current().params.doc_id




if Meteor.isClient
    Router.route '/post/:doc_id/', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'
    Router.route '/reservation/:doc_id/checkout', (->
        @layout 'layout'
        @render 'reservation_edit'
        ), name:'reservation_checkout'


    
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.helpers
        upcoming_days: ->
            upcoming_days = []
            now = new Date()
            today = moment(now).format('dddd MMM Do')
            # upcoming_days.push today
            day_number = 0
            # for day in [0..3]
            for day in [0..1]
                day_number++
                moment_ob = moment(now).add(day, 'days')
                long_form = moment(now).add(day, 'days').format('dddd MMM Do')
                upcoming_days.push {moment_ob:moment_ob,long_form:long_form}
            upcoming_days
    
    
    Template.post_edit.events
        'click .delete_post_item': ->
            if confirm 'delete post?'
                Docs.remove @_id
                Router.go "/"

    Template.post_view.helpers
        sold_out: -> @inventory < 1
    Template.post_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
    Template.post_view.events
        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'cart_item'
        #         post_id:@_id
        #     $('body').toast({
        #         title: "#{@title} added to cart."
        #         # message: 'Please see desk staff for key.'
        #         class : 'green'
        #         # position:'top center'
        #         # className:
        #         #     toast: 'ui massive message'
        #         displayTime: 5000
        #         transition:
        #           showMethod   : 'zoom',
        #           showDuration : 250,
        #           hideMethod   : 'fade',
        #           hideDuration : 250
        #         })

        # 'click .add_to_cart': ->
        #     console.log @
        #     Docs.insert
        #         model:'reservation'
        #         post_id:@_id
        #     $('body').toast({
        #         title: "#{@title} added to cart."
        #         # message: 'Please see desk staff for key.'
        #         class : 'green'
        #         # position:'top center'
        #         # className:
        #         #     toast: 'ui massive message'
        #         displayTime: 5000
        #         transition:
        #           showMethod   : 'zoom',
        #           showDuration : 250,
        #           hideMethod   : 'fade',
        #           hideDuration : 250
        #         })
        'click .new_reservation': (e,t)->
            new_reservation_id = Docs.insert
                model:'reservation'
                post_id: @_id
                post_id:post._id
                post_title:post.title
                post_image_id:post.image_id
                post_daily_rate:post.daily_rate
            Router.go "/reservation/#{new_reservation_id}/edit"
            
            

        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'

        # 'click .buy_post': (e,t)->
        #     post = Docs.findOne Router.current().params.doc_id
        #     new_reservation_id = 
        #         Docs.insert 
        #             model:'reservation'
        #             reservation_type:'post'
        #             post_id:post._id
        #             post_title:post.title
        #             post_price:post.dollar_price
        #             post_image_id:post.image_id
        #             post_point_price:post.point_price
        #             post_dollar_price:post.dollar_price
        #     Router.go "/reservation/#{new_reservation_id}/checkout"
            
if Meteor.isClient
    Template.user_posts.onCreated ->
        @autorun => Meteor.subscribe 'user_posts', Router.current().params.username
    Template.user_posts.events
        'click .add_post': ->
            new_id =
                Docs.insert
                    model:'post'
            Router.go "/post/#{new_id}/edit"

    Template.user_posts.helpers
        posts: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'post'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_posts', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'post'
            _author_id: user._id
            
    Meteor.publish 'post_reservations', (doc_id)->
        post = Docs.findOne doc_id
        Docs.find
            model:'reservation'
            post_id:post._id
            
            
            
            
if Meteor.isClient
    Template.post_stats.events
        'click .refresh_post_stats': ->
            Meteor.call 'refresh_post_stats', @_id




    Template.reservation_segment.events
        'click .calc_res_numbers': ->
            start_date = moment(@start_timestamp).date()
            start_month = moment(@start_timestamp).month()
            start_minute = moment(@start_timestamp).minute()
            start_hour = moment(@start_timestamp).hour()
            Docs.update @_id,
                $set:
                    start_date:start_date
                    start_month:start_month
                    start_hour:start_hour
                    start_minute:start_minute



if Meteor.isServer
    Meteor.publish 'post_reservations_by_id', (post_id)->
        Docs.find
            model:'reservation'
            post_id: post_id


    Meteor.publish 'reservation_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        reservations = Docs.find(model:'reservation',product_id:product_id).fetch()
        # for reservation in reservations
            # console.log 'id', reservation._id
            # console.log reservation.paid_amount
        Docs.find
            model:'reservation'
            product_id:product_id

    Meteor.publish 'reservation_slot', (moment_ob)->
        posts_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            posts.return.push date_string
        posts_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


    Meteor.methods
        refresh_post_stats: (post_id)->
            post = Docs.findOne post_id
            # console.log post
            reservations = Docs.find({model:'reservation', post_id:post_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_post_hours = 0
            average_post_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_post_hours += parseFloat(res.hour_duration)

            average_post_cost = total_earnings/reservation_count
            average_post_duration = total_post_hours/reservation_count

            Docs.update post_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_post_hours: total_post_hours.toFixed(0)
                    average_post_cost: average_post_cost.toFixed(0)
                    average_post_duration: average_post_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header post ranking #reservations
            # .ui.small.header post ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg post time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date