({
	init : function(component) {
        this.toggleSpinner(component);
        var action = component.get('c.getNDCRelations');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                component.set('v.relatedList', response.getReturnValue());
            }
            this.toggleSpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    getUserInfo : function(component) {
        var action = component.get('c.getUserInfo');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                component.set('v.isAirline', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    toggleSpinner : function(component) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    }
})