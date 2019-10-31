({
    getUnaddedProducts : function(component) {
        this.toggleSpinner(component);
        var action = component.get('c.getUnaddedProducts');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                component.set('v.prodList', response.getReturnValue());
                component.set('v.loaded', true);
                this.toggleSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    toggleSpinner : function(component) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    }
})