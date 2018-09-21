({
	getPic : function(component) {
		var action = component.get("c.getPic");
		var activeApp = component.get("v.activeApp");
		// console.log('getPic');
		action.setParams({connectedapp : activeApp});
		action.setCallback(this, function(a) {
			var state = a.getState();
			// console.log(state);
			if (state === "SUCCESS") {
				var results = a.getReturnValue();
				component.set("v.activeAppPic", results);
			} else {
				console.log(state);
			}
			// component.set("v.activeApp", results[0]);
		});
    	$A.enqueueAction(action);
	},
	getAppDescription : function(component) {
      		var action = component.get("c.getAppDescription");
      		var activeApp = component.get("v.activeApp");

      		action.setParams({connectedapp : activeApp});
      		action.setCallback(this, function(a) {
      			var state = a.getState();
      			// console.log(state);
      			if (state === "SUCCESS") {
      				var results = a.getReturnValue();
      				component.set("v.activeAppDescription", results);
      			} else {
      				console.log(state);
      			}
      			// component.set("v.activeApp", results[0]);
      		});
          	$A.enqueueAction(action);
      	},
	getAppTerms : function(component) {
      		var action = component.get("c.getAppTerms");
      		var activeApp = component.get("v.activeApp");

      		action.setParams({connectedapp : activeApp});
      		action.setCallback(this, function(a) {
      			var state = a.getState();
      			// console.log(state);
      			if (state === "SUCCESS") {
      				var results = a.getReturnValue();
      				component.set("v.activeAppTerms", results);
      			} else {
      				console.log(state);
      			}
      			// component.set("v.activeApp", results[0]);
      		});
          	$A.enqueueAction(action);
      	},
	getAppRoleSelectibility : function(component) {
      		var action = component.get("c.getAppRoleSelectibility");
      		var activeApp = component.get("v.activeApp");

      		action.setParams({connectedapp : activeApp});
      		action.setCallback(this, function(a) {
      			var state = a.getState();
      			if (state === "SUCCESS") {
      				var results = a.getReturnValue();
      				component.set("v.activeAppRoleSelectibility", results);
      			} else {
      				console.log(state);
      			}
      		});
          	$A.enqueueAction(action);
      	},
	showSpinner: function(component) {
        var div = component.find("spinner");
        $A.util.removeClass(div, 'slds-hide');
        $A.util.addClass(div, 'slds-show');
    },
    hideSpinner: function(component) {
        var div = component.find("spinner");
        $A.util.removeClass(div, 'slds-show');
        $A.util.addClass(div, 'slds-hide');
    },

})