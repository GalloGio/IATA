({
    loadDropdowns : function(component) {
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

        var importanceList = [
            {id: 'High', label: 'High'},
            {id: 'Medium', label: 'Medium'},
            {id: 'Low', label: 'Low'},
        ];
        component.set("v.importanceList", importanceList);

        var statusList = [
            {id: 'Open', label: 'Open'},
            {id: 'Closed', label: 'Closed'},
            {id: 'Out Of Scope', label: 'Out Of Scope'}
        ];
        component.set("v.statusList", statusList);
    },
    handleSave : function(component) {
        var record = component.get('v.record');
        var action = component.get('c.upsertIssue');

        if(!record.AM_Level_of_importance__c) {
            record.AM_Level_of_importance__c = 'High';
        }

        if(!record.Status__c) {
            record.Status__c = 'Open';
        }

        action.setParams({
            'issue' : JSON.stringify(record)
        });

        this.handleSpinner(component, 'show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
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
    },
    showModal : function(component, record) {
        component.set('v.errorMessage', null);
        component.set('v.record', record);
        var modal = component.find('issue-form');
        $A.util.removeClass(modal, 'slds-hide');
    },
    hideModal : function(component) {
        component.set('v.errorMessage', null);
        var modal = component.find('issue-form');
        $A.util.addClass(modal, 'slds-hide');
    },
    askConfirmation : function(component) {
        var confirmationModal = component.find('confirmationModal');
        confirmationModal.show('Confirmation','Are you sure you want to apply the selected changes?','issue_priority_edit');
    },
    handleConfiramtion : function(event) {
        var decision = event.getParam('decision');
        return decision == 'yes';
    }
})