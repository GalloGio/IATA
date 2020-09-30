({
    checkStatusAccountfunction : function(component, helper) {
        var action = component.get('c.checkStatusAccount');
        var accountid = component.get('v.recordId');
        action.setParams({'accountID': accountid});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result){
                    helper.checkEnableOrDisableBSPParticipation(component, helper);
                }else{
                    component.set('v.showLoading', false);
                    component.set('v.showLocationClassError', true);
                }
            }
        });

        $A.enqueueAction(action);
    },
    checkEnableOrDisableBSPParticipation : function(component, helper){
        var action = component.get('c.checkEnableOrDisableBSPParticipationAura');
        var accountid = component.get('v.recordId');
        action.setParams({'accountID': accountid});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.showLoading', false);
                component.set('v.showDisableEnable', result);
            }
        });

        $A.enqueueAction(action);
    }
})