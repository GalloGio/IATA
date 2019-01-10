({	
	doInit : function(cmp, evt, hlp) {
		hlp.getSubcriptionsList(cmp);
		cmp.set("v.email", _userInfo.getUserInfo().email);
	},

	saveAll : function(cmp, evt, hlp) {
		var allSubscriptions = [];
		var a = cmp.get("v.newsletters");

		for (var i=0; i < a.length; i++) {
			allSubscriptions.push(cmp.get("v.newsletters")[i]);
		}
		for (var i=0; i< cmp.get("v.products").length; i++) {
			allSubscriptions.push(cmp.get("v.products")[i]);
		}

		cmp.set("v.subscriptions", allSubscriptions);
		var choices = cmp.find("subscriptionsCbx");
		var userChoice = [];
		for (var i = 0; i < choices.length; i++) { 
			if(choices[i].get("v.value")) {
				userChoice.push(allSubscriptions[i].id);
			}
		}
		hlp.saveSubscriptions(cmp, userChoice);
	},

	unsubscribe : function(cmp, evt, hlp) {
		// Opt-out using Pardot API
		var action = cmp.get("c.optOut");
		action.setParams({
			"prospect_id" : _userInfo.getUserInfo().pardotID,
			"email" : _userInfo.getUserInfo().email,
			"doOptOut" : true
		});
		action.setCallback(this, function(a) {
			var result = a.getReturnValue();
			if(result) {
				hlp.showToast("success", "Success","Information updated");
			} else {
				hlp.showToast("error", "Error","An error occurs");
			}
		});
		$A.enqueueAction(action);
	},

	subscribe : function(cmp, evt, hlp) {
		// Opt-in by upading the lead or contact and the connector will sync the info in Pardot (not possible to opt-in using the API)
		var action = cmp.get("c.optIn");
		action.setParams({
			"salesforce_id" : _userInfo.getUserInfo().salesforceId,
			"email" : _userInfo.getUserInfo().email
		});
		action.setCallback(this, function(a) {
			var result = a.getReturnValue();
			if(result) {
				hlp.showToast("success", "Success","Information updated");
				cmp.set("v.opted_out", false);
			} else {
				hlp.showToast("error", "Error","An error occurs");
			}
		});
		$A.enqueueAction(action);
	}
})