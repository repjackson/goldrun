# # @selected_tags = new ReactiveArray []



Template.localmap.helpers
    pos:-> 
        # console.log Geolocation.currentLocation()
        Geolocation.currentLocation()
    # lat: ()-> Geolocation.latLng().lat
    # lon: ()-> Geolocation.latLng().lon

Template.mapgl.events
    'click .locate': ->
        navigator.geolocation.getCurrentPosition (position) =>
            console.log 'navigator position', position
            Session.set('current_lat', position.coords.latitude)
            Session.set('current_long', position.coords.longitude)
            
            console.log 'saving long', position.coords.longitude
            console.log 'saving lat', position.coords.latitude
        
            pos = Geolocation.currentLocation()
            # user_position_marker = 
            #     Markers.findOne
            #         _author_id: Meteor.userId()
            #         model:'user_marker'
            # unless user_position_marker
            #     Markers.insert 
            #         model:'user_marker'
            #         _author_id: Meteor.userId()
            #         latlng:
            #             lat:position.coords.latitude
            #             long:position.coords.longitude
            # if user_position_marker
            #     Markers.update user_position_marker._id,
            #         $set:
            #             latlng:
            #                 lat:position.coords.latitude
    #                         long:position.coords.longitude
    #         Meteor.users.update Meteor.userId(),
    #             $set:
    #                 location:
    #                     "type": "Point"
    #                     "coordinates": [
    #                         position.coords.longitude
    #                         position.coords.latitude
    #                     ]
    #                 current_lat: position.coords.latitude
    #                 current_long: position.coords.longitude
    #             # , (err,res)->
    #             #     console.log res

        
        
    #     $('.main_content')
    #         .transition('fade out', 250)
    #         .transition('fade in', 250)

Template.localmap.onCreated ->
    # @autorun => @subscribe 'some_posts', ->
    
Template.localmap.onRendered ->
    # console.log 'hi'
    # console.log @
    L.mapbox.accessToken = 'pk.eyJ1IjoiZ29sZHJ1biIsImEiOiJja3c2cTlwd3BmNmhqMnZwZzh3ZW5vdHRjIn0.bSaNtJ5tjrEQ_UitX5FbNQ';
    @localmap = L.mapbox.map 'localmap'

    # @geocoder = L.mapbox.geocoder 'mapbox.places'
    # @map = L.mapbox.map('map')
    #     .setView([40, -74.50], 9)
    #     .addLayer(L.mapbox.styleLayer('mapbox://styles/mapbox/streets-v11'));
    # @map.on('click', (e)->
    #     # 	alert(e.latlng);
    #     $('body').toast(
    #         showIcon: 'marker'
    #         message: "lat long: #{e.latlng}"
    #         # showProgress: 'bottom'
    #         class: 'success'
    #         displayTime: 'auto',
    #         position: "bottom right"
    #     )
    	
    	
    # )
            
Template.localmap.helpers
    current_zoom_level: -> Session.get 'zoom_level'
    post_docs: ->
        Docs.find 
            model:'post'
            app:'goldrun'
   
Template.localmap.events
    'click .refresh': (e,t)->
        console.log Geolocation.currentLocation();
        navigator.geolocation.getCurrentPosition (position) =>
            console.log position
        pos = Geolocation.currentLocation()
        # pos.coords.latitude
        console.log pos
        if pos
            Session.set('current_lat', pos.coords.latitude)
            Session.set('current_long', pos.coords.longitude)
            console.log Session.get('current_lat')
            console.log t.localmap
            t.localmap.setView([Session.get('current_lat'), Session.get('current_long')], 17);
            t.localmap.addLayer L.mapbox.styleLayer 'mapbox://styles/mapbox/streets-v11'

            # L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
            #     attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
            #     maxZoom: 18,
            #     id: 'mapbox/outdoors-v11',
            #     tileSize: 512,
            #     zoomOffset: -1,
#     #         #     accessToken: 'your.mapbox.access.token'
#     #         # }).addTo(mymap);
#     #         L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#     #             attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
#     #             accessToken:"pk.eyJ1IjoicmVwamFja3NvbiIsImEiOiJja21iN3V5OWgwMGI4Mm5temU0ZHk3bjVsIn0.3nq7qTUAh0up18iIIuOPrQ"
#     #             maxZoom: 21,
#     #             minZoom: 18,
#     #             id: 'mapbox/outdoors-v11',
#     #             tileSize: 512,
#     #             zoomOffset: -1,
#     #         }).addTo(map);
#     #         console.log map
            
#     #         L.marker([51.5, -0.09]).addTo(map)
#     #             .bindPopup('person')
#     #             .openPopup();
#     #         # circle = L.circle([51.508, -0.11], {
#     #         #     color: 'red',
#     #         #     fillColor: '#f03',
#     #         #     fillOpacity: 0.5,
#     #         #     radius:100
#     #         # }).addTo(mymap);
    
#     #         # L.marker([53.5, -0.1]).addTo(map)
#     #         #     .bindPopup('person')
#     #         #     .openPopup();




    
#     #         pos.coords.latitude
#     #         Session.set('current_lat', pos.coords.latitude)
#     #         Session.set('current_long', pos.coords.longitude)
#     #         # Meteor.users.update Meteor.userId(),
#     #         #     $set:current_position:pos
#     #         @map = L.map('mapid',{
#     #             dragging:false, 
#     #             zoomControl:false
#     #             bounceAtZoomLimits:false
#     #             touchZoom:false
#     #             doubleClickZoom:false
#     #             }).setView([Session.get('current_lat'), Session.get('current_long')], 17);
    
#     #         # var map = L.map('map', {
#     #         # doubleClickZoom: false
#     #         # }).setView([49.25044, -123.137], 13);
            
#     #         # L.tileLayer.provider('Stamen.Watercolor').addTo(map);
            
#     #         # map.on('dblclick', (event)->
#     #         #     console.log 'clicked', event
#     #         #     Markers.insert({latlng: event.latlng});
#     #         # )
#     #         # // add clustermarkers
#     #         # markers = L.markerClusterGroup();
#     #         # map.addLayer(markers);
            
#     #         query = Markers.find();
#     #         query.observe
#     #             added: (doc)->
#     #                 console.log 'added marker', doc
#     #                 # marker = L.marker(doc.latlng).on('click', (event)->
#     #                 #     Markers.remove({_id: doc._id});
#     #                 # );
#     #                 # console.log {{c.url currentUser.profile_image_id height=500 width=500 gravity='face' crop='fill'}}
#     #                 myIcon = L.icon({
#     #                     iconUrl:"https://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_100/#{Meteor.user().profile_image_id}"
#     #                     iconSize: [38, 95],
#     #                     iconAnchor: [22, 94],
#     #                     popupAnchor: [-3, -76],
#     #                     # shadowUrl: 'my-icon-shadow.png',
#     #                     shadowSize: [68, 95],
#     #                     shadowAnchor: [22, 94]
#     #                 });
    
#     #                 L.marker([doc.latlng.lat, doc.latlng.long],{
#     #                     draggable:true
#     #                     icon:myIcon
#     #                     riseOnHover:true
#     #                     }).addTo(map)
#     #                 # markers.addLayer(marker);
                    
#     #             removed: (oldDocument)->
#     #                 layers = map._layers;
#     #                 for key in layers
#     #                     val = layers[key];
#     #                     if (val._latlng)
#     #                         if val._latlng.lat is oldDocument.latlng.lat and val._latlng.lng is oldDocument.latlng.lng
#     #                             markers.removeLayer(val)
                
#     #         L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#     #             # attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
#     #             accessToken:"pk.eyJ1IjoicmVwamFja3NvbiIsImEiOiJja21iN3V5OWgwMGI4Mm5temU0ZHk3bjVsIn0.3nq7qTUAh0up18iIIuOPrQ"
#     #             maxZoom: 19,
#     #             minZoom: 19,
#     #             id: 'mapbox/outdoors-v11',
#     #             tileSize: 512,
#     #             zoomOffset: -1,
#     #         }).addTo(map);
#     #         # L.marker([Session.get('current_lat'), Session.get('current_long')]).addTo(map)
#     #             # .openPopup();
#     #             # .bindPopup('you')
#     #         L.circle([Session.get('current_lat'), Session.get('current_long')], {
#     #             color: 'blue',
#     #             weight: 0
#     #             fillColor: '#3b5998',
#     #             fillOpacity: 0.16,
#     #             radius: 50
#     #         }).addTo(map);
#     #         onMapClick = (e)->
#     #             alert("You clicked the map at " + e.latlng);
            
#             # map.on('click', onMapClick);
