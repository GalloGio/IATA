({
    controlSpinner : function(component, event, helper) {
        var option = event.getParam('option');
        var spinner = component.find('app-spinner');
        if(option == 'show') {
            $A.util.removeClass(spinner, 'slds-hide');
        } else if(option == 'hide') {
            $A.util.addClass(spinner, 'slds-hide');
        }
    }
})