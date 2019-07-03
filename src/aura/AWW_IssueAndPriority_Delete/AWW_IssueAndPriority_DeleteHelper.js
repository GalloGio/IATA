({
    hideModal : function(component) {
        var modal = component.find('delete-issue');
        $A.util.addClass(modal, 'slds-hide');        
    },
    showModal : function(component) {
        component.set('v.errorMessage', null);
        var modal = component.find('delete-issue');
        $A.util.removeClass(modal, 'slds-hide');
    }, 
    handleDelete : function(component,record) {
        var action = component.get('c.deleteIssue');

        action.setParams({
            'issue': record
        });

        this.handleSpinner(component, 'show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {   
                var refreshTab = component.getEvent('refreshTab');
                refreshTab.setParams({
                    tabName : 'issues_and_priorities'
                });
                refreshTab.fire();              
                this.hideModal(component);
            } else {
                var message = 'Unknown error';
                var errors = response.getError();
                if(errors && Array.isArray(errors) && errors.length > 0 && Array.isArray(errors[0].pageErrors) && errors[0].pageErrors.length > 0) {
                    message = errors[0].pageErrors[0].message;
                }

                component.set('v.errorMessage', message);
            }

            this.handleSpinner(component, 'hide');
        });

        $A.enqueueAction(action);
    },
    handleSpinner : function(component, value) {
        var spinner = component.getEvent('controlSpinner');
        spinner.setParams({'option': value});
        spinner.fire();
    }
})