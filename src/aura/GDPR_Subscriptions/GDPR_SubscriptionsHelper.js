({
	getSubcriptionsList : function(cmp) {
		// Retrieve subscritpion list from custom settings
		var action = cmp.get("c.getSubscriptionList");
        action.setParams({
			"email" : _userInfo.getUserInfo().email,
			"salesforceId" : _userInfo.getUserInfo().salesforceId
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result != null) {
				var obj = JSON.parse(result); 
				cmp.set("v.newsletters",obj.newsletters);
				cmp.set("v.products",obj.products);
				cmp.set("v.initialSubscription", obj.initialSubscription);
				cmp.set("v.opted_out", obj.opted_out);
				cmp.set("v.unsubscribe", obj.opted_out);
				if(! $A.util.isEmpty(_userInfo.getUserInfo().salesforceId)) {
					cmp.set("v.salesforceSynced", true);
				}
            } else {
				this.showToast("error", "Error", "An error occurs");
			}
        });
		$A.enqueueAction(action);
	},

	saveSubscriptions : function(cmp, currentChoice) {
		var initialChoice = cmp.get("v.initialSubscription");
		var subArray = []; // New subscription that need to be done
		var unsubArray = []; // Unsubscription thath need to be done

		for (var i = 0; i < currentChoice.length; i++) { 
			if(! this.arrayContains(currentChoice[i], initialChoice))
				subArray.push(currentChoice[i]);
		}

		for (var i = 0; i < initialChoice.length; i++) { 
			if(! this.arrayContains(initialChoice[i], currentChoice))
			unsubArray.push(initialChoice[i]);
		}
		// Subscribe or unscribe to lists
		var action = cmp.get("c.updateSubscriptionList");
        action.setParams({
			"prospect_id" : _userInfo.getUserInfo().pardotID,
			"email" : _userInfo.getUserInfo().email,
			"subscription_ids" : subArray,
			"unsubscription_ids" : unsubArray
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result) {
				this.showToast("success", "Success","Your subscriptions have been updated");
				cmp.set("v.initialSubscription", currentChoice);
            } else {
				this.showToast("error", "Error", "An error occurs");
			}
			cmp.set("v.localLoading", false);
        });
		$A.enqueueAction(action);
	},

	arrayContains : function (needle, arrhaystack) {
    	return (arrhaystack.indexOf(needle) > -1);
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
			console.log(result);
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