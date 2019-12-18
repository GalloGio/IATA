({
    loadDropdowns : function(component) {
        var statusList = [
            {id: '', label: '--None--'},
            {id: 'On Track', label: 'On Track'},
            {id: 'On Hold', label: 'On Hold'},
            {id: 'Delayed', label: 'Delayed'},
            {id: 'Delivered', label: 'Delivered'},
            {id: 'Cancelled', label: 'Cancelled'},
            {id: 'Not Delivered', label: 'Not Delivered'}
        ];
        component.set("v.statusList", statusList);
    },
    showModal : function(component, record) {
        this.clearErros(component);
        component.set('v.errorMessage', null);
        component.set('v.record', record);
        var modal = component.find('milestone-form');
        $A.util.removeClass(modal, 'slds-hide');
    },
    hideModal : function(component) {
        component.set('v.errorMessage', null);
        var modal = component.find('milestone-form');
        $A.util.addClass(modal, 'slds-hide');
    },
    handleSpinner : function(component, value) {
        var spinner = component.getEvent('controlSpinner');
        spinner.setParams({'option': value});
        spinner.fire();
    },
    askConfirmation : function(component) {
        var confirmationModal = component.find('confirmationModal');
        confirmationModal.show('Confirmation','Are you sure you want to apply the selected changes?','milestone_edit');
    },
    handleConfiramtion : function(event) {
        var decision = event.getParam('decision');
        return decision == 'yes';
    },
    handleValidations : function(component) {
        var cmpIds = ['subject', 'status', 'endDate'];
        var allValid = true;
        for(var cmpId of cmpIds) {
            var inputCmp = component.find(cmpId);
            if(typeof inputCmp[0].reportValidity === 'function') {
                allValid &= inputCmp[0].reportValidity();
            } else {
                if(!inputCmp[0].get('v.value')) {
                    allValid = false;
                    inputCmp[0].showHelpMessageIfInvalid();
                }
            }           
        }

        return allValid;
    },
    clearErros : function(component) {
        component.set('v.fieldValidity',false);
        component.set('v.fieldValidity',true);    
    }, 
    handleSave : function(component) {
        var action = component.get('c.upsertMilestone');
        action.setParams({
            milestone : component.get('v.record')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var refreshEvt = component.getEvent('refreshTab');
                refreshEvt.setParams({
                    tabName : 'milestones'
                });
                refreshEvt.fire(); 
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

        this.handleSpinner(component,'show');
        $A.enqueueAction(action);
    }
})