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
    
    Template.music.onCreated ->
        @autorun => @subscribe 'model_docs','artist', ->
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
                            
                            
                            
