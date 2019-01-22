({
	doInit : function(component, event, helper) {
		var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
		var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
		var sParameterName;
		var encryptedToken;
		var encryptedIndividualId;

		for (var i = 0; i < sURLVariables.length; i++) {
			
			sParameterName = sURLVariables[i].split('='); //to split the key from the value.
		
			if (sParameterName[0] == 'token') { //lets say you are looking for param name - firstName
				encryptedToken = sParameterName[1];
			}else if(sParameterName[0] == 'indId'){
				encryptedIndividualId = sParameterName[1];
			}
		}
		
		if(encryptedToken && encryptedIndividualId){
			var action = component.get('c.checkIfValidToken');
			action.setParams({"encryptedToken":encryptedToken,  "encryptedId":encryptedIndividualId});
			action.setCallback(this, function(response){
				var responseValue = response.getReturnValue();
				if(responseValue === 'VALID'){
					component.set('v.isValid', true);
					var spinner = cmp.find("spinner");
					$A.util.toggleClass(spinner, "slds-hide");
				}else {
					window.open($A.get('$Label.c.IATA_GDPR_URL')+'/s/invalid-token','_top');
				}
			});
			$A.enqueueAction(action);
		}else{
			window.open($A.get('$Label.c.IATA_GDPR_URL')+'/s/landing','_top');
		}
	}
})