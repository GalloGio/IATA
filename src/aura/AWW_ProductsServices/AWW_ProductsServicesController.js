({
    init : function(component, event, helper) {
        var action = component.get('c.getProductsAndServices');
        
        action.setParams({accountId: component.get('v.accountId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.accessToSAP', result.hasAccessToSAPFigures);
                component.set('v.linkToSAP', result.linkToSAPFigures);
                component.set('v.nonServices', result.nonServices);
                component.set('v.industryServices', result.services);
            }
        });

        $A.enqueueAction(action);
    }
})