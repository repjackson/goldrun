if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'



    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_bookmarked_docs', Router.current().params.username


    Template.profile.helpers
        bookmarked_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                _id: $in: user.bookmark_ids
if Meteor.isServer
    Meteor.publish 'user_bookmarked_docs', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            _id: $in: user.bookmark_ids
        
if Meteor.isClient
    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username, ->

    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000

    Template.profile.events
        'click .recalc_wage_stats': (e,t)->
            Meteor.call 'recalc_wage_stats', Router.current().params.username


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.profile.helpers
        user_from_username_param: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

    Template.logout_other_clients_button.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

    Template.logout_button.events
        'click .logout': (e,t)->
            Meteor.call 'insert_log', 'logout', Meteor.userId(), ->
                
            Router.go '/login'
            $(e.currentTarget).closest('.grid').transition('slide left', 500)
            
            Meteor.logout()
            $('body').toast({
                title: "logged out"
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
            
