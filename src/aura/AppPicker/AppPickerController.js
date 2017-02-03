({
	initialize : function(component, event, helper) {
		var action = component.get("c.ConnectedAppsList");
		action.setCallback(this, function(a) {
			var results = a.getReturnValue();
			component.set("v.appNames", results);
			component.set("v.activeApp", results[0]);
			helper.getPic(component);
			helper.getAppDescription(component);
		});
    	$A.enqueueAction(action);

	},
	handleClick : function(component, event, helper) {
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
		component.set("v.activePage", page);
		helper.getPic(component);
		helper.getAppDescription(component);
	},
	pagePrevious : function(component, event, helper) {
		var page = component.get("v.activePage");

		if(page > 0) {
			page--;
			var results = component.get("v.appNames");
			component.set("v.activeApp", results[page]);
			component.set("v.activePage", page);
			helper.getPic(component);
			helper.getAppDescription(component);
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
			helper.getPic(component);
			helper.getAppDescription(component);
		}
	},

	showRoles : function(component, event, helper) {
		var activeApp = event.getSource().get("v.value");
		var action = component.get("c.getroles");
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
	},
	submitRequest : function(component, event, helper) {

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
                    component.set("v.showPopup", false);
                    component.set("v.showRoles", false);
                    component.set("v.submitDisabled", false);
                    var backdrop = component.find("backdrop");
                    $A.util.removeClass(backdrop, 'slds-backdrop');
                    alert (confirm);
				} else {
					console.log(state);
				}
				// component.set("v.activeApp", results[0]);
			});
	    	$A.enqueueAction(action);
	}
})