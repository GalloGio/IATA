({
    handleTabChange : function(component,event) {
        var currTab = component.get('v.selectedTab');
        var newTab = event.target.dataset.option;

        if(currTab != newTab) {
            component.set('v.selectedTab', newTab);
        }
    },
    showModal : function(component) {     
        var modal = component.find('relations-form');
        $A.util.removeClass(modal, 'slds-hide');
    },
    hideModal : function(component) {
        var modal = component.find('relations-form');
        $A.util.addClass(modal, 'slds-hide');
    },
    initRecord : function(component,record) {   
        var convertedRecord = {};
        convertedRecord.ndc = record.NDC_engagement__c == true ? 'Yes' : 'No';
        
        convertedRecord.accountId = record.Id;
        convertedRecord.External_Entities_PAX_OTHER__c = record.External_Entities_PAX_OTHER__c;
        convertedRecord.External_Entities_CARGO_OTHER__c = record.External_Entities_CARGO_OTHER__c;
        convertedRecord.External_Entities_PAX__c = record.External_Entities_PAX__c;
        convertedRecord.External_Entities_CARGO__c = record.External_Entities_CARGO__c;

        component.set('v.record', convertedRecord);
    },
    convertToSFRecord : function(component) {
        var convertedRecord = component.get('v.record');
        var recordToUpdate = {'sobjectType': 'Account'};

        recordToUpdate.Id = convertedRecord.accountId;
        recordToUpdate.External_Entities_PAX_OTHER__c = convertedRecord.External_Entities_PAX_OTHER__c;
        recordToUpdate.External_Entities_CARGO_OTHER__c = convertedRecord.External_Entities_CARGO_OTHER__c;
        recordToUpdate.External_Entities_PAX__c = convertedRecord.External_Entities_PAX__c;
        recordToUpdate.External_Entities_CARGO__c = convertedRecord.External_Entities_CARGO__c;
        recordToUpdate.NDC_engagement__c = convertedRecord.ndc == 'Yes';

        return recordToUpdate;
    },
    handleSave : function(component,sfRecord) {
        var action = component.get('c.editCoreRelations');
        action.setParams({
            'record' : sfRecord
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var refreshEvt = component.getEvent('refreshTab');
                refreshEvt.setParams({
                    tabName : 'core_relationships'
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
    askConfirmation : function(component) {
        var confirmationModal = component.find('confirmationModal');
        confirmationModal.show('Confirmation','Are you sure you want to apply the selected changes?','core_relations_edit');
    },
    handleConfiramtion : function(event) {
        var decision = event.getParam('decision');
        return decision == 'yes';
    },
    handleSpinner : function(component,action) {
        var spinner = component.getEvent('controlSpinner');
        spinner.setParams({'option': action});
        spinner.fire();  
    },
    handleCheck : function(selectedOpts,option) {
        var res = selectedOpts;

        if(res) {
            res += ';' + option;
        } else {
            res = option;
        }

        return res; 
    },
    handleUncheck : function(selectedOpts,option) {
        var res = selectedOpts.split(';');
        res = res.filter(e => e !== option);
        res = res.join(';');

        return res;
    }
})