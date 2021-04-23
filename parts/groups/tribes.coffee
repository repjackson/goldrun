if Meteor.isServer
    Meteor.publish 'members', (tribe_id)->
        Meteor.users.find
            _id:$in:@member_ids

    Meteor.publish 'tribe_by_slug', (tribe_slug)->
        Docs.find
            model:'tribe'
            slug:tribe_slug
    Meteor.methods
        calc_tribe_stats: (tribe_slug)->
            tribe = Docs.findOne
                model:'tribe'
                slug: tribe_slug

            member_count =
                tribe.member_ids.length

            tribe_members =
                Meteor.users.find
                    _id: $in: tribe.member_ids

            dish_count = 0
            dish_ids = []
            for member in tribe_members.fetch()
                member_dishes =
                    Docs.find(
                        model:'dish'
                        _author_id:member._id
                    ).fetch()
                for dish in member_dishes
                    console.log 'dish', dish.title
                    dish_ids.push dish._id
                    dish_count++
            # dish_count =
            #     Docs.find(
            #         model:'dish'
            #         tribe_id:tribe._id
            #     ).count()
            tribe_count =
                Docs.find(
                    model:'tribe'
                    tribe_id:tribe._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    tribe_id:tribe._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            tribe_tribes =
                Docs.find(
                    model:'tribe'
                    tribe_id:tribe._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update tribe._id,
                $set:
                    member_count:member_count
                    tribe_count:tribe_count
                    dish_count:dish_count
                    total_credit_exchanged:total_credit_exchanged
                    dish_ids:dish_ids
