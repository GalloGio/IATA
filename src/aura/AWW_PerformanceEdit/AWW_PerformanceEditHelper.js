({
    initPicklists : function(component) {
        var typeList = [
            {id: '', label: '--None--'},
            {id: 'BMA', label: 'BMA'},
            {id: 'RSA', label: 'RSA'},
            {id: 'OSA', label: 'OSA'},
        ];
        component.set('v.typeList', typeList);
        var statusList = [
            {id: '', label: '--None--'},
            {id: 'On Track', label: 'On Track'},
            {id: 'On Hold', label: 'On Hold'},
            {id: 'Delayed', label: 'Delayed'},
            {id: 'Delivered', label: 'Delivered'},
            {id: 'Cancelled', label: 'Cancelled'},
            {id: 'Not Delivered', label: 'Not Delivered'},
            {id: 'Not Started', label: 'Not Started'}
        ];
        component.set('v.statusList', statusList);
        var divisionList = [
            {id: '', label: '--None--'},
            {id: 'APCS', label: 'APCS'},
            {id: 'CS', label: 'CS'},
            {id: 'DG', label: 'DG'},
            {id: 'FDS', label: 'FDS'},
            {id: 'MACS', label: 'MACS'},
            {id: 'MER', label: 'MER'},
            {id: 'SFO', label: 'SFO'}
        ];
        component.set("v.divisionList", divisionList);
        var unitList = [
            {id: '', label: '--None--'},
            {id: 'Number', label: 'Number'},
            {id: 'Percentage', label: 'Percentage'},
        ];
        component.set("v.unitList", unitList);
    },
    showModal : function(component, record) {
        this.clearErros(component);
        component.set('v.errorMessage', null);
        component.set('v.record', record);
        var modal = component.find('performance-form');
        $A.util.removeClass(modal, 'slds-hide');
    },
    hideModal : function(component) {
        component.set('v.errorMessage', null);
        var modal = component.find('performance-form');
        $A.util.addClass(modal, 'slds-hide');
    },
    askConfirmation : function(component) {
        var confirmationModal = component.find('confirmationModal');
        confirmationModal.show('Confirmation','Are you sure you want to apply the selected changes?','performance_edit');
    },
    handleConfiramtion : function(event) {
        var decision = event.getParam('decision');
        return decision == 'yes';
    },
    clearErros : function(component) {
        component.set('v.fieldValidity',false);
        component.set('v.fieldValidity',true);    
    },
    handleValidations : function(component) {
        var cmpIds = ['activityName', 'activityType', 'activityStatus', 'deadline', 'division', 'type'];
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
    handleSave : function(component) {
        var action = component.get('c.upsertRecord');
        action.setParams({
            record : component.get('v.record'),
            accountId : component.get('v.accountId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var refreshEvt = component.getEvent('refreshTab');
                refreshEvt.setParams({
                    tabName : 'performance_measures'
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
    },
    handleSpinner : function(component,action) {
        var spinner = component.getEvent('controlSpinner');
        spinner.setParams({'option': action});
        spinner.fire();  
    }
})