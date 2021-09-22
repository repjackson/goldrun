if Meteor.isClient
    Router.route '/chat', (->
        @layout 'layout'
        @render 'chat'
        ), name:'chat'
