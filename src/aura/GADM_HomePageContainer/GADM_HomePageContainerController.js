/**
 * Created by ppop on 8/8/2019.
 */
({
    initializeComponent: function(component, event, helper) {
        let action = component.get('c.getObjects');
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                console.log(response.getReturnValue());
                component.set("v.objectIds", response.getReturnValue());
                component.set("v.initialized", true);
            }
        });
        $A.enqueueAction(action);
    },
})