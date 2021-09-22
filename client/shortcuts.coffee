globalHotkeys = new Hotkeys();

globalHotkeys.add
	combo: "d r"
	callback: ->
        model_slug =  Router.current().params.model_slug
        Session.set 'loading', true
        Meteor.call 'set_facets', model_slug, ->
            Session.set 'loading', false
globalHotkeys.add
	combo: "d c"
	callback: ->
        model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        Router.go "/model/edit/#{model._id}"
globalHotkeys.add
	combo: "r a"
	callback: ->
        if Meteor.userId() and Meteor.userId() is 'vwCi2GTJgvBJN5F6c'
            if 'admin' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'admin'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'admin'
# globalHotkeys.add
# 	combo: "r m"
# 	callback: ->
#         if Meteor.userId() and Meteor.userId() is 'vwCi2GTJgvBJN5F6c'
#             if 'manager' in Meteor.user().roles
#                 Meteor.users.update Meteor.userId(), $pull:roles:'manager'
#             else
#                 Meteor.users.update Meteor.userId(), $addToSet:roles:'manager'
globalHotkeys.add
	combo: "r d"
	callback: ->
        if Meteor.userId() and Meteor.userId() is 'vwCi2GTJgvBJN5F6c'
            if 'dev' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'dev'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'dev'

globalHotkeys.add
	combo: "g h"
	callback: -> Router.go '/'
globalHotkeys.add
	combo: "g d"
	callback: ->
        if Meteor.userId() and Meteor.userId() is 'vwCi2GTJgvBJN5F6c'
            Router.go '/dev'

globalHotkeys.add
	combo: "g k"
	callback: -> Router.go '/karma'
globalHotkeys.add
	combo: "s d"
	callback: ->
        current_model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        Router.go "/m/#{current_model.slug}/#{Router.current().params.doc_id}/"
globalHotkeys.add
	combo: "g u"
	callback: ->
        model_slug =  Router.current().params.model_slug
        Session.set 'loading', true
        Meteor.call 'set_facets', model_slug, ->
            Session.set 'loading', false
        Router.go "/m/#{model_slug}/"
globalHotkeys.add
	combo: "g p"
	callback: -> Router.go "/user/#{Meteor.user().username}"
globalHotkeys.add
	combo: "g i"
	callback: -> Router.go "/inbox"
# globalHotkeys.add
# 	combo: "g m"
# 	callback: -> Router.go "/members"


globalHotkeys.add
	combo: "a d"
	callback: ->
        model = Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug
        # console.log model
        if model.collection and model.collection is 'users'
            name = prompt 'first and last name'
            split = name.split ' '
            first_name = split[0]
            last_name = split[1]
            username = name.split(' ').join('_')
            # console.log username
            Meteor.call 'add_user', first_name, last_name, username, 'guest', (err,res)=>
                if err
                    alert err
                else
                    Meteor.users.update res,
                        $set:
                            first_name:first_name
                            last_name:last_name
                    Router.go "/m/#{model.slug}/#{res}/edit"
        else
            new_doc_id = Docs.insert
                model:model.slug
            Router.go "/m/#{model.slug}/#{new_doc_id}/edit"
