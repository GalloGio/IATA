({
	getUserInfo : function(component) {
		var action = component.get("c.getUserInfo");
		
		action.setCallback(this, function(response){
			var state = response.getState();
			
			if(state ==="SUCCESS"){
				console.log("SUCCESS");
				console.log(JSON.stringify(response.getReturnValue()));
				component.set('v.userinfo',response.getReturnValue());
			} 
			else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
		});

		$A.enqueueAction(action);
	},
	getUserContact : function(component) {
		var action = component.get("c.getUserContact");
		
		action.setCallback(this, function(response){
			var state = response.getState();
			
			if(state ==="SUCCESS"){
				console.log("SUCCESS");
				console.log(JSON.stringify(response.getReturnValue()));
				component.set('v.contactinfo',response.getReturnValue());
			} 
			else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
		});

		$A.enqueueAction(action);
	},
	getCategoryPicklistValues : function(component){
		var action = component.get("c.getCategoryPicklistValues");
		
		action.setCallback(this, function(response){
			var state = response.getState();
			
			if(state ==="SUCCESS"){
				console.log("SUCCESS");
				console.log(JSON.stringify(response.getReturnValue()));
				component.set('v.categorylist',response.getReturnValue());
				var func = component.get('v.contactinfo.Membership_Function__c');
				component.find("functionpicklist").set("v.value",func);
			} 
			else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
		});

		$A.enqueueAction(action);
	},
	getPreferredLanguagePicklistValues : function(component){
		var action = component.get("c.getPreferredLanguagePicklistValues");
		
		action.setCallback(this, function(response){
			var state = response.getState();
			
			if(state ==="SUCCESS"){
				console.log("SUCCESS");
				console.log(JSON.stringify(response.getReturnValue()));
				component.set('v.preferredlanguagelist',response.getReturnValue());
				var lang = component.get('v.contactinfo.Preferred_Language__c');
				component.find("preferredlanguagepicklist").set("v.value",lang);
			} 
			else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
		});

		$A.enqueueAction(action);
	},
})