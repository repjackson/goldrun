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
            #     # // Optional: Additional classes to apply to the calendar
            #     addedClasses: "col-md-8",
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
        'click .add_credit': ->
            deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
            stripe_charge = parseFloat(deposit_amount)*100*1.02+20
            # stripe_charge = parseInt(deposit_amount*1.02+20)

            if confirm "add #{deposit_amount} credit?"
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
                Router.go "/reservation/#{@_id}/view"



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
            classes = ''
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
                classes += 'tertiary'
            date = day_moment_ob.date()
            if Session.equals('current_hour', hour)
                if Session.equals('current_date', date)
                    classes += ' active blue'
            classes
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
