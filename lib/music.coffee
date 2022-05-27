if Meteor.isClient
    Router.route '/music/', (->
        @layout 'layout'
        @render 'music'
        ), name:'music'
    
    Router.route '/music/artist/:doc_id', (->
        @layout 'layout'
        @render 'music_artist'
        ), name:'music_artist'
    Router.route '/music/album/:doc_id', (->
        @layout 'layout'
        @render 'music_album'
        ), name:'music_album'
    
    
    Template.music_artist.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id

    Template.music_artist.helpers
        current_artist: ->
            Docs.findOne Router.current().params.doc_id
    Template.music.onCreated ->
        @autorun => @subscribe 'model_docs','artist', ->
        @autorun => @subscribe 'music_facets',
            picked_tags.array()
            Session.get('current_search')
            picked_timestamp_tags.array()
        @autorun => @subscribe 'music_results',
            Session.get('model')
            picked_tags.array()
            Session.get('current_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')

    Template.music.helpers
        artist_docs: ->
            Docs.find 
                model:'artist'
    Template.music.events
        'keyup .artist_search': (e,t)->
            if e.which is 13
                query = t.$('.artist_search').val()
                Session.set('artist_search',query)
                Meteor.call 'search_artist', Session.get('artist_search'), ->
        'click .search_artist': ->
            Meteor.call 'search_artist', Session.get('artist_search'), ->
        'click .search_album': ->
            Meteor.call 'search_album', Session.get('artist_search'), ->

if Meteor.isServer 
    Meteor.methods
        search_album: (search)->
            HTTP.get "https://www.theaudiodb.com/api/v1/json/523532/searchalbum.php?s=#{search}",(err,response)=>
                console.log response
        search_artist: (search)->
            HTTP.get "https://www.theaudiodb.com/api/v1/json/523532/search.php?s=#{search}",(err,response)=>
                console.log 'ARTIST RESPONSE'
                console.log response.data.artists[0].strArtist
                artist = response.data.artists[0]
                if artist
                    found_artist = 
                        Docs.findOne 
                            model:'artist'
                            idArtist:artist.idArtist
                    if found_artist
                        console.log 'found'
                        Docs.update found_artist._id,
                            $set:strBiographyEN:artist.strBiographyEN
                    else 
                        Docs.insert 
                            model:'artist'
                            "idArtist":artist.idArtist
                            "strArtist":artist.strArtist
                            "strArtistStripped":artist.strArtistStripped
                            "strArtistAlternate":artist.strArtistAlternate
                            "strLabel":artist.strLabel
                            "idLabel":artist.idLabel
                            "intFormedYear":artist.intFormedYear
                            "intBornYear":artist.intBornYear
                            "intDiedYear":artist.intDiedYear
                            "strDisbanded":artist.strDisbanded
                            "strStyle":artist.strStyle
                            "strGenre":artist.strGenre
                            "strMood":artist.strMood
                            "strWebsite":artist.strWebsite
                            "strFacebook":artist.strFacebook
                            "strTwitter":artist.strTwitter
                            "strGender":artist.strGender
                            "intMembers":artist.intMembers
                            "strCountry":artist.strCountry
                            "strCountryCode":artist.strCountryCode
                            "strArtistThumb":artist.strArtistThumb
                            "strArtistLogo":artist.strArtistLogo
                            "strArtistCutout":artist.strArtistCutout
                            "strArtistClearart":artist.strArtistClearart
                            "strArtistWideThumb":artist.strArtistWideThumb
                            "strArtistFanart":artist.strArtistFanart
                            "strArtistFanart2":artist.strArtistFanart2
                            "strArtistFanart3":artist.strArtistFanart3
                            "strArtistFanart4":artist.strArtistFanart4
                            "strArtistBanner":artist.strArtistBanner
                            "strMusicBrainzID":artist.strMusicBrainzID
                            "strISNIcode":artist.strISNIcode
                            "strLastFMChart":artist.strLastFMChart
                            "intCharted":artist.intCharted
                            "strLocked":artist.strLocked
                            strBiographyEN:artist.strBiographyEN
                            
                            

if Meteor.isServer
    Meteor.publish 'music_facets', (
        picked_tags
        title_search=''
        picked_timestamp_tags
        # picked_author_ids=[]
        # picked_location_tags
        # picked_building_tags
        # picked_unit_tags
        # author_id
        # parent_id
        # tag_limit
        # doc_limit
        # sort_object
        # view_private
        )->
    
            self = @
            match = {}
    
            # match.tags = $all: picked_tags
            match.model = 'artist'
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
    
            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_tags.length > 0 then match.tags = $all: picked_tags
    
            total_count = Docs.find(match).count()
            # console.log 'total count', total_count
            # console.log 'facet match', match
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: '$tags', count: $sum: 1 }
                { $match: _id: $nin: picked_tags }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme tag_cloud, ', tag_cloud
            tag_cloud.forEach (tag, i) ->
                # console.log tag
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'tag'
                    index: i
            self.ready()
