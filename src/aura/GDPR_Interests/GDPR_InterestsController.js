({
	doInit : function(cmp, evt, hlp) {
		hlp.getInterestsList(cmp);
		cmp.set("v.email", _userInfo.getUserInfo().email);
	},

	saveAll : function(cmp, evt, hlp) {
		cmp.set("v.localLoading", true);

		var allInterests = cmp.get("v.interests");
		var choices = cmp.find("interestsCbx");
		var userChoice = [];
		
		
		for (var i = 0; i < choices.length; i++) { 
			if(choices[i].get("v.value")) {
				userChoice.push(allInterests[i].label);
			}
		}
		hlp.saveInterests(cmp, _userInfo.getUserInfo().pardotID, _userInfo.getUserInfo().individualId, userChoice);
	},

	changeUnsubscribe : function(cmp, evt, hlp) {
		cmp.set("v.localLoading", true);
		hlp.subscribe(cmp);
	},

	handleEVT_GDPR_OptOutSync : function(cmp, evt, hlp) {
		cmp.set("v.opted_out", evt.getParam("optout"));
		cmp.set("v.unsubscribe", evt.getParam("optout"));
	},

	selectAll : function(cmp, evt, hlp) {
		var allInterests = cmp.get("v.interests");
		// CR1: Add deselect feature to the button
		var check = cmp.get("v.showSelect");
		for (var i = 0; i < allInterests.length; i++) { 
			allInterests[i].selected = check;
		}
		cmp.set("v.interests", allInterests);

		// Change the button label (select all or deselect all)
		cmp.set("v.showSelect", !check);
	}
})