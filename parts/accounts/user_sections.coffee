if Meteor.isClient
    # Template.member_profile_layout.onCreated ->
    #     @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'thought'
    # Router.route '/member/:username', (->
    #     @layout 'member_profile_layout'
    #     @render 'user_dashboard'
    #     ), name:'member_profile_layout'
    Router.route '/member/:username/about', (->
        @layout 'member_profile_layout'
        @render 'user_about'
        ), name:'user_about'
    # Router.route '/member/:username/finance', (->
    #     @layout 'member_profile_layout'
    #     @render 'user_finance'
    #     ), name:'user_finance'
    Router.route '/member/:username/tutoring', (->
        @layout 'member_profile_layout'
        @render 'user_tutoring'
        ), name:'user_tutoring'
    Router.route '/member/:username/groups', (->
        @layout 'member_profile_layout'
        @render 'user_groups'
        ), name:'user_groups'
    Router.route '/member/:username/shop', (->
        @layout 'member_profile_layout'
        @render 'user_shop'
        ), name:'user_shop'
    Router.route '/member/:username/right', (->
        @layout 'member_profile_layout'
        @render 'user_right'
        ), name:'user_right'
    Router.route '/member/:username/credit', (->
        @layout 'member_profile_layout'
        @render 'user_credit'
        ), name:'user_credit'
    Router.route '/member/:username/wrong', (->
        @layout 'member_profile_layout'
        @render 'user_wrong'
        ), name:'user_wrong'
    Router.route '/member/:username/karma', (->
        @layout 'member_profile_layout'
        @render 'user_karma'
        ), name:'user_karma'
    Router.route '/member/:username/cart', (->
        @layout 'member_profile_layout'
        @render 'user_cart'
        ), name:'user_cart'
    Router.route '/member/:username/payment', (->
        @layout 'member_profile_layout'
        @render 'user_payment'
        ), name:'user_payment'
    Router.route '/member/:username/fiq', (->
        @layout 'member_profile_layout'
        @render 'user_fiq'
        ), name:'user_fiq'
    # Router.route '/member/:username/contact', (->
    #     @layout 'member_profile_layout'
    #     @render 'user_contact'
    #     ), name:'user_contact'
    Router.route '/member/:username/brain', (->
        @layout 'member_profile_layout'
        @render 'user_brain'
        ), name:'user_brain'
    Router.route '/member/:username/stats', (->
        @layout 'member_profile_layout'
        @render 'user_stats'
        ), name:'user_stats'
    Router.route '/member/:username/votes', (->
        @layout 'member_profile_layout'
        @render 'user_votes'
        ), name:'user_votes'
    # Router.route '/member/:username/dashboard', (->
    #     @layout 'member_profile_layout'
    #     @render 'user_dashboard'
    #     ), name:'user_dashboard'
    Router.route '/member/:username/jobs', (->
        @layout 'member_profile_layout'
        @render 'user_jobs'
        ), name:'user_jobs'
    Router.route '/member/:username/requests', (->
        @layout 'member_profile_layout'
        @render 'user_requests'
        ), name:'user_requests'
    Router.route '/member/:username/feed', (->
        @layout 'member_profile_layout'
        @render 'user_feed'
        ), name:'user_feed'
    Router.route '/member/:username/tags', (->
        @layout 'member_profile_layout'
        @render 'user_tags'
        ), name:'user_tags'
    Router.route '/member/:username/tasks', (->
        @layout 'member_profile_layout'
        @render 'user_tasks'
        ), name:'user_tasks'
    Router.route '/member/:username/transactions', (->
        @layout 'member_profile_layout'
        @render 'user_transactions'
        ), name:'user_transactions'
    Router.route '/member/:username/messages', (->
        @layout 'member_profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    Router.route '/member/:username/bookmarks', (->
        @layout 'member_profile_layout'
        @render 'user_bookmarks'
        ), name:'user_bookmarks'
    Router.route '/member/:username/documents', (->
        @layout 'member_profile_layout'
        @render 'user_documents'
        ), name:'user_documents'
    Router.route '/member/:username/social', (->
        @layout 'member_profile_layout'
        @render 'user_social'
        ), name:'user_social'
    Router.route '/member/:username/friends', (->
        @layout 'member_profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/member/:username/tests', (->
        @layout 'member_profile_layout'
        @render 'user_tests'
        ), name:'user_tests'
    Router.route '/member/:username/passages', (->
        @layout 'member_profile_layout'
        @render 'user_passages'
        ), name:'user_passages'
    Router.route '/member/:username/questions', (->
        @layout 'member_profile_layout'
        @render 'user_questions'
        ), name:'user_questions'
    Router.route '/member/:username/awards', (->
        @layout 'member_profile_layout'
        @render 'user_awards'
        ), name:'user_awards'
    Router.route '/member/:username/events', (->
        @layout 'member_profile_layout'
        @render 'user_events'
        ), name:'user_events'



    Template.user_brain.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'thought'
    Template.user_brain.events
        'click .add_thought': ->
            new_thought_id = Docs.insert
                model:'thought'
            Session.set 'editing_id', new_thought_id
    Template.user_brain.helpers
        thoughts: ->
            Docs.find
                model:'thought'



    Template.user_fiq.events
        'click .recalc_fiq': ->
            Meteor.call 'recalc_fiq', Router.current().params.user_id
    Template.user_fiq.helpers
        thoughts: ->
            Docs.find
                model:'thought'





    Template.user_tutoring.onCreated ->
        @autorun => Meteor.subscribe 'user_students', Router.current().params.user_id
        @autorun => Meteor.subscribe 'model_docs', 'tutalege_request'
    Template.user_tutoring.events
        'click .request_tutelage': ->
            Meteor.call 'request_tutelage', Router.current().params.user_id
        'click .accept_request': ->
            Meteor.call 'accept_request', @
        'click .reject_request': ->
            Meteor.call 'reject_request', @
    Template.user_tutoring.helpers
        tutelage_requested: ->
            Docs.findOne
                model:'tutalege_request'
                _author_id:Meteor.userId()
        tutalege_requests: ->
            Docs.find
                model:'tutalege_request'





    Template.user_shop.onCreated ->
        @autorun => Meteor.subscribe 'user_shop', Router.current().params.user_id
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.user_shop.events
        'click .add_product': ->
            new_product_id =
                Docs.insert
                    model:'product'
            Router.go "/m/product/#{new_product_id}/edit"
            # Meteor.call 'request_tutelage', Router.current().params.user_id
    Template.user_shop.helpers
        tutelage_requested: ->
            Docs.findOne
                model:'tutalege_request'
                _author_id:Meteor.userId()
        products: ->
            Docs.find
                model:'product'



    Template.user_wrong.onCreated ->
        @autorun => Meteor.subscribe 'user_wrong_questions', Router.current().params.user_id
    Template.user_wrong.events
        'click .recalc_similar': -> Meteor.call 'recalc_similar_wrong', Router.current().params.user_id
        'click .recalc_wrong_ids': -> Meteor.call 'calc_wrong_question_ids', Router.current().params.user_id
    Template.user_wrong.helpers
        wrong_questions: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                _id: $in: user.all_wrong_ids





    Template.user_right.onCreated ->
        @autorun => Meteor.subscribe 'user_right_questions', Router.current().params.user_id
    Template.user_right.events
        'click .recalc_similar': -> Meteor.call 'recalc_similar_right', Router.current().params.user_id
        'click .recalc_right_ids': -> Meteor.call 'calc_right_question_ids', Router.current().params.user_id
        'click .recalc_opposite_right': -> Meteor.call 'recalc_opposite_right', Router.current().params.user_id
    Template.user_right.helpers
        sorted_right_unions: ->
            sorted = _.sortBy(@right_unions, 'union_count').reverse()
        right_questions: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                _id: $in: user.all_right_ids





    Template.user_tests.onCreated ->
        @autorun => Meteor.subscribe 'user_tests_questions', Router.current().params.user_id
    Template.user_tests.events
        'click .recalc_test_stats': -> Meteor.call 'calc_user_test_stats', Router.current().params.user_id
    Template.user_tests.helpers
        # sorted_right_unions: ->
        #     sorted = _.sortBy(@right_unions, 'union_count').reverse()
        tests: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'test'
                _author_id:user._id
                # _id: $in: user.all_right_ids




    Template.user_requests.onCreated ->
        @autorun => Meteor.subscribe 'user_requests_questions', Router.current().params.user_id
    Template.user_requests.events
        'click .recalc_test_stats': -> Meteor.call 'calc_user_test_stats', Router.current().params.user_id
        'click .new_request': ->
            new_rid = Docs.insert
                model:'request'
                target_user_id:Router.current().params.user_id
            Router.go "/request/#{new_rid}/edit"



    Template.user_requests.helpers
        # sorted_right_unions: ->
        #     sorted = _.sortBy(@right_unions, 'union_count').reverse()
        requests: ->
            user = Meteor.users.findOne Router.current().params.user_id
            Docs.find
                model:'request'
                _author_id:user._id
                # _id: $in: user.all_right_ids





    Template.user_credit.onCreated ->
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
        #     locale: 'auto'
        #     # zipCode: true
        #     token: (token) ->
        #         # product = Docs.findOne Router.current().params.doc_id
        #         user = Meteor.users.findOne username:Router.current().params.username
        #         deposit_amount = parseInt $('.deposit_amount').val()*100
        #         stripe_charge = deposit_amount*100*1.02+20
        #         # calculated_amount = deposit_amount*100
        #         # console.log calculated_amount
        #         charge =
        #             amount: deposit_amount*1.02+20
        #             currency: 'usd'
        #             source: token.id
        #             description: token.description
        #             # receipt_email: token.email
        #         Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
        #             if error then alert error.reason, 'danger'
        #             else
        #                 alert 'payment received', 'success'
        #                 Docs.insert
        #                     model:'deposit'
        #                     deposit_amount:deposit_amount/100
        #                     stripe_charge:stripe_charge
        #                     amount_with_bonus:deposit_amount*1.05/100
        #                     bonus:deposit_amount*.05/100
        #                 Meteor.users.update user._id,
        #                     $inc: credit: deposit_amount*1.05/100
    	# )


    Template.user_credit.events
        'click .add_credits': ->
            amount = parseInt $('.deposit_amount').val()
            amount_times_100 = parseInt amount*100
            calculated_amount = amount_times_100*1.02+20
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount
            Docs.insert
                model:'deposit'
                amount: amount
            Meteor.users.update Meteor.userId(),
                $inc: credit: amount_times_100


        'click .initial_withdrawal': ->
            withdrawal_amount = parseInt $('.withdrawal_amount').val()
            if confirm "initiate withdrawal for #{withdrawal_amount}?"
                Docs.insert
                    model:'withdrawal'
                    amount: withdrawal_amount
                    status: 'started'
                    complete: false
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -withdrawal_amount

        'click .cancel_withdrawal': ->
            if confirm "cancel withdrawal for #{@amount}?"
                Docs.remove @_id
                Meteor.users.update Meteor.userId(),
                    $inc: credit: @amount



    Template.user_credit.helpers
        owner_earnings: ->
            Docs.find
                model:'reservation'
                owner_username:Router.current().params.username
                complete:true
        payments: ->
            Docs.find {
                model:'payment'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        deposits: ->
            Docs.find {
                model:'deposit'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        withdrawals: ->
            Docs.find {
                model:'withdrawal'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1
        received_reservations: ->
            Docs.find {
                model:'reservation'
                owner_username: Router.current().params.username
            }, sort:_timestamp:-1
        purchased_reservations: ->
            Docs.find {
                model:'reservation'
                _author_id: Router.current().params.user_id
            }, sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_authored_tests', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            model:'test'
            _author_id: user_id

    Meteor.publish 'user_wrong_questions', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            _id: $in: user.all_wrong_ids


    Meteor.publish 'user_right_questions', (user_id)->
        user = Meteor.users.findOne user_id
        Docs.find
            _id: $in: user.all_right_ids






    Meteor.methods
        accept_request: (request)->
            console.log request
            Docs.update request._id,
                $set:
                    approved:true
                    approved_timestamp:Date.now()
            Docs.insert
                model:'alert'
                target_user_id:request._author_id
                content:"Your tutalege request with has been accepted."

        request_tutelage: (target_user_id)->
            tutor = Meteor.users.findOne target_user_id
            Docs.insert
                model:'tutalege_request'
                tutor_id: target_user_id
                tutor_username:tutor.username
                approved:false
                rejected:false
            Docs.insert
                model:'alert'
                target_user_id:target_user_id
                content:"#{Meteor.user().username} requested your tutalege."
                read:false

        calc_user_test_stats: (user_id)->
            user = Meteor.users.findOne user_id
            test_cursor =
                Docs.find
                    model:'test'
                    _author_id: user_id
            total_points = 0
            total_upvotes = 0
            total_downvotes = 0
            for test in test_cursor.fetch()
                if test.points
                    total_points += test.points
                if test.upvotes
                    total_upvotes += test.upvotes
                if test.downvotes
                    total_downvotes += test.downvotes

            Meteor.users.update user_id,
                $set:
                    total_test_points: total_points
                    total_test_upvotes: total_upvotes
                    total_test_downvotes: total_downvotes

        recalc_similar_right: (user_id)->
            user = Meteor.users.findOne user_id
            console.log user.right_tag_cloud

            right_tag_list = Meteor.users.findOne(user_id).right_tag_list
            console.log right_tag_list
            users = Meteor.users.find({}).fetch()
            right_unions = []
            for user in users
                console.log 'right tag list', right_tag_list
                union = _.intersection user.right_tag_list, right_tag_list
                console.log union
                Meteor.users.update user_id,
                    $addToSet:
                        right_unions:
                            user_id: user._id
                            username: user.username
                            union_count: union.length
                            union:union

        recalc_opposite_right: (user_id)->
            user = Meteor.users.findOne user_id
            console.log user.right_tag_cloud

            right_tag_list = Meteor.users.findOne(user_id).right_tag_list
            console.log right_tag_list
            users = Meteor.users.find({}).fetch()
            right_unions = []
            Meteor.users.update user_id,
                $set:
                    right_opposite_unions: []

            for user in users
                console.log 'right tag list', right_tag_list
                union = _.intersection user.wrong_tag_list, right_tag_list
                console.log union
                Meteor.users.update user_id,
                    $addToSet:
                        right_opposite_unions:
                            user_id: user._id
                            username: user.username
                            union_count: union.length
                            union: union




        recalc_similar_wrong: (user_id)->
            user = Meteor.users.findOne user_id
        calc_wrong_question_ids: (user_id)->
            user = Meteor.users.findOne user_id
            test_sessions =
                Docs.find
                    model:'test_session'
                    _author_id: user_id
            all_wrong_ids = []
            for test_session in test_sessions.fetch()
                wrong_answers = _.where(test_session.answers, {first_choice_correct:false})
                # console.log wrong_answers
                question_wrong_ids = _.pluck(wrong_answers, 'question_id')
                # console.log question_wrong_ids
                # all_wrong_ids.concat question_wrong_ids
                Meteor.users.update user_id,
                    $addToSet:
                        all_wrong_ids: $each: question_wrong_ids


        calc_right_question_ids: (user_id)->
            user = Meteor.users.findOne user_id
            test_sessions =
                Docs.find
                    model:'test_session'
                    _author_id: user_id
            # all_right_ids = []
            for test_session in test_sessions.fetch()
                right_answers = _.where(test_session.answers, {first_choice_correct:true})
                # console.log 'right answers', right_answers
                question_right_ids = _.pluck(right_answers, 'question_id')
                # console.log 'question right ids', question_right_ids
                # all_right_ids.concat question_right_ids
                Meteor.users.update user_id,
                    $addToSet:
                        all_right_ids: $each: question_right_ids




        recalc_fiq: (user_id)->
            console.log user_id
            answer_count =
                Docs.find(
                    model:'answer_session'
                    _author_id: user_id
                ).count()
            fiq = answer_count
            Meteor.users.update user_id,
                $set:
                    answer_count: answer_count
                    fiq: fiq
