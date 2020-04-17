if Meteor.isClient
    Template.view.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'schema', Router.current().params.doc_id


    Template.detect.events
        'click .detect_fields': ->
            # console.log @
            Meteor.call 'detect_fields', @_id

    Template.view.events
        'click .calc_similar': ->
            console.log @
            Meteor.call 'calc_similar', @_id

    Template.key_view.helpers
        key: -> @valueOf()

        meta: ->
            key_string = @valueOf()
            parent = Template.parentData()
            parent["_#{key_string}"]

        context: ->
            # console.log @
            {key:@valueOf()}


        field_view: ->
            console.log @
            console.log Template.parentData(1)
            console.log Template.parentData(2)
            console.log Template.parentData(3)
            console.log Template.parentData(4)
            console.log Template.parentData(5)

            key_string = @valueOf()
            meta = Template.parentData(2)["_#{@key}"]
            "#{meta.field}_view"



if Meteor.isServer
    Meteor.methods
        calc_similar: (doc_id)->
            doc = Docs.findOne doc_id
            # console.log doc
            total = Docs.find()
            # console.log total
            matching_docs = []
            for target in total.fetch()
                tag_match_points = 0
                key_match_points = 0
                if target._keys
                    key_matches = _.intersection(doc._keys, target._keys)
                    if key_matches
                        key_matches_count = key_matches.length
                        for matching_key in key_matches
                            doc_key_value = doc["#{matching_key}"]
                            target_key_value = target["#{matching_key}"]
                            if doc_key_value is target_key_value
                                # console.log 'matching key', matching_key
                                # console.log 'matching pair', doc_key_value
                                key_match_points += 1
                        # console.log 'key match count', key_matches_count
                if target.tags
                    if doc.tags
                        tag_matches = _.intersection(doc._tags, target._tags)
                        # console.log 'tag match count', tag_matches.length
                        # console.log 'tag matches', tag_matches
                        if tag_matches.length
                            tag_match_points += tag_matches.length
                # console.log 'matching key points', key_match_points
                # console.log 'matching tag points', tag_match_points
                combined_match_points = key_match_points + tag_match_points
                # console.log 'combined match points', combined_match_points
                if combined_match_points
                    matching_object =
                        {
                            doc_id: target._id
                            matching_points: combined_match_points
                        }
                    matching_docs.push matching_object
            # console.log matching_docs
            sorted_matching_docs = _.sortBy(matching_docs, 'matching_points')
            spliced_sorted_list = sorted_matching_docs.reverse()[0..5]
            Docs.update doc_id,
                $set:
                    matching_docs:spliced_sorted_list
