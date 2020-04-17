Template.view_profile.events
    'click .view_profile': ->
        console.log @


Template.view_model.events
    'click .view_model': ->
        Session.set 'loading', true
        Meteor.call 'set_facets', @slug, ->
            Session.set 'loading', false
