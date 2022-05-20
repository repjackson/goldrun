if Meteor.isClient
    Template.account.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/users"
        'click .clear_session': (e)->
            user = Meteor.users.findOne username:Router.current().params.username
            console.log @
            console.log user.services.resume.loginTokens
            $(e.currentTarget).closest('.item').transition('fly left', 500)
            Meteor.setTimeout =>
                Meteor.users.update Meteor.userId(),
                    $pull:
                        "services.resume.loginTokens":@
            , 500
    Template.account.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
