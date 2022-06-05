# if Meteor.isClient
#     @picked_models = new ReactiveArray []
#     @picked_bible_tags = new ReactiveArray []
#     @picked_styles = new ReactiveArray []
#     @picked_moods = new ReactiveArray []
#     @picked_genres = new ReactiveArray []
#     Router.route '/bible/', (->
#         @layout 'layout'
#         @render 'bible'
#         ), name:'bible'
    
#     Router.route '/bible/artist/:doc_id', (->
#         @layout 'layout'
#         @render 'bible_artist'
#         ), name:'bible_artist'
#     Router.route '/bible/album/:doc_id', (->
#         @layout 'layout'
#         @render 'album_view'
#         ), name:'album_view'
    
    
#     Template.bible_artist.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
#         @autorun => Meteor.subscribe 'albums_by_artist_doc_id', Router.current().params.doc_id, ->
#     Template.album_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
#         @autorun => Meteor.subscribe 'tracks_by_album_doc_id', Router.current().params.doc_id, ->

# if Meteor.isServer 
#     Meteor.publish 'albums_by_artist_doc_id', (artist_doc_id)->
#         artist = Docs.findOne artist_doc_id
#         console.log 'artist', artist
#         Docs.find 
#             model:'album'
#             idArtist:artist.idArtist
            
#     Meteor.publish 'tracks_by_album_doc_id', (album_doc_id)->
#         album = Docs.findOne album_doc_id
#         console.log 'album', album.idAlbum
#         found = 
#             Docs.find(
#                 model:'track'
#                 strAlbum:album.strAlbum
#             )
#         console.log 'found count', found.count()
#         found
        
        
# if Meteor.isClient
#     Template.album_view.events 
#         'click .pull_tracks': -> 
#             console.log 'pulling tracks'
#             Meteor.call 'pull_album_tracks', Router.current().params.doc_id, ()->
#                 console.log 'pulled'
#     Template.bible_artist.helpers
#         album_track_docs: ->
#             Docs.find 
#                 model:'album'
#         current_artist: ->
#             Docs.findOne Router.current().params.doc_id
#     Template.album_view.helpers
#         album_track_docs: ->
#             Docs.find 
#                 model:'track'
#         current_album: ->
#             Docs.findOne Router.current().params.doc_id
#     Template.bible_artist.onRendered ->
#         Meteor.call 'log_view', Router.current().params.doc_id, ->
#         Meteor.setTimeout ->
#             $().popup(
#                 inline: true
#             )
#         , 2000
    
#     Template.bible.onCreated ->
#         # @autorun => @subscribe 'model_docs','artist', ->
#         @autorun => @subscribe 'bible_facets',
#             picked_models.array()
#             picked_bible_tags.array()
#             picked_styles.array()
#             picked_moods.array()
#             picked_genres.array()
#             Session.get('artist_search')
#             picked_timestamp_tags.array()
#         @autorun => @subscribe 'bible_results',
#             picked_models.array()
#             picked_bible_tags.array()
#             picked_styles.array()
#             picked_moods.array()
#             picked_genres.array()
#             Session.get('artist_search')
#             Session.get('sort_key')
#             Session.get('sort_direction')
#             Session.get('limit')

# if Meteor.isServer
#     Meteor.publish 'bible_facets', (
#         picked_models=[]
#         picked_bible_tags=[]
#         picked_styles=[]
#         picked_moods=[]
#         picked_genres=[]
#         name_search=''
#         # picked_timestamp_tags
#         sort_key='_timestamp'
#         sort_direction=-1
#         limit=20
#         # picked_author_ids=[]
#         # picked_location_tags
#         # picked_building_tags
#         # picked_unit_tags
#         # author_id
#         # parent_id
#         # tag_limit
#         # doc_limit
#         # sort_object
#         # view_private
#         )->
    
#             self = @
#             match = {}
    
#             # match.tags = $all: picked_tags
#             if picked_models.length > 0 
#                 match.model = $all: picked_models 
#             else 
#                 match.model = $in:['artist','album']
#             # if parent_id then match.parent_id = parent_id
    
#             # if view_private is true
#             #     match.author_id = Meteor.userId()
#             if name_search.length > 1
#                 match.strArtist = {$regex:"#{name_search}", $options: 'i'}

#             # if view_private is false
#             #     match.published = $in: [0,1]
    
#             if picked_bible_tags.length > 0 then match.tags = $all: picked_bible_tags
#             if picked_styles.length > 0 then match.strStyle = $all: picked_styles
#             if picked_moods.length > 0 then match.strMood = $all: picked_moods
#             if picked_genres.length > 0 then match.strGenre = $all: picked_genres

#             total_count = Docs.find(match).count()
#             # console.log 'total count', total_count
#             # console.log 'facet match', match
#             tag_cloud = Docs.aggregate [
#                 { $match: match }
#                 { $project: tags: 1 }
#                 { $unwind: "$tags" }
#                 { $group: _id: '$tags', count: $sum: 1 }
#                 { $match: _id: $nin: picked_bible_tags }
#                 { $sort: count: -1, _id: 1 }
#                 { $match: count: $lt: total_count }
#                 { $limit: 10 }
#                 { $project: _id: 0, name: '$_id', count: 1 }
#                 ]
#             # console.log 'theme tag_cloud, ', tag_cloud
#             tag_cloud.forEach (tag, i) ->
#                 # console.log tag
#                 self.added 'results', Random.id(),
#                     name: tag.name
#                     count: tag.count
#                     model:'tag'
#                     index: i
                    
                    
#             style_cloud = Docs.aggregate [
#                 { $match: match }
#                 { $project: strStyle: 1 }
#                 { $group: _id: '$strStyle', count: $sum: 1 }
#                 { $match: _id: $nin: picked_styles }
#                 { $sort: count: -1, _id: 1 }
#                 { $match: count: $lt: total_count }
#                 { $limit: 10 }
#                 { $project: _id: 0, name: '$_id', count: 1 }
#                 ]
#             # console.log 'theme tag_cloud, ', tag_cloud
#             style_cloud.forEach (tag, i) ->
#                 # console.log tag
#                 self.added 'results', Random.id(),
#                     name: tag.name
#                     count: tag.count
#                     model:'style'
#                     index: i
                    
                    
#             model_cloud = Docs.aggregate [
#                 { $match: match }
#                 { $project: model: 1 }
#                 { $group: _id: '$model', count: $sum: 1 }
#                 { $match: _id: $nin: picked_models }
#                 { $sort: count: -1, _id: 1 }
#                 { $match: count: $lt: total_count }
#                 { $limit: 10 }
#                 { $project: _id: 0, name: '$_id', count: 1 }
#                 ]
#             # console.log 'theme tag_cloud, ', tag_cloud
#             model_cloud.forEach (tag, i) ->
#                 # console.log tag
#                 self.added 'results', Random.id(),
#                     name: tag.name
#                     count: tag.count
#                     model:'model'
#                     index: i
                    
#             genre_cloud = Docs.aggregate [
#                 { $match: match }
#                 { $project: strGenre: 1 }
#                 { $group: _id: '$strGenre', count: $sum: 1 }
#                 { $match: _id: $nin: picked_genres }
#                 { $sort: count: -1, _id: 1 }
#                 { $match: count: $lt: total_count }
#                 { $limit: 10 }
#                 { $project: _id: 0, name: '$_id', count: 1 }
#                 ]
#             # console.log 'theme tag_cloud, ', tag_cloud
#             genre_cloud.forEach (tag, i) ->
#                 # console.log tag
#                 self.added 'results', Random.id(),
#                     name: tag.name
#                     count: tag.count
#                     model:'genre'
#                     index: i
            
#             mood_cloud = Docs.aggregate [
#                 { $match: match }
#                 { $project: strMood: 1 }
#                 { $group: _id: '$strMood', count: $sum: 1 }
#                 { $match: _id: $nin: picked_moods }
#                 { $sort: count: -1, _id: 1 }
#                 { $match: count: $lt: total_count }
#                 { $limit: 10 }
#                 { $project: _id: 0, name: '$_id', count: 1 }
#                 ]
#             # console.log 'theme tag_cloud, ', tag_cloud
#             mood_cloud.forEach (tag, i) ->
#                 # console.log tag
#                 self.added 'results', Random.id(),
#                     name: tag.name
#                     count: tag.count
#                     model:'mood'
#                     index: i
#             self.ready()



#     Meteor.publish 'bible_results', (
#         picked_models=[]
#         picked_bible_tags=[]
#         picked_styles=[]
#         picked_moods=[]
#         picked_genres=[]
#         name_search=''
#         sort_key='_timestamp'
#         sort_direction=-1
#         limit=20
#         # picked_timestamp_tags=[]
#         # picked_location_tags=[]
#         )->
#         self = @
#         match = {}
#         if picked_models.length > 0 
#             match.model = $all: picked_models 
#         else 
#             match.model = $in:['artist','album']
        
#         if picked_bible_tags.length > 0 then match.tags = $all: picked_bible_tags
#         if picked_styles.length > 0 then match.strStyle = $all: picked_styles
#         if picked_moods.length > 0 then match.strMood = $all: picked_moods
#         if picked_genres.length > 0 then match.strGenre = $all: picked_genres
#         if name_search.length > 1
#             match.strArtist = {$regex:"#{name_search}", $options: 'i'}
#         #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
#         # console.log 'sort key', sort_key
#         # console.log 'sort direction', sort_direction
#         # unless Meteor.userId()
#         #     match.private = $ne:true
            
#         # console.log 'results match', match
#         # console.log 'sort_key', sort_key
#         # console.log 'sort_direction', sort_direction
#         # console.log 'limit', limit
        
#         Docs.find match,
#             sort:"#{sort_key}":sort_direction
#             limit: limit
#             # fields: 
#             #     strArtistFanart:1
#             #     strArtistThumb:1
#             #     strArtistLogo:1
#             #     strArtist:1
#             #     strGenre:1
#             #     strStyle:1
#             #     strMood:1
#             #     _timestamp:1
#             #     model:1
#             #     tags:1
# if Meteor.isClient
#     Template.bible.helpers
#         one_result: ->
#             Docs.find(model:$in:['artist','album']).count() is 1
#         artist_docs: ->
#             Docs.find {
#                 model:'artist'
#             }, sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
#         bible_docs: ->
#             Docs.find {
#                 model:$in:['artist','album']
#             }, sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
#         bible_tag_results: ->
#             Results.find {
#                 model:'tag'
#             }, limit:20
#         model_results: ->
#             Results.find {
#                 model:'model'
#             }, limit:20
#         genre_results: ->
#             Results.find {
#                 model:'genre'
#             }, limit:20
#         style_results: ->
#             Results.find {
#                 model:'style'
#             }, limit:20
#         mood_results: ->
#             Results.find {
#                 model:'mood'
#             }, limit:20
#         picked_bible_tags: -> picked_bible_tags.array()
#         picked_genres: -> picked_genres.array()
#         picked_styles: -> picked_styles.array()
#         picked_moods: -> picked_moods.array()
#         picked_models: -> picked_models.array()
#         current_search: -> Session.get('artist_search')

#     Template.bible_artist.events
#         'click .pull_albums': ->
#             current_artist = Docs.findOne Router.current().params.doc_id
#             console.log 'pulling', current_artist.strArtist
#             Meteor.call 'pull_artist_albums', current_artist.strArtist, ->
#         'click .pick_mood': ->
#             picked_moods.clear()
#             picked_moods.push @strMood
#             Router.go '/bible'
#         'click .pick_genre': ->
#             picked_genres.clear()
#             picked_genres.push @strGenre
#             Router.go '/bible'
#         'click .pick_flat_tag': ->
#             picked_bible_tags.clear()
#             picked_bible_tags.push @valueOf()
#             $('body').toast(
#                 showIcon: 'search'
#                 message: "searching for #{@valueOf()}"
#                 showProgress: 'bottom'
#                 class: 'info'
#                 # displayTime: 'auto',
#                 position: "bottom right"
#             )
            
#             Meteor.call 'search_artist', @valueOf(), ->
#                 $('body').toast(
#                     showIcon: 'checkmark'
#                     message: "search complete for #{@valueOf()}"
#                     showProgress: 'bottom'
#                     class: 'info'
#                     # displayTime: 'auto',
#                     position: "bottom right"
#                 )
#             Router.go "/bible"
#     Template.bible.events
#         'click .clear': (e,t)->
#             Session.set('artist_search',null)
#         'keyup .artist_search': (e,t)->
#             query = t.$('.artist_search').val()
#             Session.set('artist_search',query)
#             if e.which is 13
#                 Meteor.call 'search_artist', Session.get('artist_search'), ->
#         'click .search_artist': ->
#             Meteor.call 'search_artist', Session.get('artist_search'), ->
#         'click .search_album': ->
#             Meteor.call 'search_album', Session.get('artist_search'), ->

#         'click .pick_model': -> picked_models.push @name
#         'click .unpick_model': -> picked_models.remove @valueOf()
       
#         'click .pick_tag': -> picked_bible_tags.push @name
#         'click .unpick_tag': -> picked_bible_tags.remove @valueOf()
       
#         'click .pick_mood': -> picked_moods.push @name
#         'click .unpick_mood': -> picked_moods.remove @valueOf()
        
#         'click .pick_genre': -> picked_genres.push @name
#         'click .unpick_genre': -> picked_genres.remove @valueOf()
        
#         'click .pick_style': -> picked_styles.push @name
#         'click .unpick_style': -> picked_styles.remove @valueOf()
        


