({
    doInit : function(component,event,helper) {
        var action = component.get('c.getUserAccessRights');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.accessLevel', response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    }
})