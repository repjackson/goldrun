if Meteor.isClient
    Template.login.onCreated ->
        Session.set 'username', ''

    Template.login.events
        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    console.log res
                    Session.set('enter_mode', 'login')

        'blur .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set('enter_mode', 'login')

        'click .enter': (e,t)->
            Session.set('current_username', $('.username').val())
            # e.preventDefault()
            # username = $('.username').val()
            # password = $('.password').val()
            # options = {
            #     username:username
            #     password:password
            #     }
            # # console.log options
            # Meteor.loginWithPassword username, password, (err,res)=>
            #     if err
            #         console.log err
            #         $('body').toast({
            #             message: err.reason
            #         })
            #     else
            #         # console.log res
            #         # Router.go "/user/#{username}"
            #         $(e.currentTarget).closest('.grid').transition('fly right', 500)
            #         Meteor.setTimeout ->
            #             Router.go "/"
            #         , 500
            #         $('body').toast({
            #             title: "logged in"
            #             # message: 'Please see desk staff for key.'
            #             class : 'success'
            #             # position:'top center'
            #             # className:
            #             #     toast: 'ui massive message'
            #             # displayTime: 5000
            #             transition:
            #               showMethod   : 'zoom',
            #               showDuration : 250,
            #               hideMethod   : 'fade',
            #               hideDuration : 250
            #             })



        'keyup .password, keyup .username': (e,t)->
            if e.which is 13
                e.preventDefault()
                username = $('.username').val()
                password = $('.password').val()
                if username and username.length > 0 and password and password.length > 0
                    options = {
                        username:username
                        password:password
                        }
                    # console.log options
                    Meteor.loginWithPassword username, password, (err,res)=>
                        if err
                            console.log err
                            $('body').toast({
                                message: err.reason
                            })
                        else
                            # Router.go "/user/#{username}"
                            Router.go "/"


    Template.login.helpers
        username: -> Session.get 'username'
        logging_in: -> Session.equals 'enter_mode', 'login'
        # enter_class: ->
        #     if Session.get('username').length
        #         if Meteor.loggingIn() then 'loading disabled' else ''
        #     else
        #         'disabled'
        # is_logging_in: -> Meteor.loggingIn()



if Meteor.isClient
    Template.reset_password.onCreated ->
        if Accounts._resetPasswordToken
            # var resetPassword = Router.current().params.token;
            Session.set 'resetPassword', Accounts._resetPasswordToken


    Template.reset_password.helpers
        resetPassword: ->
            resetPassword = Router.current().params.token
            resetPassword
            # return Session.get('resetPassword');


    Template.reset_password.events
        'submit #reset_password_form': (e, t) ->
            e.preventDefault()
            resetPassword = Router.current().params.token
            reset_password_form = $(e.currentTarget)
            password = reset_password_form.find('.password1').val()
            password_confirm = reset_password_form.find('.password2').val()
            #Check password is at least 6 chars long

            is_valid_password = (password, password_confirm) ->
                if password == password_confirm
                    if password.length >= 6 then true else false
                else
                    alert "passwords dont match"

            if is_valid_password(password, password_confirm)
                # if (isNotEmpty(password) && areValidPasswords(password, password_confirm)) {
                Accounts.resetPassword resetPassword, password, (err) ->
                    if err
                        console.error 'error'
                    else
                        Session.set 'resetPassword', null
                        Router.go '/'
            else
                alert 'passwords need to be at least 6 characters long'

    Template.forgot_password.onCreated ->
        @autorun -> Meteor.subscribe 'all_users'

    Template.forgot_password.events
        'click .submit_email': (e, t) ->
            e.preventDefault()
            emailVar = $('.email').val()

            trimInput = (val) -> val.replace /^\s*|\s*$/g, ''

            email_trim = trimInput(emailVar)
            email = email_trim.toLowerCase()
            Accounts.forgotPassword { email: email }, (err) ->
                if err
                    if err.message == 'user not found [403]'
                        alert 'email does not exist'
                    else
                        alert "error: #{err.message}"
                else
                    alert 'email sent'


        'click .submit_username': (e, t) ->
            e.preventDefault()
            username = $('.username').val().trim()
            console.log 'submitting username', username
            user = Docs.findOne username:username
            email = user.emails[0].address
            if not email
                alert "no email found for user.  email admin@dao.af."

            Accounts.forgotPassword { email: email }, (err) ->
                if err
                    if err.message == 'user not found [403]'
                        alert 'email does not exist'
                    else
                        alert "error: #{err.message}"
                else
                    alert 'email sent'



if Meteor.isClient
    Template.reset_password.onCreated ->
        if Accounts._resetPasswordToken
            # var resetPassword = Router.current().params.token;
            Session.set 'resetPassword', Accounts._resetPasswordToken


    Template.reset_password.helpers
        resetPassword: ->
            resetPassword = Router.current().params.token
            resetPassword
            # return Session.get('resetPassword');


    Template.reset_password.events
        'submit #reset_password_form': (e, t) ->
            e.preventDefault()
            resetPassword = Router.current().params.token
            reset_password_form = $(e.currentTarget)
            password = reset_password_form.find('.password1').val()
            password_confirm = reset_password_form.find('.password2').val()
            #Check password is at least 6 chars long

            is_valid_password = (password, password_confirm) ->
                if password == password_confirm
                    if password.length >= 6 then true else false
                else
                    alert "passwords dont match"

            if is_valid_password(password, password_confirm)
                # if (isNotEmpty(password) && areValidPasswords(password, password_confirm)) {
                Accounts.resetPassword resetPassword, password, (err) ->
                    if err
                        console.error 'error'
                    else
                        Session.set 'resetPassword', null
                        Router.go '/'
            else
                alert 'passwords need to be at least 6 characters long'

    Template.forgot_password.onCreated ->
        @autorun -> Meteor.subscribe 'users'

    Template.forgot_password.events
        'click .submit_email': (e, t) ->
            e.preventDefault()
            emailVar = $('.email').val()

            trimInput = (val) -> val.replace /^\s*|\s*$/g, ''

            email_trim = trimInput(emailVar)
            email = email_trim.toLowerCase()
            Accounts.forgotPassword { email: email }, (err) ->
                if err
                    if err.message == 'user not found [403]'
                        alert 'email does not exist'
                    else
                        alert "error: #{err.message}"
                else
                    alert 'email sent'


        'click .submit_username': (e, t) ->
            e.preventDefault()
            username = $('.username').val().trim()
            console.log 'submitting username', username
            user = Docs.findOne username:username
            email = user.emails[0].address
            if not email
                alert "no email found for user.  email admin@dao.af."

            Accounts.forgotPassword { email: email }, (err) ->
                if err
                    if err.message == 'user not found [403]'
                        alert 'email does not exist'
                    else
                        alert "error: #{err.message}"
                else
                    alert 'email sent'


if Meteor.isClient
    Router.route '/register', (->
        @layout 'layout'
        @render 'register'
        ), name:'register'



    Template.register.onCreated ->
        Session.setDefault 'email', null
        Session.setDefault 'email_status', 'invalid'
        
    Template.register.events
        'keyup .first_name': ->
            first_name = $('.first_name').val()
            Session.set 'first_name', first_name
        'keyup .last_name': ->
            last_name = $('.last_name').val()
            Session.set 'last_name', last_name
        'keyup .email_field': ->
            email = $('.email_field').val()
            Session.set 'email', email
            Meteor.call 'validate_email', email, (err,res)->
                console.log res
                if res is true
                    Session.set 'email_status', 'valid'
                else
                    Session.set 'email_status', 'invalid'

        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'

        'blur .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'
        
        'keyup .pin': ->
            pin = $('.pin').val()
            console.log pin
            Session.set 'pin', pin

        'click .register': (e,t)->
            username = $('.username').val()
            # email = $('.email_field').val()
            # password = $('.password').val()
            # if Session.equals 'enter_mode', 'register'
            # if confirm "register #{username}?"
            # Meteor.call 'validate_email', email, (err,res)->
            #     console.log res
            # options = {
            #     username:username
            #     password:password
            # }
            
            options = {
                email:email
                username:username
                password:password
                }
            Meteor.call 'create_user', options, (err,res)=>
                if err
                    alert err
                else
                    console.log res
                    unless username
                        username = "#{Session.get('first_name').toLowerCase()}_#{Session.get('last_name').toLowerCase()}"
                    console.log username
                    Docs.update res,
                        $addToSet: 
                            roles: 'explorer'
                            levels: 'explorer'
                        $set:
                            first_name: Session.get('first_name')
                            last_name: Session.get('last_name')
                            app:'stand'
                            username:username
                    Router.go "/user/#{username}"
                    # Meteor.loginWithPassword username, password, (err,res)=>
                    #     if err
                    #         alert err.reason
                    #         # if err.error is 403
                    #         #     Session.set 'message', "#{username} not found"
                    #         #     Session.set 'enter_mode', 'register'
                    #         #     Session.set 'username', "#{username}"
                    #     else
                    #         Router.go '/'
                # else
                #     Meteor.loginWithPassword username, password, (err,res)=>
                #         if err
                #             if err.error is 403
                #                 Session.set 'message', "#{username} not found"
                #                 Session.set 'enter_mode', 'register'
                #                 Session.set 'username', "#{username}"
                #         else
                #             Router.go '/'


    Template.register.helpers
        can_register: ->
            console.log Session.get('username')
            console.log Session.get('password')
            # Session.get('first_name') and Session.get('last_name') and Session.get('email_status', 'valid') and Session.get('password').length>3
            Session.get('username') and Session.get('password').length>3
            # true

            # Session.get('username')

        # email: -> Session.get 'email'
        username: -> Session.get 'username'
        # first_name: -> Session.get 'first_name'
        # last_name: -> Session.get 'last_name'
        registering: -> Session.equals 'enter_mode', 'register'
        # enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
        # email_valid: ->
        #     Session.equals 'email_status', 'valid'
        # email_invalid: ->
        #     Session.equals 'email_status', 'invalid'

if Meteor.isServer
    Meteor.methods
        set_user_password: (user, password)->
            result = Accounts.setPassword(user._id, password)
            console.log result
            result

        # verify_email: (email)->
        #     (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email))


        create_user: (options)->
            console.log 'creating user', options
            Accounts.createUser options

        can_submit: ->
            username = Session.get 'username'
            email = Session.get 'email'
            password = Session.get 'password'
            password2 = Session.get 'password2'
            if username and email
                if password.length > 0 and password is password2
                    true
                else
                    false


        find_username: (username)->
            res = Accounts.findUserByUsername(username)
            if res
                # console.log res
                unless res.disabled
                    return res

        new_demo_user: ->
            current_user_count = Docs.find().count()

            options = {
                username:"user#{current_user_count}"
                password:"user#{current_user_count}"
                }

            create = Accounts.createUser options
            new_user = Docs.findOne create
            return new_user
