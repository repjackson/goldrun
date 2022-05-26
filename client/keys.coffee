globalHotkeys = new Hotkeys();

globalHotkeys.add({
	combo : "ctrl+4",
	eventType: "keydown",
	callback : ()->
		alert("You pressed ctrl+4");
})

globalHotkeys.add({
	combo : "r a",
	callback : ()->
	    if Meteor.userId()
	        Meteor.users.update Meteor.userId(),
	            $set:
	                admin_mode:!Meteor.user().admin_mode
# 		alert("admin mode toggle")
})
