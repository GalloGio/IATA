({
	showToast : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : "error",
            "title": "Maximum number of accounts reached!",
            "message": "You cannot create users anymore as you reach the limit!"
        });
        toastEvent.fire();
    },


    
    loadAccountInfo : function(component) {

    // Display component only if it's a primary user (= having persmission set primary user)
		var action = component.get("c.isFredPrimaryUser");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var p = response.getReturnValue();

                component.set("v.isFredPrimaryUser", p.isFredPrimaryUser);
                component.set("v.primaryUserId", p.primaryUserId);
                component.set("v.maxNbOfPrimaryReached", p.nbOfPrimaryInAccount >= p.maxPrimary); 
            	component.set("v.maxNbOfSecondaryReached", p.nbOfSecondaryInAccount >= p.maxSecondary);

            } else if (state === "ERROR") {
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

     showRoles : function(component, event, helper) {
        var action = component.get("c.getroles");

        action.setParams({connectedapp : component.get("v.serviceName")});
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var results = a.getReturnValue();
                component.set("v.roles", results);
                component.set("v.showRoles", true);
            } else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
    },

    showToast : function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message, 
            "type": type
        });
        toastEvent.fire();
    }, 
})