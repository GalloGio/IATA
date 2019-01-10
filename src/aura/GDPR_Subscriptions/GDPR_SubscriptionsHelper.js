({
	getSubcriptionsList : function(cmp) {
		// Retrieve subscritpion list from custom settings
		var action = cmp.get("c.getSubscriptionList");
        action.setParams({
			"email" : _userInfo.getUserInfo().email
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result != null) {
				console.log(JSON.parse(result));
				var obj = JSON.parse(result); 
				cmp.set("v.newsletters",obj.newsletters);
				cmp.set("v.products",obj.products);
				cmp.set("v.initialSubscription", obj.initialSubscription);
				cmp.set("v.opted_out", obj.opted_out);
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
				this.showToast("success", "Success","Information updated");
				cmp.set("v.initialSubscription", currentChoice);
            } else {
				this.showToast("error", "Error", "An error occurs");
			}
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
	}
})