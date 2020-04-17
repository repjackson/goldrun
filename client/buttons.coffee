Template.session_edit_button.events
    'click .edit_this': -> Session.set 'editing_id', @_id
    'click .save_doc': -> Session.set 'editing_id', null

Template.session_edit_button.helpers
    button_classes: -> Template.currentData().classes


Template.session_edit_icon.events
    'click .edit_this': -> Session.set 'editing_id', @_id
    'click .save_doc': -> Session.set 'editing_id', null

Template.session_edit_icon.helpers
    button_classes: -> Template.currentData().classes


Template.detect.events
    'click .detect_fields': ->
        # console.log @
        Meteor.call 'detect_fields', @_id
