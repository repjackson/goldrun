if Meteor.isClient
    Template.login.onCreated ->
        Session.set 'username', null

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
            e.preventDefault()
            username = $('.username').val()
            password = $('.password').val()
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
                    # console.log res
                    # Router.go "/user/#{username}"
                    $(e.currentTarget).closest('.grid').transition('fly right', 500)
                    Meteor.setTimeout ->
                        Router.go "/"
                    , 500
                    $('body').toast({
                        title: "logged in"
                        # message: 'Please see desk staff for key.'
                        class : 'success'
                        # position:'top center'
                        # className:
                        #     toast: 'ui massive message'
                        # displayTime: 5000
                        transition:
                          showMethod   : 'zoom',
                          showDuration : 250,
                          hideMethod   : 'fade',
                          hideDuration : 250
                        })



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
        enter_class: ->
            if Session.get('username').length
                if Meteor.loggingIn() then 'loading disabled' else ''
            else
                'disabled'
        is_logging_in: -> Meteor.loggingIn()



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
            user = Meteor.users.findOne username:username
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
