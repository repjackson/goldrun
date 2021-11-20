if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'posts'
        ), name:'home'


    Template.post_orders.onCreated ->
        @autorun => @subscribe 'post_orders',Router.current().params.doc_id, ->
    Template.post_orders.helpers
        post_order_docs: ->
            Docs.find 
                model:'order'
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
    Router.route '/order/:doc_id/checkout', (->
        @layout 'layout'
        @render 'order_edit'
        ), name:'order_checkout'


    
    Template.post_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.post_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
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
        #         model:'order'
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
                rental_id: @_id
            Router.go "/reservation/#{new_reservation_id}/edit"
        'click .rent_post': (e,t)->
            post = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    # order_type:'rental'
                    post_id:post._id
                    post_title:post.title
                    post_image_id:post.image_id
                    post_daily_rate:post.daily_rate
                    
            Router.go "/order/#{new_order_id}/checkout"
            
            

        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'

        # 'click .buy_post': (e,t)->
        #     post = Docs.findOne Router.current().params.doc_id
        #     new_order_id = 
        #         Docs.insert 
        #             model:'order'
        #             order_type:'post'
        #             post_id:post._id
        #             post_title:post.title
        #             post_price:post.dollar_price
        #             post_image_id:post.image_id
        #             post_point_price:post.point_price
        #             post_dollar_price:post.dollar_price
        #     Router.go "/order/#{new_order_id}/checkout"
            
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
            
    Meteor.publish 'post_orders', (doc_id)->
        post = Docs.findOne doc_id
        Docs.find
            model:'order'
            post_id:post._id
            
            
            
            
if Meteor.isClient
    Router.route '/rental/:doc_id/', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'


    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.rental_view.onRendered ->
        Meteor.call 'increment_view', Router.current().params.doc_id, ->
        Session.set 'view_mode', 'cards'

    #     'click .calculate_diff': ->
    #         product = Template.parentData()
    #         console.log product
    #         moment_a = moment @start_datetime
    #         moment_b = moment @end_datetime
    #         reservation_hours = -1*moment_a.diff(moment_b,'hours')
    #         reservation_days = -1*moment_a.diff(moment_b,'days')
    #         hourly_reservation_price = reservation_hours*product.hourly_rate
    #         daily_reservation_price = reservation_days*product.daily_rate
    #         Docs.update @_id,
    #             $set:
    #                 reservation_hours:reservation_hours
    #                 reservation_days:reservation_days
    #                 hourly_reservation_price:hourly_reservation_price
    #                 daily_reservation_price:daily_reservation_price

    Template.rental_stats.events
        'click .refresh_rental_stats': ->
            Meteor.call 'refresh_rental_stats', @_id




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
    Meteor.publish 'rental_reservations_by_id', (rental_id)->
        Docs.find
            model:'reservation'
            rental_id: rental_id

    Meteor.publish 'rentals', (product_id)->
        Docs.find
            model:'rental'
            product_id:product_id

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
        rentals_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            rentals.return.push date_string
        rentals_return

        # data.long_form
        # Docs.find
        #     model:'reservation_slot'


    Meteor.methods
        refresh_rental_stats: (rental_id)->
            rental = Docs.findOne rental_id
            # console.log rental
            reservations = Docs.find({model:'reservation', rental_id:rental_id})
            reservation_count = reservations.count()
            total_earnings = 0
            total_rental_hours = 0
            average_rental_duration = 0

            # shortest_reservation =
            # longest_reservation =

            for res in reservations.fetch()
                total_earnings += parseFloat(res.cost)
                total_rental_hours += parseFloat(res.hour_duration)

            average_rental_cost = total_earnings/reservation_count
            average_rental_duration = total_rental_hours/reservation_count

            Docs.update rental_id,
                $set:
                    reservation_count: reservation_count
                    total_earnings: total_earnings.toFixed(0)
                    total_rental_hours: total_rental_hours.toFixed(0)
                    average_rental_cost: average_rental_cost.toFixed(0)
                    average_rental_duration: average_rental_duration.toFixed(0)

            # .ui.small.header total earnings
            # .ui.small.header rental ranking #reservations
            # .ui.small.header rental ranking $ earned
            # .ui.small.header # different renters
            # .ui.small.header avg rental time
            # .ui.small.header avg daily earnings
            # .ui.small.header avg weekly earnings
            # .ui.small.header avg monthly earnings
            # .ui.small.header biggest renter
            # .ui.small.header predicted payback duration
            # .ui.small.header predicted payback date



if Meteor.isClient
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'


    Template.rental_edit.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1500


    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.rental_edit.helpers
        viewing_content: ->
            Session.equals('expand_field', @_id)

    Template.rental_edit.events
        'click .field_edit': ->
            if Session.equals('expand_field', @_id)
                Session.set('expand_field', null)
            else
                Session.set('expand_field', @_id)



# Router.route '/rental/:doc_id/', (->
#     @render 'rental_view'
#     ), name:'rental_view'
# Router.route '/rental/:doc_id/edit', (->
#     @render 'rental_edit'
#     ), name:'rental_edit'
#
#
# if Meteor.isClient
#     Template.rental_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#     Template.rental_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#
#     Template.rental_history.onCreated ->
#         @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
#     Template.rental_history.helpers
#         rental_events: ->
#             Docs.find
#                 model:'log_event'
#                 parent_id:Router.current().params.doc_id
#
#
#     Template.rental_subscription.onCreated ->
#         # @autorun => Meteor.subscribe 'children', 'log_event', Router.current().params.doc_id
#     Template.rental_subscription.events
#         'click .subscribe': ->
#             Docs.insert
#                 model:'log_event'
#                 log_type:'subscribe'
#                 parent_id:Router.current().params.doc_id
#                 text: "#{Meteor.user().username} subscribed to rental order."
#
#
#     Template.rental_reservations.onCreated ->
#         @autorun => Meteor.subscribe 'rental_reservations', Router.current().params.doc_id
#     Template.rental_reservations.helpers
#         reservations: ->
#             Docs.find
#                 model:'reservation'
#                 rental_id: Router.current().params.doc_id
#     Template.rental_reservations.events
#         'click .new_reservation': ->
#             Docs.insert
#                 model:'reservation'
#                 rental_id: Router.current().params.doc_id
#
#
# if Meteor.isServer
#     Meteor.publish 'rental_reservations', (rental_id)->
#         Docs.find
#             model:'reservation'
#             rental_id: rental_id
#
#
#
#     Meteor.methods
#         calc_rental_stats: ->
#             rental_stat_doc = Docs.findOne(model:'rental_stats')
#             unless rental_stat_doc
#                 new_id = Docs.insert
#                     model:'rental_stats'
#                 rental_stat_doc = Docs.findOne(model:'rental_stats')
#             console.log rental_stat_doc
#             total_count = Docs.find(model:'rental').count()
#             complete_count = Docs.find(model:'rental', complete:true).count()
#             incomplete_count = Docs.find(model:'rental', complete:$ne:true).count()
#             Docs.update rental_stat_doc._id,
#                 $set:
#                     total_count:total_count
#                     complete_count:complete_count
#                     incomplete_count:incomplete_count


if Meteor.isClient
    # Calendar = require('tui-calendar');
    # require("tui-calendar/dist/tui-calendar.css");
    # require('tui-date-picker/dist/tui-date-picker.css');
    # require('tui-time-picker/dist/tui-time-picker.css');

    Template.rental_calendar.onCreated ->
        @autorun -> Meteor.subscribe 'rental_reservations_by_id', Router.current().params.doc_id
    Template.rental_calendar.onRendered ->
        # @calendar = new Calendar('#calendar', {
        #     # defaultView: 'month',
        #     defaultView: 'week',
        #     taskView: true,  # e.g. true, false, or ['task', 'milestone'])
        #     scheduleView: ['time']  # e.g. true, false, or ['allday', 'time'])
        #     month:
        #         daynames: ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'],
        #         startDayOfWeek: 0,
        #         narrowWeekend: true
        #     week:
        #         daynames: ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'],
        #         startDayOfWeek: 0,
        #         narrowWeekend: true
        #     template:
        #         monthGridHeader: (model)->
        #             date = new Date(model.date);
        #             template = '<span class="tui-full-calendar-weekday-grid-date">' + date.getDate() + '</span>';
        #             template;
        # })
        # if @subscriptionsReady()
        #     reservations = Docs.find(
        #         model:'reservation'
        #     ).fetch()
        #     console.log reservations
        #     id = '1'
        #     converted_schedules = []
        #     for res in reservations
        #         converted_schedules.push {
        #             id: toString(id)
        #             calendarId: '1'
        #             title: 'title'
        #             # title: res._author_username
        #             category: 'time'
        #             # category: res._author_username
        #             dueDateClass: ''
        #             # start: '2019-10-10T02:30:00+09:00',
        #             # end: '2019-10-10T02:50:00+09:00'
        #             start: res.start_datetime
        #             end: res.end_datetime
        #         }
        #         id++
        #     converted_schedules.push {
        #         id: '1',
        #         calendarId: '1',
        #         title: 'my schedule',
        #         category: 'time',
        #         dueDateClass: '',
        #         start: '2019-10-11T02:30:00',
        #         end: '2019-10-11T05:50:00'
        #     }
        #     converted_schedules.push {
        #         id: '2',
        #         calendarId: '1',
        #         title: 'second schedule',
        #         category: 'time',
        #         dueDateClass: '',
        #         start: '2019-10-10T09:30:00+09:00',
        #         end: '2019-10-10T09:50:00+09:00'
        #     }
        #     console.log converted_schedules
        #     @calendar.createSchedules( converted_schedules )
        # $('#calendar').fullCalendar();
        # calendarEl = document.getElementById('calendar');
        #
        # calendar = new Calendar(calendarEl, {
        #     plugins: [ dayGridPlugin, timeGridPlugin, listPlugin ]
        # });
        #
        # calendar.render();

        Template.rental_calendar.helpers
            # calendarOptions: ->
            #     # // While developing, in order to hide the license warning, use the following key
            #     schedulerLicenseKey: 'CC-Attribution-NonCommercial-NoDerivatives',
            #     # // Standard fullcalendar options
            #     height: 700,
            #     hiddenDays: [ 0 ],
            #     slotDuration: '01:00:00',
            #     minTime: '08:00:00',
            #     maxTime: '19:00:00',
            #     lang: 'fr',
            #     # // Function providing events reactive computation for fullcalendar plugin
            #     events: (start, end, timezone, callback)->
            #         console.log(start.format(), end.format());
            #         # // Get events from the CalendarEvents collection
            #         # // return as an array with .fetch()
            #         events = Docs.find({
            #              "id"         : "calendar1",
            #              "startValue" : { $gte: start.valueOf() },
            #              "endValue"   : { $lte: end.valueOf() }
            #         }).fetch();
            #         # callback(events);
            #     # // Optional: id of the calendar
            #     id: "calendar1",
            #     # // Optional: Additional cl to apply to the calendar
            #     addedcl: "col-md-8",
            #     # // Optional: Additional functions to apply after each reactive events computation
            #     autoruns: [
            #         ()->
            #             console.log("user defined autorun function executed!");
            #     ]

        rental: -> Docs.findOne Router.current().params.doc_id
        current_hour: -> Session.get('current_hour')
        current_date_string: -> Session.get('current_date_string')
        current_date: -> Session.get('current_date')
        current_month: -> Session.get('current_month')
        hourly_reservation: ->
            # day_moment_ob = Template.parentData().data.moment_ob
            # # start_date = day_moment_ob.format("YYYY-MM-DD")
            # start_date = day_moment_ob.date()
            # start_month = day_moment_ob.month()
            # start_hour = parseInt(@.valueOf())
            start_date = parseInt Session.get('current_date')
            start_hour = parseInt Session.get('current_hour')
            start_month = parseInt Session.get('current_month')
            Docs.findOne {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }

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

    Template.rental_calendar.events
        # 'click .next_view': (e,t)->
        #     t.calendar.next()
        # 'click .create_schedules': (e,t)->
        #     reservations = Docs.find(
        #         model:'reservation'
        #     ).fetch()
        #     console.log reservations
        #     id = '1'
        #     converted_schedules = []
        #     for res in reservations
        #         converted_schedules.push {
        #             id: toString(id)
        #             calendarId: '1'
        #             title: 'title'
        #             # title: res._author_username
        #             category: 'time'
        #             # category: res._author_username
        #             dueDateClass: ''
        #             # start: '2019-10-10T02:30:00+09:00',
        #             # end: '2019-10-10T02:50:00+09:00'
        #             start: res.start_datetime
        #             end: res.end_datetime
        #         }
        #         id++
        #     console.log converted_schedules
        #     t.calendar.createSchedules( converted_schedules )
        #
        # 'click .prev_view': (e,t)->
        #     t.calendar.prev()
        # 'click .view_day': (e,t)->
        #     t.calendar.changeView('day', true);
        # 'click .view_week': (e,t)->
        #     t.calendar.changeView('week', true);
        # 'click .move_now': (e,t)->
        #     # if t.calendar.getViewName() isnt 'month'
        #     t.calendar.scrollToNow()
        # 'click .view_month': (e,t)->
        #     # // monthly view(default 6 weeks view)
        #     t.calendar.setOptions({month: {visibleWeeksCount: 6}}, true); # or null
        #     t.calendar.changeView('month', true);


        'click .reserve_this': ->
            rental = Docs.findOne Router.current().params.doc_id
            current_month = parseInt Session.get('current_month')
            current_date = parseInt Session.get('current_date')
            current_minute = parseInt Session.get('current_minute')
            current_date_string = Session.get('current_date_string')
            current_hour = parseInt Session.get('current_hour')
            start_datetime = "#{current_date_string}T#{current_hour}:00"
            end_datetime = "#{current_date_string}T#{current_hour+1}:00"
            start_time = "#{current_hour}:00"
            end_time = moment(@start_datetime).add(1,'hours').format("HH:mm")

            new_reservation_id = Docs.insert
                model:'reservation'
                rental_id: rental._id
                start_hour: current_hour
                start_minute: 0
                start_date_string: current_date_string
                start_date: current_date
                start_month: current_month
                start_datetime: start_datetime
                end_datetime: end_datetime
                start_time: start_time
                end_time: end_time
                hour_duration: 1
            Meteor.call 'recalc_reservation_cost', new_reservation_id

    Template.reservation_small.helpers
        is_paying: -> Session.get 'paying'
        can_buy: -> Meteor.user().credit > @total_cost
        need_credit: -> Meteor.user().credit < @total_cost
        need_approval: -> @friends_only and Meteor.userId() not in @author.friend_ids
        submit_button_class: ->
            if Session.get 'paying'
                'disabled'
            else if @start_datetime and @end_datetime
                 ''
            else 'disabled'
        member_balance_after_reservation: ->
            rental = Docs.findOne @rental_id
            if rental
                current_balance = Meteor.user().credit
                (current_balance-@total_cost+rental.security_deposit_amount).toFixed(2)
        member_balance_after_purchase: ->
            rental = Docs.findOne @rental_id
            if rental
                current_balance = Meteor.user().credit
                (current_balance-@total_cost).toFixed(2)

    Template.reservation_small.onCreated ->

    Template.reservation_small.events
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

        'change .res_start_time': (e,t)->
            val = t.$('.res_start_time').val()
            Docs.update @_id,
                $set:start_time:val
            Meteor.call 'recalc_reservation_cost', Template.parentData().doc_id

        'change .res_end_time': (e,t)->
            val = t.$('.res_end_time').val()
            Docs.update @_id,
                $set:end_time:val
            Meteor.call 'recalc_reservation_cost', Template.parentData().doc_id

        'change .hour_duration': (e,t)->
            val = parseFloat(t.$('.hour_duration').val())
            val_int = parseInt(t.$('.hour_duration').val())
            console.log val
            console.log moment(@start_datetime).add(val,'hours').format("HH:mm")
            end_time = moment(@start_datetime).add(val,'hours').format("HH:mm")
            end_datetime = moment(@start_datetime).add(val,'hours').format("YYYY-MM-DD[T]HH:00")
            end_hour = moment(@start_datetime).add(val,'hours').hour()
            console.log end_datetime
            Docs.update @_id,
                $set:
                    hour_duration:val
                    end_time:end_time
                    end_hour: end_hour
                    end_datetime:end_datetime
            Meteor.call 'recalc_reservation_cost', @_id

        'change .res_start': (e,t)->
            val = t.$('.res_start').val()
            Docs.update @_id,
                $set:start_datetime:val
            Meteor.call 'recalc_reservation_cost', @_id

        'change .res_end': (e,t)->
            val = t.$('.res_end').val()
            Docs.update @_id,
                $set:end_datetime:val
            Meteor.call 'recalc_reservation_cost', @_id

        'click .submit_reservation': ->
            Session.set 'paying', true
            # Docs.update @_id,
            #     $set:
            #         submitted:true
            #         submitted_timestamp:Date.now()
            Meteor.call 'pay_for_reservation', @_id, =>
                Session.set 'paying', false
                Router.go "/reservation/#{@_id}/"



    Template.upcoming_day.events
        'click .select_hour': ->
            day_moment_ob = Template.parentData().moment_ob

            hour = parseInt(@.valueOf())
            Session.set('current_hour', hour)

            date_string = day_moment_ob.format("YYYY-MM-DD")
            Session.set('current_date_string', date_string)

            date = day_moment_ob.date()
            Session.set('current_date', date)

            month = day_moment_ob.month()
            Session.set('current_month', month)

    Template.upcoming_day.helpers
        hours: -> [7..20]
        hour_display: ->
            # console.log @
            if @ < 11.9
                "#{@}am"
            else if @ < 12.1
                "#{@}pm"
            else
                "#{@-12}pm"


        hour_class: ->
            cl = ''
            hour = parseInt(@.valueOf())
            day_moment_ob = Template.parentData().data.moment_ob
            # date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            found_res = Docs.findOne {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }
            if found_res and found_res.submitted
                cl += 'tertiary'
            date = day_moment_ob.date()
            if Session.equals('current_hour', hour)
                if Session.equals('current_date', date)
                    cl += ' active blue'
            cl
        pending_res: ->
            hour = parseInt(@.valueOf())
            day_moment_ob = Template.parentData().data.moment_ob
            # date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            found_res = Docs.findOne {
                model:'reservation'
                submitted: $ne: true
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }

        existing_reservations: ->
            day_moment_ob = Template.parentData().data.moment_ob
            # start_date = day_moment_ob.format("YYYY-MM-DD")
            start_date = day_moment_ob.date()
            start_month = day_moment_ob.month()
            start_hour = parseInt(@.valueOf())
            Docs.find {
                model:'reservation'
                start_month: start_month
                start_hour: start_hour
                start_date: start_date
            }
            