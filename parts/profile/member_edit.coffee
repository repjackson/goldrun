if Meteor.isClient
    Router.route '/member/:username/edit', -> @render 'member_edit'

    Template.member_edit.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username


    Template.user_model_editor.onCreated ->
        @autorun -> Meteor.subscribe 'user_models'


    Template.member_edit.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    Template.user_model_editor.helpers
        models: ->
            Docs.find
                model:'model'
                user_model:true

        user_model_class: ->
            current_user = Meteor.users.findOne username:Router.current().params.username

            if current_user.model_ids and @_id in current_user.model_ids then 'grey' else ''



    Template.user_model_editor.events
        'click .toggle_model': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user.model_ids and @_id in current_user.model_ids
                Meteor.users.update current_user._id,
                    $pull: model_ids: @_id
            else
                Meteor.users.update current_user._id,
                    $addToSet: model_ids: @_id



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



    Template.member_edit.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                Router.go "/members"

        "change input[name='profile_image']": (e) ->
            files = e.currentTarget.files
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.dir res
                    if err
                        console.error 'error uploading', err
                    else
                        user = Meteor.users.findOne username:Router.current().params.username
                        Meteor.users.update user._id,
                            $set: "image_id": res.public_id
                    return
