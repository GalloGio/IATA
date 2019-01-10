({
	doInit : function(cmp, evt, hlp) {
		hlp.getInterestsList(cmp);
		cmp.set("v.email", _userInfo.getUserInfo().email);
	},

	saveAll : function(cmp, evt, hlp) {
		var allInterests = cmp.get("v.interests");
		var choices = cmp.find("interestsCbx");
		var userChoice = [];
	
		for (var i = 0; i < choices.length; i++) { 
			if(choices[i].get("v.value")) {
				userChoice.push(allInterests[i].label);
			}
		}
		hlp.saveInterests(cmp, _userInfo.getUserInfo().pardotID, _userInfo.getUserInfo().individualId, userChoice);
	}
})