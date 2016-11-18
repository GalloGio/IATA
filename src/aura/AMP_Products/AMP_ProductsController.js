({
	doInit: function(component, event, helper) {
		var action;
        action = component.get("c.canViewSalesfigures");
        //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            // console.log(JSON.stringify(actionResult.getReturnValue()));
            component.set("v.canRead", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
    },
})
