({
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

	showToast : function(type, title, msg) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type": type,
			"title": title,
			"message": msg
		});
		toastEvent.fire();
	},
})