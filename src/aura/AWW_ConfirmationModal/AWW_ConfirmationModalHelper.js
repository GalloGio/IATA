({
    handleVisibility : function(component, action) {
        var modal = component.find('confirmation-modal');
        if(action == 'show') {
            $A.util.removeClass(modal, 'slds-hide');
        } else {
            $A.util.addClass(modal, 'slds-hide');
        }
    },
    handleDecision : function(component, choice) {
        var evt = component.getEvent('confirmation');
        evt.setParams({
            action: component.get('v.action'),
            decision: choice
        });

        evt.fire();
    }
})