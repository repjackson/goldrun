if Meteor.isClient
    Router.route '/user/:username/edit', (->
        @layout 'layout'
        @render 'account'
        ), name:'account'

    Template.account.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username

    Template.account.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    Template.user_single_doc_ref_editor.onCreated ->
        @autorun => Meteor.subscribe 'type', @data.model

    Template.user_single_doc_ref_editor.events
        'click .select_choice': ->
            context = Template.currentData()
            current_user = Meteor.users.findOne Router.current().params._id
            Meteor.users.update current_user._id,
                $set: "#{context.key}": @slug

    Template.user_single_doc_ref_editor.helpers
        choices: ->
            Docs.find
                model:@model

        choice_class: ->
            context = Template.parentData()
            current_user = Meteor.users.findOne Router.current().params._id
            if current_user["#{context.key}"] and @slug is current_user["#{context.key}"] then 'grey' else ''


    Template.account.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/users"


    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            if new_username
                if confirm "Change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/user/#{new_username}")




    Template.password_edit.events
        # 'click .change_password': (e, t) ->
        #     Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
        #         if err
        #             alert err.reason
        #         else
        #             alert 'password changed'
        #             # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            console.log 'new password', new_password
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'set_password', current_user._id, new_password, (err,res)->
                if err 
                    alert err
                else if res
                    alert "password set to #{new_password}."
                    console.lgo 'res', res