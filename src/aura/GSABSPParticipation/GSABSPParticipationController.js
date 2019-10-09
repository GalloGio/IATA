({
    doInit : function(component,event,helper) {
        var action = component.get('c.checkUserPermissionsBSPParticipationAura');
        var accountid = component.get('v.recordId');
        //action.setParams({'accountID': accountid});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('MR::: ',response);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result){
                    helper.checkStatusAccountfunction(component,helper);
                }else{
                    component.set('v.showLoading', false);
                    component.set('v.showUserError', true);
                }
            }
        });

        $A.enqueueAction(action);
    },
    doDisable : function(component, event, helper) {
        component.set('v.showLoading', true);
        var action = component.get('c.disableBSPParticipationAura');
        var accountid = component.get('v.recordId');
        action.setParams({'accountID': accountid});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('MR::: ',response);
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                window.location.reload()
            }
        });

        $A.enqueueAction(action);
    },
    doEnable : function(component, event, helper) {
        component.set('v.showLoading', true);
        var action = component.get('c.enableBSPParticipationAura');
        var accountid = component.get('v.recordId');
        action.setParams({'accountID': accountid});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('MR::: ',response);
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                window.location.reload()
            }
        });

        $A.enqueueAction(action);
    }
})