if Meteor.isClient
    @picked_music_tags = new ReactiveArray []
    @picked_styles = new ReactiveArray []
    @picked_moods = new ReactiveArray []
    @picked_genres = new ReactiveArray []
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
    Template.music_artist.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
        Meteor.setTimeout ->
            $().popup(
                inline: true
            )
        , 2000
    
    Template.music.onCreated ->
        # @autorun => @subscribe 'model_docs','artist', ->
        @autorun => @subscribe 'music_facets',
            picked_music_tags.array()
            picked_styles.array()
            picked_moods.array()
            picked_genres.array()
            Session.get('artist_search')
            picked_timestamp_tags.array()
        @autorun => @subscribe 'music_results',
            picked_music_tags.array()
            picked_styles.array()
            picked_moods.array()
            picked_genres.array()
            Session.get('artist_search')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')

if Meteor.isServer
    Meteor.publish 'music_facets', (
        picked_music_tags=[]
        picked_styles=[]
        picked_moods=[]
        picked_genres=[]
        name_search=''
        # picked_timestamp_tags
        sort_key='_timestamp'
        sort_direction=-1
        limit=20
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
            if name_search.length > 1
                match.strArtist = {$regex:"#{name_search}", $options: 'i'}

            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_music_tags.length > 0 then match.tags = $all: picked_music_tags
            if picked_styles.length > 0 then match.strStyle = $all: picked_styles
            if picked_moods.length > 0 then match.strMood = $all: picked_moods
            if picked_genres.length > 0 then match.strGenre = $all: picked_genres

            total_count = Docs.find(match).count()
            # console.log 'total count', total_count
            # console.log 'facet match', match
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: '$tags', count: $sum: 1 }
                { $match: _id: $nin: picked_music_tags }
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
                    
                    
            style_cloud = Docs.aggregate [
                { $match: match }
                { $project: strStyle: 1 }
                { $group: _id: '$strStyle', count: $sum: 1 }
                { $match: _id: $nin: picked_styles }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme tag_cloud, ', tag_cloud
            style_cloud.forEach (tag, i) ->
                # console.log tag
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'style'
                    index: i
                    
            genre_cloud = Docs.aggregate [
                { $match: match }
                { $project: strGenre: 1 }
                { $group: _id: '$strGenre', count: $sum: 1 }
                { $match: _id: $nin: picked_genres }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme tag_cloud, ', tag_cloud
            genre_cloud.forEach (tag, i) ->
                # console.log tag
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'genre'
                    index: i
            
            mood_cloud = Docs.aggregate [
                { $match: match }
                { $project: strMood: 1 }
                { $group: _id: '$strMood', count: $sum: 1 }
                { $match: _id: $nin: picked_moods }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme tag_cloud, ', tag_cloud
            mood_cloud.forEach (tag, i) ->
                # console.log tag
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'mood'
                    index: i
            self.ready()



    Meteor.publish 'music_results', (
        picked_music_tags=[]
        picked_styles=[]
        picked_moods=[]
        picked_genres=[]
        name_search=''
        sort_key='_timestamp'
        sort_direction=-1
        limit=42
        # picked_timestamp_tags=[]
        # picked_location_tags=[]
        )->
        self = @
        match = {model:'artist'}
        if picked_music_tags.length > 0 then match.tags = $all: picked_music_tags
        if picked_styles.length > 0 then match.strStyle = $all: picked_styles
        if picked_moods.length > 0 then match.strMood = $all: picked_moods
        if picked_genres.length > 0 then match.strGenre = $all: picked_genres
        if name_search.length > 1
            match.strArtist = {$regex:"#{name_search}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        # unless Meteor.userId()
        #     match.private = $ne:true
            
        # console.log 'results match', match
        # console.log 'sort_key', sort_key
        # console.log 'sort_direction', sort_direction
        # console.log 'limit', limit
        
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            limit: limit
            fields: 
                strArtistFanart:1
                strArtistThumb:1
                strArtistLogo:1
                strArtist:1
                strGenre:1
                strStyle:1
                strMood:1
                _timestamp:1
                model:1
                tags:1
if Meteor.isClient
    Template.music.helpers
        one_result: ->
            Docs.find(model:'artist').count() is 1
        artist_docs: ->
            Docs.find {
                model:'artist'
            }, sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
        music_tag_results: ->
            Results.find {
                model:'tag'
            }, limit:20
        genre_results: ->
            Results.find {
                model:'genre'
            }, limit:20
        style_results: ->
            Results.find {
                model:'style'
            }, limit:20
        mood_results: ->
            Results.find {
                model:'mood'
            }, limit:20
        picked_music_tags: -> picked_music_tags.array()
        picked_genres: -> picked_genres.array()
        picked_styles: -> picked_styles.array()
        picked_moods: -> picked_moods.array()
        current_search: ->
            Session.get('artist_search')
    Template.music_artist.events
        'click .pick_flat_tag': ->
            picked_music_tags.clear()
            picked_music_tags.push @valueOf()
            $('body').toast(
                showIcon: 'search'
                message: "searching for #{@valueOf()}"
                showProgress: 'bottom'
                class: 'info'
                # displayTime: 'auto',
                position: "bottom right"
            )
            
            Meteor.call 'search_artist', @valueOf(), ->
                $('body').toast(
                    showIcon: 'checkmark'
                    message: "search complete for #{@valueOf()}"
                    showProgress: 'bottom'
                    class: 'info'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
            Router.go "/music"
    Template.music.events
        'click .clear': (e,t)->
            Session.set('artist_search',null)
        'keyup .artist_search': (e,t)->
            query = t.$('.artist_search').val()
            Session.set('artist_search',query)
            if e.which is 13
                Meteor.call 'search_artist', Session.get('artist_search'), ->
        'click .search_artist': ->
            Meteor.call 'search_artist', Session.get('artist_search'), ->
        'click .search_album': ->
            Meteor.call 'search_album', Session.get('artist_search'), ->

        'click .pick_tag': -> picked_music_tags.push @name
        'click .unpick_tag': -> picked_music_tags.remove @valueOf()
       
        'click .pick_mood': -> picked_moods.push @name
        'click .unpick_mood': -> picked_moods.remove @valueOf()
        
        'click .pick_genre': -> picked_genres.push @name
        'click .unpick_genre': -> picked_genres.remove @valueOf()
        
        'click .pick_style': -> picked_styles.push @name
        'click .unpick_style': -> picked_styles.remove @valueOf()
        



if Meteor.isServer 
    Meteor.methods
        search_album: (search)->
            HTTP.get "https://www.theaudiodb.com/api/v1/json/523532/searchalbum.php?s=#{search}",(err,response)=>
                console.log response
        search_artist: (search)->
            HTTP.get "https://www.theaudiodb.com/api/v1/json/523532/search.php?s=#{search}",(err,response)=>
                # console.log 'ARTIST RESPONSE'
                # console.log response.data.artists[0].strArtist
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
                        new_id = Docs.insert 
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
                        Meteor.call 'call_watson', new_id, 'strBiographyEN', ->
                            

