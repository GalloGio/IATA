({
	doInit : function(component, event, helper) {
		// Get URL param token and check if it's an email
		var individualObj = {};
		individualObj.sobjectType = 'Individual';
		individualObj.Email__c = '';
		component.set('v.individual', individualObj);

		var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
		var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
		var sParameterName;
		var encryptedToken;
		var encryptedIndividualId;

		for (var i = 0; i < sURLVariables.length; i++) {
			sParameterName = sURLVariables[i].split('='); //to split the key from the value.
			if (sParameterName[0] == 'token') { //lets say you are looking for param name - firstName
				encryptedToken = sParameterName[1];
			}
		}
		
		if(encryptedToken){
			var action = component.get('c.checkIfValidToken');
			action.setParams({"encryptedToken":encryptedToken});
			action.setCallback(this, function(response){
				var email = response.getReturnValue();
				if(email != null){
					var indiv = component.get("v.individual");
					indiv.Email__c = email;
					component.set('v.individual', indiv);
				}else {
					window.open($A.get('$Label.c.IATA_GDPR_URL')+'/s/invalid-token','_top');
				}
			});
			$A.enqueueAction(action);
		}else{
			window.open($A.get('$Label.c.IATA_GDPR_URL')+'/s/landing','_top');
		}
	},

	submit : function(cmp, evt, hlp) {
		
		if(hlp.checkRequiredFields(cmp)) {
			cmp.set("v.localLoading", true);
			// Create prospect in Pardot + generate token + email to the portal (welcome email)	
			var action = cmp.get("c.grantAccessToPortal");
			action.setParams({
				"indivJson": JSON.stringify(cmp.get("v.individual"))
			});
			action.setCallback(this, function(resp) {
				var tokenizedLink = resp.getReturnValue();
				if(tokenizedLink != null) {
					// Redirect to the portal
					window.location.replace(tokenizedLink);
				} else {
					console.log('Error');
				}
				cmp.set("v.localLoading", false);
			});	
			$A.enqueueAction(action);    
		}
	}
})