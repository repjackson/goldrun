if Meteor.isClient    
    Template.alpha.onRendered ->
        # unless @data.watson
            # Meteor.call 'call_watson', @data._id, 'url','url',->
        # if @data.response
        # window.speechSynthesis.cancel()
        # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[1].plaintext
        # if @data 
        #     if @data.voice
        #         window.speechSynthesis.speak new SpeechSynthesisUtterance @data.voice
        #     else if @data.response
        #         if @data.response.queryresult.pods
        #             window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[0].plaintext
        # Meteor.setTimeout( =>
        # , 7000)
    
    Template.alpha.helpers
        alphas: ->
            Docs.find
                model:'alpha'
        
        split_datatypes: ->
            split = @datatypes.split ','
            split
    
    Template.alpha.events
        'click .select_datatype': ->
            picked_tags.push @valueOf().toLowerCase()
        'click .alphatemp': ->
            # window.speechSynthesis.cancel()
            # window.speechSynthesis.speak new SpeechSynthesisUtterance @plaintext
            
