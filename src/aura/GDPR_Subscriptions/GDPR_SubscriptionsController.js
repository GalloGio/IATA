({	
	doInit : function(cmp, evt, hlp) {
		
		cmp.set("v.salesforceSynced", _userInfo.getUserInfo() != null && !$A.util.isEmpty(_userInfo.getUserInfo().salesforceId));
		hlp.getSubcriptionsList(cmp);
		cmp.set("v.email", _userInfo.getUserInfo().email);
	},

	saveAll : function(cmp, evt, hlp) {
		cmp.set("v.localLoading", true);

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

	changeUnsubscribe : function(cmp, evt, hlp) {
		cmp.set("v.localLoading", true);
		hlp.subscribe(cmp);
	},

	redirectToSubscriptionTab : function(cmp, evt, hlp) {
		// Notify tabs component to display the subscription tab
		var aaa = $A.get("e.c:EVT_GDPR_DisplayTab");
		aaa.setParams({"activeTabId": "3"}); 
		aaa.fire();
	},

	handleEVT_GDPR_OptOutSync : function(cmp, evt, hlp) {
		cmp.set("v.opted_out", evt.getParam("optout"));
		cmp.set("v.unsubscribe", evt.getParam("optout"));
	},

	selectAll : function(cmp, evt, hlp) {
		var allNewletters = cmp.get("v.newsletters");
		for (var i = 0; i < allNewletters.length; i++) { 
			allNewletters[i].selected = true;
		}
		cmp.set("v.newsletters", allNewletters);

		var allProducts = cmp.get("v.products");
		for (var i = 0; i < allProducts.length; i++) { 
			allProducts[i].selected = true;
		}
		cmp.set("v.products", allProducts);
	}
	
})