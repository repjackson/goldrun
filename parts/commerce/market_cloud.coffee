if Meteor.isClient
    Template.market_cloud.onCreated ->
        @autorun -> Meteor.subscribe('market_tags', selected_market_tags.array())

    Template.market_cloud.helpers
        all_market_tags: ->
            market_count = Docs.find(model:'market').count()
            if 0 < market_count < 3 then Market_tags.find { count: $lt: market_count } else Market_tags.find({},{limit:42})
        # cloud_tag_class: ->
        #     button_class = switch
        #         when @index <= 5 then 'large'
        #         when @index <= 12 then ''
        #         when @index <= 20 then 'small'
        #     return button_class
        selected_market_tags: -> selected_market_tags.array()
        # settings: -> {
        #     position: 'bottom'
        #     limit: 10
        #     rules: [
        #         {
        #             collection: Market_tags
        #             field: 'name'
        #             matchAll: true
        #             template: Template.tag_result
        #         }
        #     ]
        # }


    Template.market_cloud.events
        'click .select_market_tag': -> selected_market_tags.push @name
        'click .unselect_market_tag': -> selected_market_tags.remove @valueOf()
        'click #clear_tags': -> selected_market_tags.clear()

        # 'keyup #search': (e,t)->
        #     e.preventDefault()
        #     val = $('#search').val().toLowerCase().trim()
        #     switch e.which
        #         when 13 #enter
        #             switch val
        #                 when 'clear'
        #                     selected_market_tags.clear()
        #                     $('#search').val ''
        #                 else
        #                     unless val.length is 0
        #                         selected_market_tags.push val.toString()
        #                         $('#search').val ''
        #         when 8
        #             if val.length is 0
        #                 selected_market_tags.pop()
        #
        # 'autocompleteselect #search': (event, template, doc) ->
        #     selected_market_tags.push doc.name
        #     $('#search').val ''


if Meteor.isServer
    Meteor.publish 'market_tags', (selected_market_tags)->
        # user = Meteor.users.finPdOne @userId
        # current_herd = user.profile.current_herd

        self = @
        match = {}

        # selected_market_tags.push current_herd

        if selected_market_tags.length > 0 then match.tags = $all: selected_market_tags
        match.model = 'rental'
        cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: selected_market_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 42 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]

        cloud.forEach (tag, i) ->
            self.added 'market_tags', Random.id(),
                name: tag.name
                count: tag.count
                index: i

        self.ready()


    Meteor.publish 'market_docs', (selected_market_tags)->
        # user = Meteor.users.findOne @userId
        console.log selected_market_tags
        # console.log filter
        self = @
        match = {}
        # if filter is 'shop'
        #     match.active = true
        if selected_market_tags.length > 0 then match.tags = $all: selected_market_tags
        match.model = 'rental'
        Docs.find match, sort:_timestamp:-1
