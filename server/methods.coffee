Meteor.methods
    search_musician: (search)->
        HTTP.get "https://www.theaudiodb.com/api/v1/json/523532/searchalbum.php?s=#{search}",(err,response)=>
            console.log response
