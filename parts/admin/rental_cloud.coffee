if Meteor.isClient
    Template.rental_cloud.onCreated ->
        @autorun -> Meteor.subscribe('rental_tags', selected_rental_tags.array())
    Template.rentals.onCreated ->
        @autorun -> Meteor.subscribe('rental_docs',
            selected_rental_tags.array()
            Session.get('sort_key')
            )

    Template.rentals.helpers
        rentals: ->
            Docs.find
                model:'rental'
                product_id:Router.current().params.doc_id

        reservations: ->
            Docs.find {
                model:'reservation'
                product_id:Router.current().params.doc_id
            },sort:
                date:-1
                hour:-1

    Template.rental_cloud.helpers
        all_rental_tags: ->
            rental_count = Docs.find(model:'rental').count()
            if 0 < rental_count < 3 then Rental_tags.find { count: $lt: rental_count } else Rental_tags.find({},{limit:42})
        # cloud_tag_class: ->
        #     button_class = switch
        #         when @index <= 5 then 'large'
        #         when @index <= 12 then ''
        #         when @index <= 20 then 'small'
        #     return button_class
        selected_rental_tags: -> selected_rental_tags.array()
        # settings: -> {
        #     position: 'bottom'
        #     limit: 10
        #     rules: [
        #         {
        #             collection: Rental_tags
        #             field: 'name'
        #             matchAll: true
        #             template: Template.tag_result
        #         }
        #     ]
        # }

    Template.sort_item.events
        'click .set_sort': ->
            console.log @
            Session.set 'sort_key', @key

    Template.rental_cloud.events
        'click .select_rental_tag': -> selected_rental_tags.push @name
        'click .unselect_rental_tag': -> selected_rental_tags.remove @valueOf()
        'click #clear_tags': -> selected_rental_tags.clear()

        # 'keyup #search': (e,t)->
        #     e.preventDefault()
        #     val = $('#search').val().toLowerCase().trim()
        #     switch e.which
        #         when 13 #enter
        #             switch val
        #                 when 'clear'
        #                     selected_rental_tags.clear()
        #                     $('#search').val ''
        #                 else
        #                     unless val.length is 0
        #                         selected_rental_tags.push val.toString()
        #                         $('#search').val ''
        #         when 8
        #             if val.length is 0
        #                 selected_rental_tags.pop()
        #
        # 'autocompleteselect #search': (event, template, doc) ->
        #     selected_rental_tags.push doc.name
        #     $('#search').val ''


if Meteor.isServer
    Meteor.publish 'rental_tags', (selected_rental_tags)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}

        # selected_rental_tags.push current_herd

        if selected_rental_tags.length > 0 then match.tags = $all: selected_rental_tags
        match.model = 'rental'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_rental_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'rental_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'rental_docs', (selected_rental_tags, query)->
        # user = Meteor.users.findOne @userId
        console.log selected_rental_tags
        # console.log filter
        self = @
        match = {}
        if query
            match.title = {$regex:"#{query}", $options: 'i'}
        if selected_rental_tags.length > 0 then match.tags = $all: selected_rental_tags
        match.model = 'rental'
        Docs.find match, sort:_timestamp:-1
