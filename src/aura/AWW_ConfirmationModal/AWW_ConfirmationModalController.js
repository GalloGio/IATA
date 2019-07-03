({
    show : function(component, event, helper) {
        var params = event.getParam('arguments');
        component.set('v.header', params.header)
        component.set('v.message', params.message);
        component.set('v.action', params.action);
        
        helper.handleVisibility(component, 'show');
        
    },
    hide : function(component, event, helper) {
        helper.handleVisibility(component, 'hide');
    },
    yes : function(component, event, helper) {
        helper.handleDecision(component, 'yes');
        helper.handleVisibility(component, 'hide');
    },
    no : function(component, event, helper) {
        helper.handleDecision(component, 'no');
        helper.handleVisibility(component, 'hide');
    }
})