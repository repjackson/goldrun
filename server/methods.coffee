Meteor.methods
    call_wiki: (query)->
        console.log 'calling wiki', query
        # term = query.split(' ').join('_')
        # term = query[0]
        term = query
        HTTP.get "https://en.wikipedia.org/wiki/#{term}",(err,response)=>
            # console.log response.data
            if err
                console.log 'error finding wiki article for ', query
                # console.log err
            else

                # console.log response
                # console.log 'response'

                found_doc =
                    Docs.findOne
                        url: "https://en.wikipedia.org/wiki/#{term}"
                if found_doc
                    console.log 'found wiki doc for term', term
                    # console.log 'found wiki doc for term', term, found_doc
                    Docs.update found_doc._id,
                        $addToSet:
                            tags:'wikipedia'
                    console.log 'found wiki doc', found_doc
                    Meteor.call 'call_watson', found_doc._id, 'url','url', ->
                else
                    new_wiki_id = Docs.insert
                        title: query
                        tags:[query, 'wikipedia']
                        source: 'wikipedia'
                        model:'wikipedia'
                        # ups: 1000000
                        url:"https://en.wikipedia.org/wiki/#{term}"
                    console.log 'new wiki doc', query
                    Meteor.call 'call_watson', new_wiki_id, 'url','url', ->
