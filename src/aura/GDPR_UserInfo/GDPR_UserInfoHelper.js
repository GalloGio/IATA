({
	getPickListValues : function(cmp) {
		// Retrieve picklist values from schema
		var action = cmp.get("c.getPickListValues");
        
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result != null) {
				cmp.set("v.picklists",result );
            } else {
				console.log("Error gettting picklist values");
			}
        });
		$A.enqueueAction(action);
	},

	retrieveUserInfo : function(cmp) {
		// Call Pardot to get latest user info
		var action = cmp.get("c.retrieveUserInfo");
        action.setParams({
			"email":  _userInfo.getUserInfo().email
        });
        action.setCallback(this, function(a) {
			var result = a.getReturnValue();
            if(result != null) {
                   cmp.set("v.individual", result);
            } else {
				console.log("error");
			}
        });
		$A.enqueueAction(action);
	},

	saveUserInfo : function(cmp) {
		// Create lead + individual
		var action = cmp.get("c.updateUserInfo");
        action.setParams({
			"prospect": this.individualToProspect(cmp)
        });

        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result) {
				  this.showToast("success", "Success","User information updated");
			} else {
				this.showToast("error", "Error", "An error occurs");
			}
        });
		$A.enqueueAction(action);
	},

	individualToProspect : function(cmp) {
		var indiv =  cmp.get("v.individual");
		var prospect = cmp.get("v.prospect");

		prospect.first_name = indiv.FirstName;
		prospect.last_name = indiv.LastName;
		prospect.email = indiv.Email__c;

		prospect.salutation = indiv.Salutation;
		prospect.company = indiv.Company__c;
		prospect.job_title = indiv.Job_Title__c;
		prospect.phone = indiv.Phone__c;
		prospect.country = indiv.Country__c;
		prospect.industry = indiv.Industry__c;
		prospect.id = _userInfo.getUserInfo().pardotID;

		return JSON.stringify(prospect);
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