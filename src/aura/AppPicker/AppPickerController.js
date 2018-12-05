({
	initialize : function(component, event, helper) {
	    console.log('initialize');
		var action = component.get("c.ConnectedAppsList");
		action.setCallback(this, function(a) {
			var results = a.getReturnValue();
			component.set("v.appNames", results);
			component.set("v.activeApp", results[0]);
			component.set("v.Terms", false);
			component.set("v.termsLocked", false);
			component.set("v.requestAppDisabled", true);
			helper.getPic(component);
			helper.getAppDescription(component);
			helper.getAppTerms(component);
            helper.getAppRoleSelectibility(component);
		});
    	$A.enqueueAction(action);
	},
	handleClick : function(component, event, helper) {
		console.log('clicked');
		component.set("v.showPopup", true);
		var backdrop = component.find("backdrop");
		$A.util.addClass(backdrop, 'slds-backdrop');


	},
	handleClose : function(component, event, helper) {
		component.set("v.showPopup", false);
		component.set("v.showRoles", false);
		var backdrop = component.find("backdrop");
		$A.util.removeClass(backdrop, 'slds-backdrop');
	},
	changePage : function(component, event, helper) {
		var page = event.getSource().get("v.value");
		console.log('page: ' + page);
		component.set("v.activePage", page);
		var results = component.get("v.appNames");
		component.set("v.activeApp", results[page]);
        component.set("v.Terms", false);
        component.set("v.termsLocked", false);
        component.set("v.requestAppDisabled", true);
//        var btnReqApp = component.find("btnReqApp");
//        btnReqApp.set("v.disabled", true);
		helper.getPic(component);
		helper.getAppDescription(component);
		helper.getAppTerms(component);
		helper.getAppRoleSelectibility(component);
	},
	pagePrevious : function(component, event, helper) {
		var page = component.get("v.activePage");

		if(page > 0) {
			page--;
			var results = component.get("v.appNames");
			component.set("v.activeApp", results[page]);
			component.set("v.activePage", page);
			component.set("v.Terms", false);
			component.set("v.termsLocked", false);
			component.set("v.requestAppDisabled", true);
			helper.getPic(component);
			helper.getAppDescription(component);
			helper.getAppTerms(component);
            helper.getAppRoleSelectibility(component);
		}
	},
	pageNext : function(component, event, helper) {
		var page = component.get("v.activePage");
		var pages = component.get("v.appNames");

		if(page < (pages.length-1)) {
			page++;
			var results = component.get("v.appNames");
			component.set("v.activeApp", results[page]);
			component.set("v.activePage", page);
			component.set("v.Terms", false);
			component.set("v.termsLocked", false);
			component.set("v.requestAppDisabled", true);
			helper.getPic(component);
			helper.getAppDescription(component);
			helper.getAppTerms(component);
            helper.getAppRoleSelectibility(component);
		}
	},

	showRoles : function(component, event, helper) {
		var activeAppSource = component.find("activeApp");
		var activeApp = activeAppSource.get("v.value");
		var action = component.get("c.getroles");
		component.set("v.submitDisabled", true);
		// console.log(activeApp);
		action.setParams({connectedapp : activeApp});
		action.setCallback(this, function(a) {
			var state = a.getState();
			console.log(state);
			if (state === "SUCCESS") {
				var results = a.getReturnValue();

				component.set("v.roles", results);
				component.set("v.showRoles", true);
			} else {
				console.log(state);
			}
			// component.set("v.activeApp", results[0]);
		});
    	$A.enqueueAction(action);
	},
	hideRoles : function(component, event, helper) {
		component.set("v.showRoles", false);
	},
	clickRadio : function(component, event, helper) {
		component.set("v.selectedRole", event.getSource().get("v.label"));
		console.log('LABEL: ' + event.getSource().get("v.label"));
		component.set("v.submitDisabled", false);
	},

    checkSelectedRoleAvailability : function(component, event, helper){
        // For Fred, we need to check the roles availability accordingly to the following logic
        // - if there is no Fred user in the company, the Primary User role is given
        // - otherwise, the Secondary User role is given if the limit is not reached
        var fredServiceRequestWarining = 'Please note, you are about to request access to FRED+. This service facilitates CORSIA CO2 emissions reporting for Aircraft Operators and State Authorities and your access request will be assessed by the FRED+ team. Please confirm that you would like to proceed.';
        if(component.get("v.activeApp") == 'FRED'){
			var action = component.get("c.getAutomaticRole");
			action.setParams({connectedapp : component.get("v.activeApp")});
			action.setCallback(this, function(a) {
				var state = a.getState();
				// console.log(state);
                if (state === "SUCCESS"){
					var results = a.getReturnValue();
                    
                    if(results == ''){
						alert($A.get("$Label.c.OneId_Max_Account_Reached2"));
                    }
                    else{
                        component.set("v.selectedRole", results);
						var action2 = component.get('c.submitRequest');
                        if(confirm(fredServiceRequestWarining)){
                        	$A.enqueueAction(action2);
                        }
                    }
				} else {
					console.log(state);
				}
			});
	    	$A.enqueueAction(action);            
        }
        else{
            var action2 = component.get('c.submitRequest');
            $A.enqueueAction(action2);
        }
    },

	submitRequest : function(component, event, helper) {
		helper.showSpinner(component, event);
		var activeApp = component.get("v.activeApp");
		var selectedRole = component.get("v.selectedRole");

		var action = component.get("c.submit");
        console.log("Submit3-1 " );

			component.set("v.submitDisabled", true);
			action.setParams({connectedapp : activeApp, role : selectedRole});
			action.setCallback(this, function(a) {
				var state = a.getState();
				// console.log(state);
				if (state === "SUCCESS") {
					var confirm = $A.get("$Label.c.ISSP_Submit_ConnectedApp");
                    //component.set("v.submitDisabled", false);
                    var requestFill = component.find("requestFill");
                    $A.util.addClass(requestFill, 'hide');
                    var requestSent = component.find("requestSent");
                    $A.util.removeClass(requestSent, 'hide');

					component.set("v.requestSent", true);
				} else {
					console.log(state);
				}
				// component.set("v.activeApp", results[0]);
				helper.hideSpinner(component, event);
			});
	    	$A.enqueueAction(action);
	},
	closeRequest : function(component, event, helper) {
		console.log('closing');
		component.set("v.showRoles", false);
		component.set("v.showPopup", false);
		var backdrop = component.find("backdrop");
        $A.util.removeClass(backdrop, 'slds-backdrop');
        $A.get('e.force:refreshView').fire();
	},

	checkTerms : function(component, event, helper) {
		var terms = component.get("v.Terms");
		if(terms){
            //component.set("v.termsaccepted", true);
            component.set("v.termsLocked", true);
            component.set("v.requestAppDisabled", false);
        }else{
            //component.set("v.termsaccepted", false);
            component.set("v.termsLocked", false);
            component.set("v.requestAppDisabled", true);

        }
	},
})