({
    checkStatusAccountfunction : function(component, helper) {
        var action = component.get('c.checkStatusAccount');
        var accountid = component.get('v.recordId');
        action.setParams({'accountID': accountid});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('MR::: ',response);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('MR::: result',result);
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
            console.log('MR::: ',response);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('MR::: result2',result);
                component.set('v.showLoading', false);
                component.set('v.showDisableEnable', result);
            }
        });

        $A.enqueueAction(action);
    }
})