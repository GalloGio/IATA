({
	controlToken : function(cmp) {
		var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 

		var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
		var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
		var sParameterName;
		var i;
		var encryptedToken = null;

		for (i = 0; i < sURLVariables.length; i++) {
			sParameterName = sURLVariables[i].split('='); //to split the key from the value.
			if (sParameterName[0] == 'token') { //lets say you are looking for param name - firstName
				sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
				encryptedToken = sParameterName[1];
			}
		}

		if(encryptedToken != null) {
			// Decrypt token with 
			var email = '';

			// if email format is valid
			return email.match(regExpEmailformat);
		}
		return false;

	},

	checkRequiredFields : function(cmp) {
		var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/; 
		cmp.set("v.submit", true);

		var isAllFilled = true;
		var firstName = cmp.find("firstName");
        if($A.util.isEmpty(firstName.get("v.value"))) {
            firstName.set("v.errors", [{message: $A.get("$Label.c.ISSP_Registration_Error_FirstName")}]);
            isAllFilled = false;
        } else {
            firstName.set("v.errors", null);
        } 

        var lastName = cmp.find("lastName");
        if($A.util.isEmpty(lastName.get("v.value"))) {
            lastName.set("v.errors", [{message: $A.get("$Label.c.ISSP_Registration_Error_LastName")}]);
            isAllFilled = false;
        } else {
            lastName.set("v.errors", null);
		}

		var company = cmp.find("company");
        if($A.util.isEmpty(company.get("v.value"))) {
            company.set("v.errors", [{message: "Please enter your company name"}]);
            isAllFilled = false;
        } else {
            company.set("v.errors", null);
		}
		
		var email = cmp.find("email");
		var emailValue = email.get("v.value");
        if($A.util.isEmpty(email.get("v.value"))) {
            email.set("v.errors", [{message: $A.get("$Label.c.ISSP_EmailError")}]);
            isAllFilled = false;
        } else {
			if(! emailValue.match(regExpEmailformat)) {
				email.set("v.errors", [{ message: $A.get("$Label.c.ISSP_AMS_Invalid_Email")}]);
				isAllFilled = false;
			} else {
				email.set("v.errors", null);
			}
		}

        if(!cmp.get("v.termsChecked")) {
            isAllFilled = false;
		} 
		console.log('isAllFilled'+isAllFilled);
		return isAllFilled;

	},

	sendWelcomeEmail : function(cmp) {
		var action = cmp.get("c.grantAccessToPortal");
			action.setParams({
				"indiv":cmp.get("v.individual")
			});
			action.setCallback(this, function(resp) {
				var tokenizedLink = resp.getReturnValue();
				if(tokenizedLink != null) {
					// Send welcome email
					hlp.sendWelcomeEmail(cmp);
					// Redirect to the portal
					window.location.replace(tokenizedLink);
				} else {
					console.log('Error');
				}
		});	
		$A.enqueueAction(action);   
	}
})