({
    init : function(component) {
        this.toggleSpinner(component);
        var action = component.get('c.getAirlines');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                component.set('v.airlineList', response.getReturnValue());
                console.log(component.get('v.airlineList'));
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