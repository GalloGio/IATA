({
	getInterestsList : function(cmp) {
		// Retrieve interest list from custom settings
		var action = cmp.get("c.getInterestList");
		action.setParams({
			"email" : _userInfo.getUserInfo().email,
			"salesforceId" : _userInfo.getUserInfo().salesforceId
        });
        action.setCallback(this, function(a) {
			var result = a.getReturnValue();
            if(result != null) {
				cmp.set("v.interests",result );
				if(result!= null && result.length>0) {
					cmp.set("v.opted_out", result[0].opted_out);
					cmp.set("v.unsubscribe", result[0].opted_out);
				}
				if(! $A.util.isEmpty(_userInfo.getUserInfo().salesforceId)) {
					cmp.set("v.salesforceSynced", true);
				}
            } else {
				console.log("error");
			}
        });
		$A.enqueueAction(action);
	},

	saveInterests : function(cmp, pardotID, individualId, userChoice) {
		// Retrieve subscritpion list from custom settings
		var action = cmp.get("c.updateInterest");
		action.setParams({
			"prospectID":  pardotID,
			"email":  _userInfo.getUserInfo().email,
			"interests" : userChoice,
			"individualId" : individualId,
        });
        //updateInterest(String prospectID, list<String> interests) {
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result != null) {
					this.showToast("success", "Success","Your interests have been updated");
            } else {
					this.showToast("error", "Error", "An error occurs");
			}
			cmp.set("v.localLoading", false);
        });
		$A.enqueueAction(action);
	},

	showToast : function(type, title, msg) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type": type,
			"title": title,
			"message": msg
		});
		toastEvent.fire();
	},

	subscribe : function(cmp) {
		// Opt-in by upading the lead or contact and the connector will sync the info in Pardot (not possible to opt-in using the API)
		var action = cmp.get("c.optIn");
		action.setParams({
			"salesforce_id" : _userInfo.getUserInfo().salesforceId,
			"email" : _userInfo.getUserInfo().email,
			"doOptOut" : cmp.get("v.unsubscribe")
		});
		action.setCallback(this, function(a) {
			var result = a.getReturnValue();
			if(result) {
				this.showToast("success", "Success","Your subscriptions have been updated");
				cmp.set("v.opted_out", cmp.get("v.unsubscribe"));
				// Notifiy interest component to be synced
				var appEvent = $A.get("e.c:EVT_GDPR_OptOutSync");
				appEvent.setParams({"optout" :  cmp.get("v.unsubscribe")});
				appEvent.fire();
			} else {
				this.showToast("error", "Error","An error occurs");
			}

			cmp.set("v.localLoading", false);
		});
		$A.enqueueAction(action);
	},

	
})